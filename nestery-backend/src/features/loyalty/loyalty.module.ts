import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { LoyaltyService } from './loyalty.service';
import { LoyaltyController } from './loyalty.controller';
import { UsersModule } from '../../users/users.module';
import { UserEntity } from '../../users/entities/user.entity';
import { BookingEntity } from '../../bookings/entities/booking.entity';

/**
 * Module for loyalty program functionality
 */
@Module({
  imports: [
    HttpModule,
    ConfigModule,
    CoreModule,
    UsersModule,
    TypeOrmModule.forFeature([UserEntity, BookingEntity]),
  ],
  controllers: [LoyaltyController],
  providers: [LoyaltyService],
  exports: [LoyaltyService],
})
export class LoyaltyModule {}
