import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { User } from './entities/user.entity';
import { PremiumSubscription } from '../features/subscriptions/entities/premium-subscription.entity';
import { CoreModule } from '../core/core.module';
import { ConfigModule } from '@nestjs/config'; // Import ConfigModule

/**
 * Users module handling user-related operations
 */
@Module({
  imports: [TypeOrmModule.forFeature([User, PremiumSubscription]), CoreModule, ConfigModule], // Add ConfigModule and PremiumSubscription
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
