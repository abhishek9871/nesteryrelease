import { Injectable, NotFoundException, BadRequestException, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { UserEntity } from '../../users/entities/user.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { DataSource, MoreThanOrEqual, Repository } from 'typeorm';
import { LoyaltyTierDefinitionEntity } from './entities/loyalty-tier-definition.entity';
import { LoyaltyTransactionEntity } from './entities/loyalty-transaction.entity';
import { LoyaltyTierEnum } from './enums/loyalty-tier.enum';
import { LoyaltyTransactionTypeEnum } from './enums/loyalty-transaction-type.enum';
import { EventEmitter2, OnEvent } from '@nestjs/event-emitter';

// Event payload interfaces (conceptual)
interface BookingCommissionFinalizedEvent {
  userId: string;
  netCommissionAmount: number;
  bookingId: string;
}
interface ReferralUsedEvent {
  referrerUserId: string;
  referralId: string;
}
interface ReviewApprovedEvent {
  userId: string;
  reviewId: string;
}
interface PremiumSubscriptionActivatedEvent {
  userId: string;
  subscriptionId: string;
}
interface UserProfileCompletedEvent {
  userId: string;
}
interface PartnerOfferEngagedEvent {
  userId: string;
  milesToAward: number;
  offerId: string;
}

@Injectable()
export class LoyaltyService implements OnModuleInit {
  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(LoyaltyTierDefinitionEntity)
    private readonly tierDefinitionRepository: Repository<LoyaltyTierDefinitionEntity>,
    @InjectRepository(LoyaltyTransactionEntity)
    private readonly transactionRepository: Repository<LoyaltyTransactionEntity>,
    private readonly eventEmitter: EventEmitter2,
    private readonly dataSource: DataSource,
  ) {
    this.logger.setContext('LoyaltyService');
  }

  /**
   * Get loyalty status and points for a user
   */
  async onModuleInit() {
    await this.seedLoyaltyTiers();
  }

  private async seedLoyaltyTiers() {
    const tiers = [
      {
        tier: LoyaltyTierEnum.SCOUT,
        name: 'Scout',
        minMilesRequired: 0,
        earningMultiplier: 1.0,
        benefitsDescription: 'Basic benefits',
      },
      {
        tier: LoyaltyTierEnum.EXPLORER,
        name: 'Explorer',
        minMilesRequired: 1000,
        earningMultiplier: 1.25,
        benefitsDescription: 'Explorer benefits',
      },
      {
        tier: LoyaltyTierEnum.NAVIGATOR,
        name: 'Navigator',
        minMilesRequired: 5000,
        earningMultiplier: 1.5,
        benefitsDescription: 'Navigator benefits',
      },
      {
        tier: LoyaltyTierEnum.GLOBETROTTER,
        name: 'Globetrotter',
        minMilesRequired: 20000,
        earningMultiplier: 2.0,
        benefitsDescription: 'Top-tier benefits',
      },
    ];

    for (const tierData of tiers) {
      const existingTier = await this.tierDefinitionRepository.findOneBy({ tier: tierData.tier });
      if (!existingTier) {
        const newTier = this.tierDefinitionRepository.create(tierData);
        await this.tierDefinitionRepository.save(newTier);
        this.logger.log(`Seeded loyalty tier: ${tierData.name}`);
      }
    }
  }

  async getLoyaltyStatus(userId: string): Promise<any> {
    try {
      this.logger.debug(`Getting loyalty status for user: ${userId}`);

      // Note: User's booking history could be used for additional loyalty calculations

      // Calculate total points
      const user = await this.userRepository.findOneBy({ id: userId });
      if (!user) {
        throw new NotFoundException(`User with ID ${userId} not found`);
      }
      const currentMiles = user.loyaltyMilesBalance;

      // Determine loyalty tier
      const currentTier = user.loyaltyTier;
      const tierDefinition = await this.tierDefinitionRepository.findOneBy({ tier: currentTier });

      // Get next tier and points needed
      const nextTierInfo = await this.getNextTierInfo(currentTier, currentMiles);

      return {
        loyaltyMilesBalance: currentMiles,
        loyaltyTier: currentTier,
        tierName: tierDefinition?.name,
        tierBenefits: tierDefinition?.benefitsDescription,
        nextTier: nextTierInfo.nextTier,
        milesToNextTier: nextTierInfo.milesNeeded,
        earningMultiplier: tierDefinition?.earningMultiplier,
      };
    } catch (error) {
      this.logger.error(`Error getting loyalty status: ${error.message}`, error.stack);
      throw error;
    }
  }

  /**
   * Award miles to a user
   */
  async awardMiles(
    userId: string,
    baseAmount: number,
    type: LoyaltyTransactionTypeEnum,
    description?: string,
    relatedEntity?: { type: string; id: string },
  ): Promise<LoyaltyTransactionEntity> {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const user = await queryRunner.manager.findOneBy(UserEntity, { id: userId });
      if (!user) {
        throw new NotFoundException(`User with ID ${userId} not found`);
      }

      const tierDefinition = await queryRunner.manager.findOneBy(LoyaltyTierDefinitionEntity, {
        tier: user.loyaltyTier,
      });
      const multiplier = tierDefinition?.earningMultiplier || 1.0;

      // For now, apply multiplier only to specific earning types. This can be configured.
      const applyMultiplier = [LoyaltyTransactionTypeEnum.BOOKING_COMMISSION_EARN].includes(type);

      const milesAwarded = applyMultiplier
        ? Math.floor(baseAmount * Number(multiplier))
        : Math.floor(baseAmount);

      if (milesAwarded <= 0 && type !== LoyaltyTransactionTypeEnum.ADJUSTMENT_SUBTRACT) {
        // Allow 0 for adjustments if needed
        this.logger.warn(
          `Attempted to award non-positive miles (${milesAwarded}) for type ${type}. Skipping transaction.`,
        );
        // Depending on strictness, could throw error or just return null/undefined
        throw new BadRequestException('Miles to award must be positive.');
      }

      const transaction = this.transactionRepository.create({
        userId,
        transactionType: type,
        milesAmount: milesAwarded,
        description,
        relatedBookingId: relatedEntity?.type === 'booking' ? relatedEntity.id : undefined,
        relatedReferralId: relatedEntity?.type === 'referral' ? relatedEntity.id : undefined,
        relatedSubscriptionId:
          relatedEntity?.type === 'subscription' ? relatedEntity.id : undefined,
        relatedReviewId: relatedEntity?.type === 'review' ? relatedEntity.id : undefined,
        relatedPartnerOfferId:
          relatedEntity?.type === 'partner_offer' ? relatedEntity.id : undefined,
      });

      const savedTransaction = await queryRunner.manager.save(transaction);

      user.loyaltyMilesBalance += milesAwarded;
      await queryRunner.manager.save(user);

      await this._updateUserTier(user, queryRunner.manager);

      await queryRunner.commitTransaction();
      this.logger.log(
        `Awarded ${milesAwarded} miles to user ${userId} for ${type}. New balance: ${user.loyaltyMilesBalance}`,
      );
      return savedTransaction;
    } catch (error) {
      await queryRunner.rollbackTransaction();
      this.logger.error(`Error awarding miles to user ${userId}: ${error.message}`, error.stack);
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Redeem points for a reward
   */
  async redeemMiles(
    userId: string,
    milesToRedeem: number,
    type: LoyaltyTransactionTypeEnum,
    description?: string,
    redemptionTarget?: any, // Could be an ID or object related to the redemption
  ): Promise<LoyaltyTransactionEntity> {
    const queryRunner = this.dataSource.createQueryRunner();
    await queryRunner.connect();
    await queryRunner.startTransaction();

    try {
      const user = await queryRunner.manager.findOneBy(UserEntity, { id: userId });
      if (!user) {
        throw new Error(`User not found: ${userId}`);
      }

      if (user.loyaltyMilesBalance < milesToRedeem) {
        throw new BadRequestException(
          `Insufficient miles. Required: ${milesToRedeem}, Available: ${user.loyaltyMilesBalance}`,
        );
      }

      const transaction = this.transactionRepository.create({
        userId,
        transactionType: type,
        milesAmount: -milesToRedeem, // Negative for redemption
        description,
        // Populate related fields based on redemptionTarget if applicable
      });

      const savedTransaction = await queryRunner.manager.save(transaction);

      user.loyaltyMilesBalance -= milesToRedeem;
      await queryRunner.manager.save(user);

      // No tier update needed for redemption, but could be if tiers had spending requirements

      await queryRunner.commitTransaction();
      this.logger.log(
        `Redeemed ${milesToRedeem} miles from user ${userId} for ${type}. New balance: ${user.loyaltyMilesBalance}`,
      );

      // Example: Interact with SubscriptionsService
      if (
        type === LoyaltyTransactionTypeEnum.PREMIUM_DISCOUNT_REDEEM &&
        redemptionTarget?.discountAmount
      ) {
        // this.subscriptionsService.applyLoyaltyDiscount(userId, redemptionTarget.discountAmount);
        this.logger.log(
          `Placeholder: Called SubscriptionsService.applyLoyaltyDiscount for user ${userId}`,
        );
      }

      return savedTransaction;
    } catch (error) {
      await queryRunner.rollbackTransaction();
      this.logger.error(`Error redeeming miles for user ${userId}: ${error.message}`, error.stack);
      throw error;
    } finally {
      await queryRunner.release();
    }
  }

  /**
   * Update user's loyalty tier based on their current miles balance
   */
  private async _updateUserTier(
    user: UserEntity,
    manager: import('typeorm').EntityManager,
  ): Promise<void> {
    const tiers = await manager.find(LoyaltyTierDefinitionEntity, {
      order: { minMilesRequired: 'DESC' },
    });
    if (!tiers.length) {
      this.logger.error('No loyalty tier definitions found. Cannot update user tier.');
      return;
    }

    let newTier = user.loyaltyTier;
    for (const tier of tiers) {
      if (user.loyaltyMilesBalance >= tier.minMilesRequired) {
        newTier = tier.tier;
        break;
      }
    }

    if (newTier !== user.loyaltyTier) {
      const oldTier = user.loyaltyTier;
      user.loyaltyTier = newTier;
      await manager.save(user);
      this.logger.log(`User ${user.id} tier updated from ${oldTier} to ${newTier}.`);
      // Optionally emit an event for tier upgrade
      // this.eventEmitter.emit('user.tier.upgraded', { userId: user.id, oldTier, newTier });
    }
  }

  /**
   * Get information about the next loyalty tier
   */
  private async getNextTierInfo(
    currentTierEnum: LoyaltyTierEnum,
    currentMiles: number,
  ): Promise<{ nextTier: string | null; milesNeeded: number | null }> {
    const tiers = await this.tierDefinitionRepository.find({ order: { minMilesRequired: 'ASC' } });
    const currentTierDefinition = tiers.find(t => t.tier === currentTierEnum);

    if (!currentTierDefinition) {
      this.logger.error(`Current tier definition not found for ${currentTierEnum}`);
      return { nextTier: null, milesNeeded: null };
    }

    const nextTierDefinition = tiers.find(
      t => t.minMilesRequired > currentTierDefinition.minMilesRequired,
    );

    if (!nextTierDefinition) {
      return { nextTier: null, milesNeeded: 0 }; // Already at highest tier
    }

    return {
      nextTier: nextTierDefinition.name,
      milesNeeded: Math.max(0, nextTierDefinition.minMilesRequired - currentMiles),
    };
  }

  async getTransactionsHistory(userId: string, page: number, limit: number): Promise<any> {
    try {
      const user = await this.userRepository.findOneBy({ id: userId });
      if (!user) {
        throw new Error(`User not found: ${userId}`);
      }
      const [transactions, total] = await this.transactionRepository.findAndCount({
        where: { userId },
        order: { createdAt: 'DESC' },
        skip: (page - 1) * limit,
        take: limit,
      });
      return { data: transactions, total, page, limit };
    } catch (error) {
      this.logger.error(
        `Error fetching transaction history for user ${userId}: ${error.message}`,
        error.stack,
      );
      throw error;
    }
  }

  async performDailyCheckIn(userId: string): Promise<LoyaltyTransactionEntity> {
    try {
      const user = await this.userRepository.findOneBy({ id: userId });
      if (!user) {
        throw new Error(`User not found: ${userId}`);
      }

      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const existingCheckIn = await this.transactionRepository.findOne({
        where: {
          userId,
          transactionType: LoyaltyTransactionTypeEnum.DAILY_CHECKIN_EARN,
          createdAt: MoreThanOrEqual(today),
        },
      });

      if (existingCheckIn) {
        throw new BadRequestException('Already checked in today.');
      }

      const dailyCheckInMiles = this.configService.get<number>('LOYALTY_DAILY_CHECKIN_MILES', 5);
      return this.awardMiles(
        userId,
        dailyCheckInMiles,
        LoyaltyTransactionTypeEnum.DAILY_CHECKIN_EARN,
        'Daily Check-in Bonus',
      );
    } catch (error) {
      this.logger.error(
        `Error performing daily check-in for user ${userId}: ${error.message}`,
        error.stack,
      );
      throw error;
    }
  }

  // Event Listeners
  @OnEvent('booking.commission.finalized')
  async handleBookingCommissionFinalized(payload: BookingCommissionFinalizedEvent) {
    const milesPerDollar = 1; // Configurable
    const milesToAward = payload.netCommissionAmount * milesPerDollar;
    await this.awardMiles(
      payload.userId,
      milesToAward,
      LoyaltyTransactionTypeEnum.BOOKING_COMMISSION_EARN,
      `Commission from booking ${payload.bookingId}`,
      { type: 'booking', id: payload.bookingId },
    );
  }

  @OnEvent('referral.used')
  async handleReferralUsed(payload: ReferralUsedEvent) {
    const referralBonusMiles = 250; // Configurable
    await this.awardMiles(
      payload.referrerUserId,
      referralBonusMiles,
      LoyaltyTransactionTypeEnum.REFERRAL_BONUS_EARN,
      `Bonus for referral ${payload.referralId}`,
      { type: 'referral', id: payload.referralId },
    );
  }

  @OnEvent('review.approved')
  async handleReviewApproved(payload: ReviewApprovedEvent) {
    const reviewAwardMiles = 50; // Configurable
    await this.awardMiles(
      payload.userId,
      reviewAwardMiles,
      LoyaltyTransactionTypeEnum.REVIEW_AWARD_EARN,
      `Award for approved review ${payload.reviewId}`,
      { type: 'review', id: payload.reviewId },
    );
  }

  @OnEvent('premium.subscription.activated')
  async handlePremiumSubscriptionActivated(payload: PremiumSubscriptionActivatedEvent) {
    const premiumBonusMiles = 500; // Configurable
    await this.awardMiles(
      payload.userId,
      premiumBonusMiles,
      LoyaltyTransactionTypeEnum.PREMIUM_SUBSCRIPTION_BONUS_EARN,
      `Bonus for premium subscription ${payload.subscriptionId}`,
      { type: 'subscription', id: payload.subscriptionId },
    );
  }

  @OnEvent('user.profile.completed')
  async handleUserProfileCompleted(payload: UserProfileCompletedEvent) {
    const profileCompletionMiles = 50; // Configurable
    // Check if already awarded to prevent multiple awards
    const existingTransaction = await this.transactionRepository.findOne({
      where: {
        userId: payload.userId,
        transactionType: LoyaltyTransactionTypeEnum.PROFILE_COMPLETION_EARN,
      },
    });
    if (!existingTransaction) {
      await this.awardMiles(
        payload.userId,
        profileCompletionMiles,
        LoyaltyTransactionTypeEnum.PROFILE_COMPLETION_EARN,
        'Bonus for profile completion',
      );
    }
  }

  @OnEvent('partner.offer.engaged')
  async handlePartnerOfferEngaged(payload: PartnerOfferEngagedEvent) {
    await this.awardMiles(
      payload.userId,
      payload.milesToAward,
      LoyaltyTransactionTypeEnum.PARTNER_OFFER_EARN,
      `Bonus for partner offer ${payload.offerId}`,
      { type: 'partner_offer', id: payload.offerId },
    );
  }
}
