import { Injectable } from '@nestjs/common';
import { LoggerService } from '../logger/logger.service';

/**
 * Service for handling exceptions and error responses consistently across the application
 */
@Injectable()
export class ExceptionService {
  constructor(private readonly logger: LoggerService) {
    this.logger.setContext('ExceptionService');
  }

  /**
   * Creates a standardized error response object
   */
  createErrorResponse(
    statusCode: number,
    message: string,
    error: string,
    details?: any,
  ): Record<string, any> {
    const errorResponse = {
      statusCode,
      message,
      error,
      timestamp: new Date().toISOString(),
    };

    if (details) {
      Object.assign(errorResponse, { details });
    }

    this.logger.error(`Error: ${error} - ${message}`, JSON.stringify(errorResponse));
    return errorResponse;
  }

  /**
   * Handles and logs an exception
   */
  handleException(exception: any): void {
    const errorMessage = exception.message || 'Unknown error occurred';
    const errorStack = exception.stack || '';
    
    this.logger.error(errorMessage, errorStack);
  }
}
