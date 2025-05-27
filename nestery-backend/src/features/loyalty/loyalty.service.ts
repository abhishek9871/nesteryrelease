import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { UserEntity } from '../../users/entities/user.entity';
import { BookingEntity } from '../../bookings/entities/booking.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

@Injectable()
export class LoyaltyService {
  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @InjectRepository(BookingEntity)
    private readonly bookingRepository: Repository<BookingEntity>,
  ) {
    this.logger.setContext('LoyaltyService');
  }

  /**
   * Get loyalty status and points for a user
   */
  async getLoyaltyStatus(userId: string): Promise<{
    tier: string;
    points: number;
    nextTier: string;
    pointsToNextTier: number;
    benefits: string[];
    history: Array<{ date: Date; description: string; points: number }>;
  }> {
    try {
      this.logger.debug(`Getting loyalty status for user: ${userId}`);

      // Note: User's booking history could be used for additional loyalty calculations

      // Calculate total points
      const totalPoints = await this.calculateTotalPoints(userId);

      // Determine loyalty tier
      const tier = this.determineLoyaltyTier(totalPoints);

      // Get next tier and points needed
      const nextTierInfo = this.getNextTierInfo(tier, totalPoints);

      // Get tier benefits
      const benefits = this.getTierBenefits(tier);

      // Get point history
      const history = await this.getPointHistory(userId);

      return {
        tier,
        points: totalPoints,
        nextTier: nextTierInfo.nextTier,
        pointsToNextTier: nextTierInfo.pointsNeeded,
        benefits,
        history,
      };
    } catch (error) {
      this.logger.error(`Error getting loyalty status: ${error.message}`, error.stack);
      throw error;
    }
  }

  /**
   * Award points for a completed booking
   */
  async awardPointsForBooking(bookingId: string): Promise<{
    awarded: number;
    newTotal: number;
    tier: string;
  }> {
    try {
      this.logger.debug(`Awarding points for booking: ${bookingId}`);

      // Get booking details
      const booking = await this.bookingRepository.findOne({
        where: { id: bookingId },
        relations: ['user', 'property'],
      });

      if (!booking) {
        throw new Error(`Booking not found: ${bookingId}`);
      }

      if (booking.status !== 'completed') {
        throw new Error(`Cannot award points for non-completed booking: ${bookingId}`);
      }

      // Calculate points to award
      const pointsAwarded = await this.calculateBookingPoints(booking);

      // Update user's points
      const user = booking.user;
      const currentPoints = user.loyaltyPoints || 0;
      const newTotal = currentPoints + pointsAwarded;

      await this.userRepository.update(user.id, {
        loyaltyPoints: newTotal,
      });

      // Record point history
      await this.recordPointTransaction(
        user.id,
        pointsAwarded,
        `Booking completed: ${booking.property.name}`,
        booking.id,
      );

      // Determine new tier
      const newTier = this.determineLoyaltyTier(newTotal);

      // Check if user leveled up
      const oldTier = this.determineLoyaltyTier(currentPoints);
      if (newTier !== oldTier) {
        await this.handleTierUpgrade(user.id, oldTier, newTier);
      }

      return {
        awarded: pointsAwarded,
        newTotal,
        tier: newTier,
      };
    } catch (error) {
      this.logger.error(`Error awarding booking points: ${error.message}`, error.stack);
      throw error;
    }
  }

  /**
   * Redeem points for a reward
   */
  async redeemPoints(
    userId: string,
    rewardId: string,
    pointsRequired: number,
  ): Promise<{
    success: boolean;
    remainingPoints: number;
    reward: {
      id: string;
      name: string;
      description: string;
      pointsRequired: number;
    };
  }> {
    try {
      this.logger.debug(`Redeeming points for user: ${userId}, reward: ${rewardId}`);

      // Get user's current points
      const user = await this.userRepository.findOne({
        where: { id: userId },
      });

      if (!user) {
        throw new Error(`User not found: ${userId}`);
      }

      const currentPoints = user.loyaltyPoints || 0;

      if (currentPoints < pointsRequired) {
        throw new Error(
          `Insufficient points. Required: ${pointsRequired}, Available: ${currentPoints}`,
        );
      }

      // Get reward details (in a real app, this would come from a rewards repository)
      const reward = this.getRewardById(rewardId);

      if (!reward) {
        throw new Error(`Reward not found: ${rewardId}`);
      }

      if (reward.pointsRequired !== pointsRequired) {
        throw new Error(
          `Points mismatch. Expected: ${reward.pointsRequired}, Received: ${pointsRequired}`,
        );
      }

      // Deduct points
      const remainingPoints = currentPoints - pointsRequired;
      await this.userRepository.update(userId, {
        loyaltyPoints: remainingPoints,
      });

      // Record point transaction
      await this.recordPointTransaction(
        userId,
        -pointsRequired,
        `Redeemed reward: ${reward.name}`,
        rewardId,
      );

      // In a real app, we would also create a reward redemption record
      // and trigger any necessary fulfillment processes

      return {
        success: true,
        remainingPoints,
        reward,
      };
    } catch (error) {
      this.logger.error(`Error redeeming points: ${error.message}`, error.stack);
      throw error;
    }
  }

  /**
   * Get available rewards for a user
   */
  async getAvailableRewards(userId: string): Promise<
    Array<{
      id: string;
      name: string;
      description: string;
      pointsRequired: number;
      available: boolean;
    }>
  > {
    try {
      this.logger.debug(`Getting available rewards for user: ${userId}`);

      // Get user's current points
      const user = await this.userRepository.findOne({
        where: { id: userId },
      });

      if (!user) {
        throw new Error(`User not found: ${userId}`);
      }

      const currentPoints = user.loyaltyPoints || 0;

      // Get all rewards (in a real app, this would come from a rewards repository)
      const allRewards = [
        {
          id: 'reward1',
          name: 'Free Night Stay',
          description: 'Redeem for a free night at any property up to $200 value',
          pointsRequired: 2000,
        },
        {
          id: 'reward2',
          name: 'Room Upgrade',
          description: 'Guaranteed room upgrade on your next booking',
          pointsRequired: 500,
        },
        {
          id: 'reward3',
          name: 'Airport Transfer',
          description: 'Free airport transfer for your next booking',
          pointsRequired: 300,
        },
      ];

      // Mark rewards as available based on user's points
      const availableRewards = allRewards.map(reward => ({
        ...reward,
        available: currentPoints >= reward.pointsRequired,
      }));

      return availableRewards;
    } catch (error) {
      this.logger.error(`Error getting available rewards: ${error.message}`, error.stack);
      throw new Error(`Failed to get available rewards: ${error.message}`);
    }
  }

  /**
   * Calculate total loyalty points for a user
   */
  private async calculateTotalPoints(userId: string): Promise<number> {
    try {
      const user = await this.userRepository.findOne({
        where: { id: userId },
      });

      if (!user) {
        throw new Error(`User not found: ${userId}`);
      }

      return user.loyaltyPoints || 0;
    } catch (error) {
      this.logger.error(`Error calculating total points: ${error.message}`, error.stack);
      throw error;
    }
  }

  /**
   * Calculate points to award for a booking
   */
  private async calculateBookingPoints(booking: BookingEntity): Promise<number> {
    let points = 0;

    // Base points for any booking
    points += 100;

    // Points based on booking total
    if (booking.totalPrice) {
      points += Math.floor(booking.totalPrice / 10); // 1 point per $10 spent
    }

    // Bonus points for longer stays
    const stayDuration = this.calculateStayDuration(booking.checkInDate, booking.checkOutDate);
    if (stayDuration >= 7) {
      points += 200; // Bonus for stays of a week or longer
    } else if (stayDuration >= 3) {
      points += 50; // Smaller bonus for stays of 3-6 days
    }

    // Bonus points for booking premium properties
    // Note: rating field was moved to metadata object
    const rating = (booking.property?.metadata as any)?.rating || 0;
    if (booking.property && rating && rating >= 4.5) {
      points += 50; // Bonus for premium properties
    }

    return points;
  }

  /**
   * Calculate duration of stay in days
   */
  private calculateStayDuration(checkIn: Date, checkOut: Date): number {
    const checkInDate = new Date(checkIn);
    const checkOutDate = new Date(checkOut);
    const diffTime = Math.abs(checkOutDate.getTime() - checkInDate.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
  }

  /**
   * Determine loyalty tier based on points
   */
  private determineLoyaltyTier(points: number): string {
    if (points >= 5000) {
      return 'Platinum';
    } else if (points >= 2000) {
      return 'Gold';
    } else if (points >= 500) {
      return 'Silver';
    } else {
      return 'Bronze';
    }
  }

  /**
   * Get information about the next tier
   */
  private getNextTierInfo(
    currentTier: string,
    currentPoints: number,
  ): {
    nextTier: string;
    pointsNeeded: number;
  } {
    switch (currentTier) {
      case 'Bronze':
        return {
          nextTier: 'Silver',
          pointsNeeded: 500 - currentPoints,
        };
      case 'Silver':
        return {
          nextTier: 'Gold',
          pointsNeeded: 2000 - currentPoints,
        };
      case 'Gold':
        return {
          nextTier: 'Platinum',
          pointsNeeded: 5000 - currentPoints,
        };
      case 'Platinum':
        return {
          nextTier: 'Platinum',
          pointsNeeded: 0,
        };
      default:
        return {
          nextTier: 'Silver',
          pointsNeeded: 500 - currentPoints,
        };
    }
  }

  /**
   * Get benefits for a loyalty tier
   */
  private getTierBenefits(tier: string): string[] {
    switch (tier) {
      case 'Bronze':
        return ['Earn 1 point per $10 spent', 'Access to member-only deals'];
      case 'Silver':
        return [
          'Earn 1.2 points per $10 spent',
          'Access to member-only deals',
          'Priority customer service',
          'Late checkout when available',
        ];
      case 'Gold':
        return [
          'Earn 1.5 points per $10 spent',
          'Access to member-only deals',
          'Priority customer service',
          'Late checkout when available',
          'Room upgrades when available',
          '10% discount on bookings',
        ];
      case 'Platinum':
        return [
          'Earn 2 points per $10 spent',
          'Access to member-only deals',
          'Priority customer service',
          'Guaranteed late checkout',
          'Room upgrades when available',
          '15% discount on bookings',
          'Free welcome amenities',
          'Dedicated concierge service',
        ];
      default:
        return ['Earn 1 point per $10 spent'];
    }
  }

  /**
   * Get point history for a user
   */
  private async getPointHistory(
    _userId: string,
  ): Promise<Array<{ date: Date; description: string; points: number }>> {
    // In a real app, this would come from a point transaction repository
    // For now, we'll return mock data
    return [
      {
        date: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000),
        description: 'Booking completed: Luxury Beach Villa',
        points: 250,
      },
      {
        date: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000),
        description: 'Booking completed: Mountain Retreat Cabin',
        points: 180,
      },
      {
        date: new Date(Date.now() - 180 * 24 * 60 * 60 * 1000),
        description: 'Welcome bonus',
        points: 100,
      },
    ];
  }

  /**
   * Record a point transaction
   */
  private async recordPointTransaction(
    userId: string,
    points: number,
    description: string,
    referenceId?: string,
  ): Promise<void> {
    // In a real app, this would create a record in a point transaction repository
    this.logger.debug(
      `Recording point transaction: User ${userId}, Points ${points}, Description: ${description}`,
    );

    // For now, we'll just log it
    this.logger.debug(
      `Point transaction recorded: ${JSON.stringify({
        userId,
        points,
        description,
        referenceId,
        date: new Date(),
      })}`,
    );
  }

  /**
   * Handle tier upgrade
   */
  private async handleTierUpgrade(userId: string, oldTier: string, newTier: string): Promise<void> {
    this.logger.debug(`User ${userId} upgraded from ${oldTier} to ${newTier}`);

    // In a real app, we might:
    // 1. Send a congratulatory email
    // 2. Create a notification
    // 3. Award a tier upgrade bonus
    // 4. Update user's tier in the database

    // For now, we'll just log it
    this.logger.log(
      `Tier upgrade recorded: ${JSON.stringify({
        userId,
        oldTier,
        newTier,
        date: new Date(),
      })}`,
    );
  }

  /**
   * Get reward by ID
   */
  private getRewardById(rewardId: string): {
    id: string;
    name: string;
    description: string;
    pointsRequired: number;
  } | null {
    // In a real app, this would come from a rewards repository
    const rewards = [
      {
        id: 'reward1',
        name: 'Free Night Stay',
        description: 'Redeem for a free night at any property up to $200 value',
        pointsRequired: 2000,
      },
      {
        id: 'reward2',
        name: 'Room Upgrade',
        description: 'Guaranteed room upgrade on your next booking',
        pointsRequired: 500,
      },
      {
        id: 'reward3',
        name: 'Airport Transfer',
        description: 'Free airport transfer for your next booking',
        pointsRequired: 300,
      },
    ];

    return rewards.find(reward => reward.id === rewardId) || null;
  }
}
