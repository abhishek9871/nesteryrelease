Starting Container

 

> nestery-backend@0.0.1 start:prod

> node dist/main

 

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [NestFactory] Starting Nest application...

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +42ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] PassportModule dependencies initialized +1ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] ConfigModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] LoggerModule dependencies initialized +0ms

[UtilsService] Attempting to connect to Redis cache at fit-crawdad-24523.upstash.io:6379 CacheModuleFactory

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] HttpModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] ConfigHostModule dependencies initialized +1ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] CoreModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] DiscoveryModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] ExceptionModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] CacheModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] ConfigModule dependencies initialized +1ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] ScheduleModule dependencies initialized +7ms

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] EventEmitterModule dependencies initialized +0ms

[BookingComService] Initialized BookingComService with Demand API v3.1: https://distribution-xml.booking.com/3.1

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] JwtModule dependencies initialized +92ms

[GoogleMapsService] Redis connection test successful to fit-crawdad-24523.upstash.io:6379 CacheModuleFactory

[Nest] 12  - 06/10/2025, 7:03:56 PM     LOG [InstanceLoader] CacheModule dependencies initialized +422ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [InstanceLoader] TypeOrmCoreModule dependencies initialized +7933ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [InstanceLoader] TypeOrmModule dependencies initialized +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/social-sharing/user/:userId/referral, GET} route +1ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/social-sharing/user/:userId/referral/generate, POST} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/social-sharing/referral/:referralCode/process, POST} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/social-sharing/property/:propertyId/stats, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/social-sharing/booking/:bookingId/share, POST} route +1ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RoutesResolver] AffiliateController {/v1/affiliates}: +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/partners/:partnerId/offers, POST} route +1ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/offers/:offerId/trackable-link, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/redirect/:uniqueCode, GET} route +1ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/offers/:offerId, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/partners, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/partners/:id, GET} route +2ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/partners/:id, PUT} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/partners/:id, DELETE} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/partners/:id/dashboard, GET} route +1ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/offers, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/offers/active, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/offers/:id, PUT} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/offers/:id, DELETE} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/dashboard, GET} route +1ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/offers, POST} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/affiliates/offers/:offerId, PUT} route +2ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RoutesResolver] RevenueAnalyticsController {/v1/v1/revenue}: +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/v1/revenue/analytics/summary, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/v1/revenue/analytics/partner, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/v1/revenue/partner/performance, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/v1/revenue/trends, GET} route +1ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/v1/revenue/trends/partner, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/v1/revenue/commission/batches, GET} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/v1/revenue/commission/process, POST} route +0ms

[Nest] 12  - 06/10/2025, 7:04:04 PM     LOG [RouterExplorer] Mapped {/v1/v1/revenue/analytics/cache/clear, POST} route +0ms

[Nest] 12  - 06/10/2025, 7:04:05 PM     LOG [NestApplication] Nest application successfully started +423ms

[Bootstrap] ✅ Application is running on 0.0.0.0:3000