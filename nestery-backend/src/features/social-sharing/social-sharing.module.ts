import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SocialSharingService } from './social-sharing.service';
import { SocialSharingController } from './social-sharing.controller';
import { User } from '../../users/entities/user.entity';
import { LoggerModule } from '../../core/logger/logger.module';
import { ExceptionModule } from '../../core/exception/exception.module';

@Module({
  imports: [TypeOrmModule.forFeature([User]), HttpModule, LoggerModule, ExceptionModule],
  controllers: [SocialSharingController],
  providers: [SocialSharingService],
  exports: [SocialSharingService],
})
export class SocialSharingModule {}
