import { Module } from '@nestjs/common';
import { CoreService } from './core.service';
import { LoggerService } from './logger/logger.service';
import { ExceptionService } from './exception/exception.service';
import { UtilsService } from './utils/utils.service';

/**
 * Core module containing shared services and utilities used across the application
 */
@Module({
  providers: [CoreService, LoggerService, ExceptionService, UtilsService],
  exports: [CoreService, LoggerService, ExceptionService, UtilsService],
})
export class CoreModule {}
