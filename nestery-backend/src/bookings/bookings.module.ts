import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BookingsService } from './bookings.service';
import { BookingsController } from './bookings.controller';
import { Booking } from './entities/booking.entity';
import { CoreModule } from '../core/core.module';
import { UsersModule } from '../users/users.module';
import { PropertiesModule } from '../properties/properties.module';

/**
 * Bookings module handling booking-related operations
 */
@Module({
  imports: [
    TypeOrmModule.forFeature([Booking]),
    CoreModule,
    UsersModule,
    PropertiesModule,
  ],
  controllers: [BookingsController],
  providers: [BookingsService],
  exports: [BookingsService],
})
export class BookingsModule {}
