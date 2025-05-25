import { Injectable, Logger } from '@nestjs/common';
import { Readable } from 'stream';
import * as crypto from 'crypto';
import * as path from 'path';
import * as fs from 'fs';
import * as os from 'os';

export interface FileInfo {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  buffer: Buffer;
  size: number;
  filename: string;
  path?: string;
}

export interface MultipartParserOptions {
  limits?: {
    fileSize?: number; // in bytes
    files?: number; // max number of files
    fields?: number; // max number of fields
  };
  fileFilter?: (mimetype: string, filename: string) => boolean;
  dest?: string; // destination directory
}

@Injectable()
export class MultipartParserService {
  private readonly logger = new Logger(MultipartParserService.name);
  private readonly defaultOptions: MultipartParserOptions = {
    limits: {
      fileSize: 5 * 1024 * 1024, // 5MB
      files: 10,
      fields: 20,
    },
    fileFilter: (mimetype: string, filename: string) => true,
    dest: os.tmpdir(),
  };

  /**
   * Parses a multipart/form-data request
   * @param req The request object
   * @param options Parser options
   * @returns Promise with parsed files and fields
   */
  async parseMultipartData(
    req: any,
    options: MultipartParserOptions = {},
  ): Promise<{ files: FileInfo[]; fields: Record<string, string> }> {
    const mergedOptions = this.mergeOptions(options);
    const contentType = req.headers['content-type'] || '';
    
    if (!contentType.includes('multipart/form-data')) {
      throw new Error('Content-Type is not multipart/form-data');
    }

    const boundary = this.extractBoundary(contentType);
    if (!boundary) {
      throw new Error('No boundary found in Content-Type header');
    }

    return new Promise((resolve, reject) => {
      const files: FileInfo[] = [];
      const fields: Record<string, string> = {};
      let fileCount = 0;
      let fieldCount = 0;
      let currentFile: FileInfo | null = null;
      let currentField: { name: string; value: string } | null = null;
      let inHeader = true;
      let buffer = Buffer.alloc(0);
      let totalSize = 0;

      // Set up timeout to prevent hanging
      const timeout = setTimeout(() => {
        req.destroy();
        reject(new Error('Request processing timeout'));
      }, 30000); // 30 seconds timeout

      // Handle request errors
      req.on('error', (err) => {
        clearTimeout(timeout);
        this.logger.error(`Request error: ${err.message}`);
        reject(err);
      });

      // Process data chunks
      req.on('data', (chunk: Buffer) => {
        try {
          // Check total size to prevent memory exhaustion
          totalSize += chunk.length;
          if (totalSize > 50 * 1024 * 1024) { // 50MB total request size limit
            req.destroy();
            throw new Error('Request body too large');
          }

          buffer = Buffer.concat([buffer, chunk]);
          
          // Process buffer
          this.processBuffer(buffer, boundary, mergedOptions, files, fields, 
            (newBuffer, newFiles, newFields, newFileCount, newFieldCount) => {
              buffer = newBuffer;
              files.length = 0;
              files.push(...newFiles);
              Object.assign(fields, newFields);
              fileCount = newFileCount;
              fieldCount = newFieldCount;
              
              // Check limits
              if (mergedOptions.limits.files && fileCount > mergedOptions.limits.files) {
                req.destroy();
                throw new Error(`Too many files. Maximum is ${mergedOptions.limits.files}`);
              }
              
              if (mergedOptions.limits.fields && fieldCount > mergedOptions.limits.fields) {
                req.destroy();
                throw new Error(`Too many fields. Maximum is ${mergedOptions.limits.fields}`);
              }
            }
          );
        } catch (err) {
          clearTimeout(timeout);
          this.logger.error(`Error processing chunk: ${err.message}`);
          reject(err);
        }
      });

      // End of request
      req.on('end', () => {
        clearTimeout(timeout);
        resolve({ files, fields });
      });
    });
  }

  /**
   * Process the buffer to extract files and fields
   */
  private processBuffer(
    buffer: Buffer,
    boundary: string,
    options: MultipartParserOptions,
    files: FileInfo[],
    fields: Record<string, string>,
    callback: (
      newBuffer: Buffer,
      newFiles: FileInfo[],
      newFields: Record<string, string>,
      fileCount: number,
      fieldCount: number,
    ) => void,
  ): void {
    // Implementation of multipart parsing logic
    // This is a simplified version - in production, use a more robust parser
    
    // For now, we'll use a placeholder implementation
    // In a real implementation, this would parse the multipart data according to RFC 7578
    
    // Placeholder implementation
    callback(Buffer.alloc(0), files, fields, files.length, Object.keys(fields).length);
  }

  /**
   * Extract boundary from Content-Type header
   */
  private extractBoundary(contentType: string): string | null {
    const boundaryMatch = contentType.match(/boundary=(?:"([^"]+)"|([^;]+))/i);
    return boundaryMatch ? (boundaryMatch[1] || boundaryMatch[2]) : null;
  }

  /**
   * Merge default options with provided options
   */
  private mergeOptions(options: MultipartParserOptions): MultipartParserOptions {
    return {
      limits: {
        ...this.defaultOptions.limits,
        ...options.limits,
      },
      fileFilter: options.fileFilter || this.defaultOptions.fileFilter,
      dest: options.dest || this.defaultOptions.dest,
    };
  }

  /**
   * Generate a secure random filename
   */
  private generateFilename(originalname: string): string {
    const ext = path.extname(originalname);
    const randomName = crypto.randomBytes(16).toString('hex');
    return `${randomName}${ext}`;
  }

  /**
   * Save file to disk
   */
  private saveFileToDisk(fileInfo: FileInfo, dest: string): Promise<string> {
    return new Promise((resolve, reject) => {
      const filePath = path.join(dest, fileInfo.filename);
      const writeStream = fs.createWriteStream(filePath);
      
      const readable = new Readable();
      readable._read = () => {}; // Required but not used
      readable.push(fileInfo.buffer);
      readable.push(null); // EOF
      
      readable.pipe(writeStream);
      
      writeStream.on('finish', () => {
        resolve(filePath);
      });
      
      writeStream.on('error', (err) => {
        this.logger.error(`Error saving file: ${err.message}`);
        reject(err);
      });
    });
  }
}
