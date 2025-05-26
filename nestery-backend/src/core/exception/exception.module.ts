import { Module } from '@nestjs/common';
import { ExceptionService } from './exception.service';
import { LoggerModule } from '../logger/logger.module';

@Module({
  imports: [LoggerModule],
  providers: [ExceptionService],
  exports: [ExceptionService],
})
export class ExceptionModule {}
