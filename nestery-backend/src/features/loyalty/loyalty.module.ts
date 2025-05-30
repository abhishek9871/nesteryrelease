import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { CoreModule } from '../../core/core.module';
import { LoyaltyService } from './loyalty.service';
import { LoyaltyController } from './loyalty.controller';
import { UsersModule } from '../../users/users.module';
import { UserEntity } from '../../users/entities/user.entity';
import { LoyaltyTierDefinitionEntity } from './entities/loyalty-tier-definition.entity';
import { LoyaltyTransactionEntity } from './entities/loyalty-transaction.entity';

/**
 * Module for loyalty program functionality
 */
@Module({
  imports: [
    CoreModule,
    UsersModule,
    TypeOrmModule.forFeature([UserEntity, LoyaltyTierDefinitionEntity, LoyaltyTransactionEntity]),
    // EventEmitterModule is already imported globally in AppModule
    // If not, it should be imported here: EventEmitterModule.forRoot()
  ],
  controllers: [LoyaltyController],
  providers: [LoyaltyService],
  exports: [LoyaltyService],
})
export class LoyaltyModule {}
