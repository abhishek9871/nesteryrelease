import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { IntegrationsService } from './integrations.service';
import { BookingComService } from './booking-com/booking-com.service';
import { OyoService } from './oyo/oyo.service';
import { GoogleMapsService } from './google-maps/google-maps.service';
import { CoreModule } from '../core/core.module';

/**
 * Integrations module handling external API integrations
 */
@Module({
  imports: [
    CoreModule,
  ],
  providers: [
    IntegrationsService,
    BookingComService,
    OyoService,
    GoogleMapsService,
  ],
  exports: [
    IntegrationsService,
    BookingComService,
    OyoService,
    GoogleMapsService,
  ],
})
export class IntegrationsModule {}
