import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { ConfigModule } from '@nestjs/config';
import { CoreModule } from '../../core/core.module';
import { LoyaltyService } from './loyalty.service';
import { LoyaltyController } from './loyalty.controller';
import { UsersModule } from '../../users/users.module';

/**
 * Module for loyalty program functionality
 */
@Module({
  imports: [
    HttpModule,
    ConfigModule,
    CoreModule,
    UsersModule,
  ],
  controllers: [LoyaltyController],
  providers: [LoyaltyService],
  exports: [LoyaltyService],
})
export class LoyaltyModule {}
