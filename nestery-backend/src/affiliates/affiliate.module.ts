import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';

import { AffiliateController } from './affiliate.controller';

import { PartnerService } from './services/partner.service';
import { AffiliateOfferService } from './services/affiliate-offer.service';
import { TrackableLinkService } from './services/trackable-link.service';
import { AffiliateEarningService } from './services/affiliate-earning.service';
import { CommissionCalculationService } from './services/commission-calculation.service';
import { PayoutService } from './services/payout.service';
import { AuditService } from './services/audit.service';

import { PartnerEntity } from './entities/partner.entity';
import { AffiliateOfferEntity } from './entities/affiliate-offer.entity';
import { AffiliateLinkEntity } from './entities/affiliate-link.entity';
import { AffiliateEarningEntity } from './entities/affiliate-earning.entity';
import { AuditLogEntity } from './entities/audit-log.entity';
import { PayoutEntity } from './entities/payout.entity';
import { InvoiceEntity } from './entities/invoice.entity';

import { UserEntity } from '../users/entities/user.entity';
import { BookingEntity } from '../bookings/entities/booking.entity';

@Module({
  imports: [
    ConfigModule,
    ScheduleModule.forRoot(),
    TypeOrmModule.forFeature([
      PartnerEntity,
      AffiliateOfferEntity,
      AffiliateLinkEntity,
      AffiliateEarningEntity,
      AuditLogEntity,
      PayoutEntity,
      InvoiceEntity,
      UserEntity, // To allow TrackableLinkService to associate links with users
      BookingEntity, // To allow AffiliateEarningService to associate earnings with bookings
    ]),
  ],
  controllers: [AffiliateController],
  providers: [
    PartnerService,
    AffiliateOfferService,
    TrackableLinkService,
    AffiliateEarningService,
    CommissionCalculationService,
    PayoutService,
    AuditService,
  ],
})
export class AffiliateModule {}
