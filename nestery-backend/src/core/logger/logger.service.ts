import { Injectable, LoggerService as NestLoggerService } from '@nestjs/common';

@Injectable()
export class LoggerService implements NestLoggerService {
  private context: string = 'Application';

  setContext(context: string) {
    this.context = context;
  }

  log(message: string, ...optionalParams: unknown[]) {
    // eslint-disable-next-line no-console
    console.log(`[${this.context}] ${message}`, ...optionalParams);
  }

  error(message: string, trace?: string, ...optionalParams: unknown[]) {
    // eslint-disable-next-line no-console
    console.error(`[${this.context}] ERROR: ${message}`, trace || '', ...optionalParams);
  }

  warn(message: string, ...optionalParams: unknown[]) {
    console.warn(`[${this.context}] WARNING: ${message}`, ...optionalParams);
  }

  debug(message: string, ...optionalParams: unknown[]) {
    // eslint-disable-next-line no-console
    console.debug(`[${this.context}] DEBUG: ${message}`, ...optionalParams);
  }

  verbose(message: string, ...optionalParams: unknown[]) {
    // eslint-disable-next-line no-console
    console.log(`[${this.context}] VERBOSE: ${message}`, ...optionalParams);
  }
}
