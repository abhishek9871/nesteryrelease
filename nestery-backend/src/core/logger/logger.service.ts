import { Injectable, LoggerService as NestLoggerService } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * Custom logger service that extends NestJS Logger functionality
 * with additional context and formatting options
 */
@Injectable()
export class LoggerService implements NestLoggerService {
  private context?: string;
  private readonly logLevels: { [key: string]: number } = {
    error: 0,
    warn: 1,
    info: 2,
    debug: 3,
  };
  private currentLogLevel: number;

  constructor(private readonly configService: ConfigService) {
    const configuredLevel = this.configService.get<string>('LOG_LEVEL', 'info');
    this.currentLogLevel = this.logLevels[configuredLevel];
  }

  /**
   * Set the context for the logger
   */
  setContext(context: string): void {
    this.context = context;
  }

  /**
   * Log a debug message
   */
  debug(message: any, context?: string): void {
    if (this.currentLogLevel >= this.logLevels.debug) {
      this.printLog('debug', message, context || this.context);
    }
  }

  /**
   * Log an info message
   */
  log(message: any, context?: string): void {
    if (this.currentLogLevel >= this.logLevels.info) {
      this.printLog('info', message, context || this.context);
    }
  }

  /**
   * Log a warning message
   */
  warn(message: any, context?: string): void {
    if (this.currentLogLevel >= this.logLevels.warn) {
      this.printLog('warn', message, context || this.context);
    }
  }

  /**
   * Log an error message
   */
  error(message: any, trace?: string, context?: string): void {
    if (this.currentLogLevel >= this.logLevels.error) {
      this.printLog('error', message, context || this.context);
      if (trace) {
        console.error(trace);
      }
    }
  }

  /**
   * Format and print the log message
   */
  private printLog(level: string, message: any, context?: string): void {
    const timestamp = new Date().toISOString();
    const formattedMessage = typeof message === 'object' ? JSON.stringify(message) : message;
    const contextString = context ? `[${context}]` : '';
    
    console.log(`${timestamp} ${level.toUpperCase()} ${contextString} ${formattedMessage}`);
  }
}
