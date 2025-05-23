import { Injectable } from '@nestjs/common';
import { LoggerService } from './logger/logger.service';

/**
 * Core service providing common functionality across the application
 */
@Injectable()
export class CoreService {
  constructor(private readonly logger: LoggerService) {
    this.logger.setContext('CoreService');
  }

  /**
   * Returns the current timestamp
   */
  getCurrentTimestamp(): number {
    return Date.now();
  }

  /**
   * Generates a unique identifier with optional prefix
   */
  generateUniqueId(prefix?: string): string {
    const timestamp = this.getCurrentTimestamp();
    const random = Math.floor(Math.random() * 10000);
    return prefix ? `${prefix}-${timestamp}-${random}` : `${timestamp}-${random}`;
  }
}
