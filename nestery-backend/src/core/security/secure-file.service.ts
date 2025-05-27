import { Injectable, Logger, BadRequestException, PayloadTooLargeException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';
import * as path from 'path';
import * as crypto from 'crypto';
import * as mime from 'mime-types';
import { stat, mkdir, writeFile } from 'fs/promises';
import { MultipartParserService } from './multipart-parser.service';

export interface FileInfo {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  buffer: Buffer;
  size: number;
  filename?: string;
  path?: string;
}

export interface SecureFileOptions {
  allowedMimeTypes?: string[];
  maxFileSize?: number;
  destination?: string;
  sanitizeFilename?: boolean;
  generateRandomFilename?: boolean;
}

@Injectable()
export class SecureFileService {
  private readonly logger = new Logger(SecureFileService.name);
  private readonly defaultOptions: SecureFileOptions = {
    allowedMimeTypes: [],
    maxFileSize: 5 * 1024 * 1024, // 5MB
    destination: './uploads',
    sanitizeFilename: true,
    generateRandomFilename: true,
  };

  constructor(private readonly configService: ConfigService) {
    // Initialize with config values if available
    const configMaxSize = this.configService.get<number>('MAX_FILE_SIZE');
    if (configMaxSize) {
      this.defaultOptions.maxFileSize = configMaxSize;
    }

    const uploadDir = this.configService.get<string>('UPLOAD_DIRECTORY');
    if (uploadDir) {
      this.defaultOptions.destination = uploadDir;
    }
  }

  /**
   * Process upload from request
   */
  async processUpload(req: Request, options: SecureFileOptions = {}): Promise<FileInfo[]> {
    // Use MultipartParserService to parse the request
    const multipartParser = new MultipartParserService();
    const { files } = await multipartParser.parseMultipartData(req, {});

    // Process the parsed files
    return this.processFiles(files, options);
  }

  /**
   * Process uploaded files with security checks
   */
  async processFiles(files: FileInfo[], options: SecureFileOptions = {}): Promise<FileInfo[]> {
    try {
      const mergedOptions = this.mergeOptions(options);

      // Ensure upload directory exists
      const destinationDir = mergedOptions.destination || this.defaultOptions.destination;
      if (!destinationDir) {
        throw new Error('Destination directory is required');
      }
      await this.ensureDirectoryExists(destinationDir);

      const processedFiles: FileInfo[] = [];

      for (const file of files) {
        // Validate file type and extension
        this.validateFile(file.mimetype, file.originalname, mergedOptions);

        // Validate file content (size, etc.)
        await this.validateFileContent(file, mergedOptions);

        // Process filename
        if (mergedOptions.sanitizeFilename) {
          file.originalname = this.sanitizeFilename(file.originalname);
        }

        if (mergedOptions.generateRandomFilename) {
          file.filename = this.generateSecureFilename(file.originalname);
        } else {
          file.filename = file.originalname;
        }

        // Save file
        const destination = mergedOptions.destination || this.defaultOptions.destination;
        if (!destination) {
          throw new Error('Destination directory is required');
        }
        file.path = await this.saveFile(file, destination);

        processedFiles.push(file);
      }

      return processedFiles;
    } catch (error) {
      this.logger.error(`File upload error: ${error.message}`, error.stack);

      if (error instanceof PayloadTooLargeException) {
        throw error;
      }

      throw new BadRequestException(`File upload failed: ${error.message || 'Unknown error'}`);
    }
  }

  /**
   * Validate file based on mime type and filename
   */
  private validateFile(mimetype: string, filename: string, options: SecureFileOptions): boolean {
    // Check mime type
    const allowedTypes = options.allowedMimeTypes || [];
    if (allowedTypes.length > 0 && !allowedTypes.includes(mimetype)) {
      this.logger.warn(`Rejected file with mimetype: ${mimetype}`);
      throw new BadRequestException(
        `File type not allowed. Allowed types: ${allowedTypes.join(', ')}`,
      );
    }

    // Check file extension matches mime type
    const extension = path.extname(filename).toLowerCase().substring(1);
    const expectedExtensions = mime.extensions[mimetype] || [];

    if (extension && expectedExtensions.length > 0 && !expectedExtensions.includes(extension)) {
      this.logger.warn(`File extension doesn't match mimetype: ${filename} (${mimetype})`);
      throw new BadRequestException("File extension doesn't match content type");
    }

    return true;
  }

  /**
   * Validate file content (size, format integrity)
   */
  private async validateFileContent(file: FileInfo, options: SecureFileOptions): Promise<void> {
    // Check file size
    const maxSize = options.maxFileSize || this.defaultOptions.maxFileSize;
    if (maxSize && file.size > maxSize) {
      throw new PayloadTooLargeException(
        `File too large. Maximum size is ${maxSize / 1024 / 1024}MB`,
      );
    }

    // Additional content validation could be added here
    // For example, validating image dimensions, checking PDF structure, etc.
  }

  /**
   * Sanitize filename to prevent path traversal and command injection
   */
  private sanitizeFilename(filename: string): string {
    // Remove path components
    let sanitized = path.basename(filename);

    // Replace potentially dangerous characters
    sanitized = sanitized.replace(/[^\w\s.-]/g, '_');

    // Ensure filename doesn't start with dots or dashes
    sanitized = sanitized.replace(/^[.-]+/, '');

    return sanitized;
  }

  /**
   * Generate secure random filename while preserving extension
   */
  private generateSecureFilename(originalname: string): string {
    const extension = path.extname(originalname);
    const randomName = crypto.randomBytes(16).toString('hex');
    return `${randomName}${extension}`;
  }

  /**
   * Save file to disk with proper error handling
   */
  private async saveFile(file: FileInfo, destination: string): Promise<string> {
    const filePath = path.join(destination, file.filename || '');

    try {
      await writeFile(filePath, file.buffer);
      return filePath;
    } catch (error) {
      this.logger.error(`Error saving file: ${error.message}`, error.stack);
      throw new Error(`Failed to save file: ${error.message}`);
    }
  }

  /**
   * Ensure directory exists, create if it doesn't
   */
  private async ensureDirectoryExists(directory: string): Promise<void> {
    try {
      await stat(directory);
    } catch (error) {
      if (error.code === 'ENOENT') {
        try {
          await mkdir(directory, { recursive: true });
        } catch (mkdirError) {
          this.logger.error(`Failed to create directory: ${mkdirError.message}`);
          throw new Error(`Failed to create upload directory: ${mkdirError.message}`);
        }
      } else {
        throw error;
      }
    }
  }

  /**
   * Merge default options with provided options
   */
  private mergeOptions(options: SecureFileOptions): SecureFileOptions {
    return {
      allowedMimeTypes: options.allowedMimeTypes || this.defaultOptions.allowedMimeTypes,
      maxFileSize: options.maxFileSize || this.defaultOptions.maxFileSize,
      destination: options.destination || this.defaultOptions.destination,
      sanitizeFilename:
        options.sanitizeFilename !== undefined
          ? options.sanitizeFilename
          : this.defaultOptions.sanitizeFilename,
      generateRandomFilename:
        options.generateRandomFilename !== undefined
          ? options.generateRandomFilename
          : this.defaultOptions.generateRandomFilename,
    };
  }
}
