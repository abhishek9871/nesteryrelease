import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { PricePredictionService } from './price-prediction.service';
import { Property } from '../../properties/entities/property.entity';

/**
 * Module for price prediction functionality
 */
@Module({
  imports: [HttpModule, ConfigModule, CoreModule, TypeOrmModule.forFeature([Property])],
  providers: [PricePredictionService],
  exports: [PricePredictionService],
})
export class PricePredictionModule {}
