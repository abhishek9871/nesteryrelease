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
import { SocialSharingModule } from './features/social-sharing/social-sharing.module';
import { configValidationSchema } from './config/config.schema';

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
    
    // Database
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DB_HOST'),
        port: configService.get('DB_PORT'),
        username: configService.get('DB_USERNAME'),
        password: configService.get('DB_PASSWORD'),
        database: configService.get('DB_DATABASE'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
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
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
