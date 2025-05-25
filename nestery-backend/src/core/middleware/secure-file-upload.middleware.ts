import { Injectable, NestMiddleware, Logger } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { SecureFileService } from '../security/secure-file.service';

export interface SecureFileUploadOptions {
  fieldName: string;
  allowedMimeTypes?: string[];
  maxFileSize?: number;
  destination?: string;
}

@Injectable()
export class SecureFileUploadMiddleware implements NestMiddleware {
  private readonly logger = new Logger(SecureFileUploadMiddleware.name);
  private options: SecureFileUploadOptions;

  constructor(private readonly secureFileService: SecureFileService) {}

  /**
   * Configure middleware options
   * @param options Upload options
   */
  configure(options: SecureFileUploadOptions): SecureFileUploadMiddleware {
    this.options = options;
    return this;
  }

  /**
   * Middleware implementation
   */
  async use(req: Request, res: Response, next: NextFunction) {
    if (!this.options) {
      this.logger.error('SecureFileUploadMiddleware not configured');
      return res.status(500).json({
        statusCode: 500,
        message: 'Server configuration error',
      });
    }

    try {
      // Process file upload
      const files = await this.secureFileService.processUpload(req, {
        allowedMimeTypes: this.options.allowedMimeTypes,
        maxFileSize: this.options.maxFileSize,
        destination: this.options.destination,
      });

      // Attach files to request object
      req[this.options.fieldName] = files.length === 1 ? files[0] : files;

      next();
    } catch (error) {
      this.logger.error(`File upload error: ${error.message}`, error.stack);
      
      // Send appropriate error response
      const statusCode = error.status || 400;
      return res.status(statusCode).json({
        statusCode,
        message: error.message || 'File upload failed',
        error: error.name || 'Bad Request',
      });
    }
  }
}
