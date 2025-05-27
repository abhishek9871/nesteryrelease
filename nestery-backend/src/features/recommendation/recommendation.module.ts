import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { RecommendationService } from './recommendation.service';
import { Property } from '../../properties/entities/property.entity';
import { User } from '../../users/entities/user.entity';
import { Booking } from '../../bookings/entities/booking.entity';

/**
 * Module for personalized recommendations functionality
 */
@Module({
  imports: [
    HttpModule,
    ConfigModule,
    CoreModule,
    TypeOrmModule.forFeature([Property, User, Booking])
  ],
  providers: [RecommendationService],
  exports: [RecommendationService],
})
export class RecommendationModule {}
