import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';
import { CoreModule } from '../../core/core.module';
import { PricePredictionService } from './price-prediction.service';

/**
 * Module for price prediction functionality
 */
@Module({
  imports: [
    HttpModule,
    ConfigModule,
    CoreModule,
  ],
  providers: [PricePredictionService],
  exports: [PricePredictionService],
})
export class PricePredictionModule {}
