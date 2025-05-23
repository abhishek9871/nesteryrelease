import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';
import { CoreModule } from '../../core/core.module';
import { SocialSharingService } from './social-sharing.service';
import { SocialSharingController } from './social-sharing.controller';

/**
 * Module for social sharing functionality
 */
@Module({
  imports: [
    HttpModule,
    ConfigModule,
    CoreModule,
  ],
  controllers: [SocialSharingController],
  providers: [SocialSharingService],
  exports: [SocialSharingService],
})
export class SocialSharingModule {}
