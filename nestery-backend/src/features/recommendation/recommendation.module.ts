import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';
import { CoreModule } from '../../core/core.module';
import { RecommendationService } from './recommendation.service';

/**
 * Module for personalized recommendations functionality
 */
@Module({
  imports: [
    HttpModule,
    ConfigModule,
    CoreModule,
  ],
  providers: [RecommendationService],
  exports: [RecommendationService],
})
export class RecommendationModule {}
