import { Injectable, Logger, BadRequestException, PayloadTooLargeException } from '@nestjs/common';
import { FileInfo, MultipartParserService, MultipartParserOptions } from './multipart-parser.service';
import * as fs from 'fs';
import * as path from 'path';
import * as crypto from 'crypto';
import * as mime from 'mime-types';
import { promisify } from 'util';

const mkdir = promisify(fs.mkdir);
const writeFile = promisify(fs.writeFile);
const stat = promisify(fs.stat);

export interface SecureFileOptions {
  allowedMimeTypes?: string[];
  maxFileSize?: number; // in bytes
  destination?: string;
  sanitizeFilename?: boolean;
  generateRandomFilename?: boolean;
}

@Injectable()
export class SecureFileService {
  private readonly logger = new Logger(SecureFileService.name);
  private readonly defaultOptions: SecureFileOptions = {
    allowedMimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'],
    maxFileSize: 5 * 1024 * 1024, // 5MB
    destination: './uploads',
    sanitizeFilename: true,
    generateRandomFilename: true,
  };

  constructor(private readonly multipartParser: MultipartParserService) {}

  /**
   * Process file upload with security checks
   * @param req Express request object
   * @param options Secure file options
   * @returns Promise with processed file information
   */
  async processUpload(req: any, options: SecureFileOptions = {}): Promise<FileInfo[]> {
    const mergedOptions = this.mergeOptions(options);
    
    // Create destination directory if it doesn't exist
    await this.ensureDirectoryExists(mergedOptions.destination);
    
    // Configure multipart parser options
    const parserOptions: MultipartParserOptions = {
      limits: {
        fileSize: mergedOptions.maxFileSize,
        files: 10, // Reasonable limit
      },
      fileFilter: (mimetype, filename) => this.validateFile(mimetype, filename, mergedOptions),
      dest: mergedOptions.destination,
    };
    
    try {
      // Parse multipart data
      const { files, fields } = await this.multipartParser.parseMultipartData(req, parserOptions);
      
      if (files.length === 0) {
        throw new BadRequestException('No files were uploaded');
      }
      
      // Process each file
      const processedFiles: FileInfo[] = [];
      
      for (const file of files) {
        // Additional validation
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
        file.path = await this.saveFile(file, mergedOptions.destination);
        
        processedFiles.push(file);
      }
      
      return processedFiles;
    } catch (error) {
      this.logger.error(`File upload error: ${error.message}`, error.stack);
      
      if (error instanceof PayloadTooLargeException) {
        throw error;
      }
      
      throw new BadRequestException(
        `File upload failed: ${error.message || 'Unknown error'}`,
      );
    }
  }
  
  /**
   * Validate file based on mime type and filename
   */
  private validateFile(
    mimetype: string, 
    filename: string, 
    options: SecureFileOptions
  ): boolean {
    // Check mime type
    if (options.allowedMimeTypes.length > 0 && !options.allowedMimeTypes.includes(mimetype)) {
      this.logger.warn(`Rejected file with mimetype: ${mimetype}`);
      throw new BadRequestException(
        `File type not allowed. Allowed types: ${options.allowedMimeTypes.join(', ')}`,
      );
    }
    
    // Check file extension matches mime type
    const extension = path.extname(filename).toLowerCase().substring(1);
    const expectedExtensions = mime.extensions[mimetype] || [];
    
    if (extension && expectedExtensions.length > 0 && !expectedExtensions.includes(extension)) {
      this.logger.warn(`File extension doesn't match mimetype: ${filename} (${mimetype})`);
      throw new BadRequestException('File extension doesn\'t match content type');
    }
    
    return true;
  }
  
  /**
   * Validate file content (size, format integrity)
   */
  private async validateFileContent(file: FileInfo, options: SecureFileOptions): Promise<void> {
    // Check file size
    if (file.size > options.maxFileSize) {
      throw new PayloadTooLargeException(
        `File too large. Maximum size is ${options.maxFileSize / 1024 / 1024}MB`,
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
    const filePath = path.join(destination, file.filename);
    
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
      sanitizeFilename: options.sanitizeFilename !== undefined 
        ? options.sanitizeFilename 
        : this.defaultOptions.sanitizeFilename,
      generateRandomFilename: options.generateRandomFilename !== undefined 
        ? options.generateRandomFilename 
        : this.defaultOptions.generateRandomFilename,
    };
  }
}
