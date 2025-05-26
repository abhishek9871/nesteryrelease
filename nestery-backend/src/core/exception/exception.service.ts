import { Injectable } from '@nestjs/common';
import { LoggerService } from '../logger/logger.service';

@Injectable()
export class ExceptionService {
  constructor(private readonly logger: LoggerService) {
    this.logger.setContext('ExceptionService');
  }

  handleException(error: Error): void {
    this.logger.error(`Exception handled: ${error.message}`, error.stack);
    // Additional error handling logic could be added here
    // such as sending to error monitoring service, etc.
  }

  handleHttpException(error: Error, statusCode: number): void {
    this.logger.error(`HTTP Exception (${statusCode}): ${error.message}`, error.stack);
    // Additional HTTP-specific error handling logic
  }

  handleDatabaseException(error: Error): void {
    this.logger.error(`Database Exception: ${error.message}`, error.stack);
    // Database-specific error handling logic
  }

  handleValidationException(error: Error): void {
    this.logger.error(`Validation Exception: ${error.message}`, error.stack);
    // Validation-specific error handling logic
  }
}
