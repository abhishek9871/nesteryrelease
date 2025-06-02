import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { HttpModule } from '@nestjs/axios';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CoreModule } from './core/core.module';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { PropertiesModule } from './properties/properties.module';
import { BookingsModule } from './bookings/bookings.module';
import { IntegrationsModule } from './integrations/integrations.module';
import { PricePredictionModule } from './features/price-prediction/price-prediction.module';
import { RecommendationModule } from './features/recommendation/recommendation.module';
import { LoyaltyModule } from './features/loyalty/loyalty.module';
import { EventEmitterModule } from '@nestjs/event-emitter';
import { SocialSharingModule } from './features/social-sharing/social-sharing.module';
import { AffiliateModule } from './affiliates/affiliate.module';
import { configValidationSchema } from './config/config.schema';
import { CacheModule } from '@nestjs/cache-manager';
import { createKeyv } from '@keyv/redis';

// Entity imports - Required for webpack bundling since glob patterns don't work
import { User } from './users/entities/user.entity';
import { Property } from './properties/entities/property.entity';
import { PropertyAvailability } from './properties/entities/property-availability.entity';
import { NesteryMasterProperty } from './properties/entities/nestery-master-property.entity';
import { Booking } from './bookings/entities/booking.entity';
import { Supplier } from './integrations/entities/supplier.entity';
import { SupplierProperty } from './integrations/entities/supplier-property.entity';
import { LoyaltyTierDefinitionEntity } from './features/loyalty/entities/loyalty-tier-definition.entity';
import { LoyaltyTransactionEntity } from './features/loyalty/entities/loyalty-transaction.entity';
import { LoyaltyReward } from './features/loyalty/entities/loyalty-reward.entity';
import { LoyaltyRedemption } from './features/loyalty/entities/loyalty-redemption.entity';
import { LoyaltyPointsLedger } from './features/loyalty/entities/loyalty-points-ledger.entity';
import { PricePrediction } from './features/price-prediction/entities/price-prediction.entity';
import { UserRecommendation } from './features/recommendation/entities/user-recommendation.entity';
import { Referral } from './features/referrals/entities/referral.entity';
import { Review } from './features/reviews/entities/review.entity';
import { SocialShare } from './features/social-sharing/entities/social-share.entity';
import { PremiumSubscription } from './features/subscriptions/entities/premium-subscription.entity';
import { Itinerary } from './features/itineraries/entities/itinerary.entity';
import { ItineraryItem } from './features/itineraries/entities/itinerary-item.entity';
import { LoggerService } from './core/logger/logger.service';

import { PartnerEntity } from './affiliates/entities/partner.entity';
import { AffiliateOfferEntity } from './affiliates/entities/affiliate-offer.entity';
import { AffiliateLinkEntity } from './affiliates/entities/affiliate-link.entity';
import { AffiliateEarningEntity } from './affiliates/entities/affiliate-earning.entity';

// import { PciSecurityMiddleware } from './middleware/pci-security.middleware'; // Removed as per redirect model for Booking.com

/**
 * Main application module
 */
@Module({
  imports: [
    // Configuration
    ConfigModule.forRoot({
      isGlobal: true,
      validationSchema: configValidationSchema,
      envFilePath: [`.env.${process.env.NODE_ENV}`, '.env'],
    }),
    EventEmitterModule.forRoot(),
    CacheModule.registerAsync({
      isGlobal: true,
      imports: [ConfigModule, CoreModule], // CoreModule exports LoggerService
      inject: [ConfigService, LoggerService],
      useFactory: async (configService: ConfigService, logger: LoggerService) => {
        const host = configService.get<string>('CACHE_HOST');
        const port = configService.get<number>('CACHE_PORT');
        const ttlInMilliseconds = configService.get<number>('CACHE_TTL_DEFAULT_SECONDS', 60) * 1000;

        try {
          logger.log(
            `Attempting to connect to Redis cache at ${host}:${port}`,
            'CacheModuleFactory',
          );

          // Create Redis connection URL
          const redisUrl = `redis://${host}:${port}`;

          // Test connection by creating a temporary Keyv instance
          const testKeyv = createKeyv(redisUrl);
          await testKeyv.set('test-connection', 'ok', 1000);
          await testKeyv.delete('test-connection');

          logger.log(`Redis connection test successful to ${host}:${port}`, 'CacheModuleFactory');

          // Return configuration with Redis store
          return {
            stores: [createKeyv(redisUrl)],
            ttl: ttlInMilliseconds, // Global TTL for CacheModule in milliseconds
          };
        } catch (error) {
          logger.warn(
            `Redis connection failed: ${error.message}. Falling back to in-memory cache.`,
            'CacheModuleFactory',
          );
          // Return configuration with in-memory cache only
          return {
            ttl: ttlInMilliseconds, // Global TTL for CacheModule in milliseconds
          };
        }
      },
    }),

    // Database
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DATABASE_HOST'),
        port: configService.get('DATABASE_PORT'),
        username: configService.get('DATABASE_USERNAME'),
        password: configService.get('DATABASE_PASSWORD'),
        database: configService.get('DATABASE_NAME'),
        entities: [
          // Core entities
          User,
          Property,
          PropertyAvailability,
          NesteryMasterProperty,
          Booking,
          Supplier,
          SupplierProperty,
          // Loyalty entities
          LoyaltyTierDefinitionEntity,
          LoyaltyTransactionEntity,
          LoyaltyReward,
          LoyaltyRedemption,
          LoyaltyPointsLedger,
          // Feature entities
          PricePrediction,
          UserRecommendation,
          Referral,
          Review,
          SocialShare,
          PremiumSubscription,
          Itinerary,
          ItineraryItem,
          // Affiliate Entities
          PartnerEntity,
          AffiliateOfferEntity,
          AffiliateLinkEntity,
          AffiliateEarningEntity,
        ],
        migrations: [__dirname + '/migrations/*{.ts,.js}'],
        synchronize: configService.get('NODE_ENV') !== 'production',
        logging: configService.get('NODE_ENV') !== 'production',
        ssl: configService.get('DB_SSL') === 'true',
      }),
    }),

    // HTTP
    HttpModule,

    // Core modules
    CoreModule,

    // Feature modules
    UsersModule,
    AuthModule,
    PropertiesModule,
    BookingsModule,
    IntegrationsModule,

    // Advanced feature modules
    PricePredictionModule,
    RecommendationModule,
    LoyaltyModule,
    SocialSharingModule,
    AffiliateModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {
  // configure(consumer: MiddlewareConsumer) {
  //   consumer
  //     .apply(PciSecurityMiddleware) // Removed as PCI scope is reduced by redirecting to Booking.com for payment
  //     .forRoutes('bookings/booking-com'); // Example, adjust if it was used elsewhere
  // }
}
