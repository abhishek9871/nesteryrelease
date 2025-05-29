import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IntegrationsService } from './integrations.service';
import { BookingComService } from './booking-com/booking-com.service';
import { OyoService } from './oyo/oyo.service';
import { GoogleMapsService } from './google-maps/google-maps.service';
import { CoreModule } from '../core/core.module';
import { Supplier } from './entities/supplier.entity';
import { Property } from '../properties/entities/property.entity';
import { PropertiesModule } from '../properties/properties.module';

/**
 * Integrations module handling external API integrations
 */
@Module({
  imports: [
    CoreModule,
    TypeOrmModule.forFeature([Supplier, Property]),
    PropertiesModule, // To use PropertiesService for fetching property details
  ],
  providers: [IntegrationsService, BookingComService, OyoService, GoogleMapsService],
  exports: [IntegrationsService, BookingComService, OyoService, GoogleMapsService],
})
export class IntegrationsModule {}
