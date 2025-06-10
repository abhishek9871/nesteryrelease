import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule } from '@nestjs/config';
import { ScheduleModule } from '@nestjs/schedule';
import { CacheModule } from '@nestjs/cache-manager';

import { AffiliateController } from './affiliate.controller';
import { RevenueAnalyticsController } from './controllers/revenue-analytics.controller';

import { PartnerService } from './services/partner.service';
import { AffiliateOfferService } from './services/affiliate-offer.service';
import { TrackableLinkService } from './services/trackable-link.service';
import { AffiliateEarningService } from './services/affiliate-earning.service';
import { CommissionCalculationService } from './services/commission-calculation.service';
import { PayoutService } from './services/payout.service';
import { AuditService } from './services/audit.service';
import { EnhancedCommissionService } from './services/enhanced-commission.service';
import { RevenueAnalyticsService } from './services/revenue-analytics.service';

import { PartnerEntity } from './entities/partner.entity';
import { AffiliateOfferEntity } from './entities/affiliate-offer.entity';
import { AffiliateLinkEntity } from './entities/affiliate-link.entity';
import { AffiliateEarningEntity } from './entities/affiliate-earning.entity';
import { AuditLogEntity } from './entities/audit-log.entity';
import { PayoutEntity } from './entities/payout.entity';
import { InvoiceEntity } from './entities/invoice.entity';
import { CommissionBatchEntity } from './entities/commission-batch.entity';

import { UserEntity } from '../users/entities/user.entity';
import { BookingEntity } from '../bookings/entities/booking.entity';
import { FrsCommissionRateValidator } from './validators/frs-commission.validator';

@Module({
  imports: [
    ConfigModule,
    ScheduleModule.forRoot(),
    CacheModule.register({
      ttl: 3600, // 1 hour default TTL
      max: 1000, // Maximum number of items in cache
    }),
    TypeOrmModule.forFeature([
      PartnerEntity,
      AffiliateOfferEntity,
      AffiliateLinkEntity,
      AffiliateEarningEntity,
      AuditLogEntity,
      PayoutEntity,
      InvoiceEntity,
      CommissionBatchEntity,
      UserEntity, // To allow TrackableLinkService to associate links with users
      BookingEntity, // To allow AffiliateEarningService to associate earnings with bookings
    ]),
  ],
  controllers: [AffiliateController, RevenueAnalyticsController],
  providers: [
    PartnerService,
    AffiliateOfferService,
    TrackableLinkService,
    AffiliateEarningService,
    CommissionCalculationService,
    PayoutService,
    AuditService,
    EnhancedCommissionService,
    RevenueAnalyticsService,
    // Add the FRS validator as a provider
    {
      provide: 'FrsCommissionRateValidator',
      useClass: FrsCommissionRateValidator,
    },
  ],
})
export class AffiliateModule {}
