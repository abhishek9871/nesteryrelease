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

      // Get user's booking history
      const userBookings = await this.bookingRepository.find({
        where: { user: { id: userId } },
        relations: ['property'],
        order: { createdAt: 'DESC' },
      });

      // Calculate total points
      const totalPoints = await this.calculateTotalPoints(userId);

      // Determine loyalty tier
      const tier = this.determineLoyaltyTier(totalPoints);
      
      // Get next tier and points needed
      const nextTierInfo = this.getNextTierInfo(tier, totalPoints);

      // Get tier benefits
      const benefits = this.getTierBenefits(tier);

      // Get points history
      const history = await this.getPointsHistory(userId);

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
      throw new Error(`Failed to get loyalty status: ${error.message}`);
    }
  }

  /**
   * Award points for a new booking
   */
  async awardPointsForBooking(bookingId: string): Promise<{
    pointsAwarded: number;
    newTotal: number;
    tier: string;
    tierChanged: boolean;
  }> {
    try {
      this.logger.debug(`Awarding points for booking: ${bookingId}`);

      // Get booking details
      const booking = await this.bookingRepository.findOne({
        where: { id: bookingId },
        relations: ['user', 'property'],
      });

      if (!booking) {
        throw new Error(`Booking with ID ${bookingId} not found`);
      }

      // Calculate points to award
      const pointsAwarded = this.calculatePointsForBooking(booking);

      // Get current points and tier
      const currentPoints = await this.calculateTotalPoints(booking.user.id);
      const currentTier = this.determineLoyaltyTier(currentPoints);

      // Add points to user's loyalty record
      await this.addPointsToHistory(booking.user.id, pointsAwarded, `Booking at ${booking.property.name}`, booking.id);

      // Calculate new total and tier
      const newTotal = currentPoints + pointsAwarded;
      const newTier = this.determineLoyaltyTier(newTotal);

      return {
        pointsAwarded,
        newTotal,
        tier: newTier,
        tierChanged: currentTier !== newTier,
      };
    } catch (error) {
      this.logger.error(`Error awarding points for booking: ${error.message}`, error.stack);
      throw new Error(`Failed to award points for booking: ${error.message}`);
    }
  }

  /**
   * Redeem points for a reward
   */
  async redeemPoints(userId: string, rewardId: string, pointsCost: number): Promise<{
    success: boolean;
    remainingPoints: number;
    reward: {
      id: string;
      name: string;
      description: string;
      pointsCost: number;
    };
  }> {
    try {
      this.logger.debug(`Redeeming points for user: ${userId}, reward: ${rewardId}`);

      // Get current points
      const currentPoints = await this.calculateTotalPoints(userId);

      // Check if user has enough points
      if (currentPoints < pointsCost) {
        throw new Error(`Insufficient points. Required: ${pointsCost}, Available: ${currentPoints}`);
      }

      // Get reward details (in a real implementation, this would come from a rewards database)
      const reward = this.getRewardDetails(rewardId);

      // Deduct points from user's loyalty record
      await this.addPointsToHistory(userId, -pointsCost, `Redeemed for ${reward.name}`, null);

      // Calculate remaining points
      const remainingPoints = currentPoints - pointsCost;

      return {
        success: true,
        remainingPoints,
        reward,
      };
    } catch (error) {
      this.logger.error(`Error redeeming points: ${error.message}`, error.stack);
      throw new Error(`Failed to redeem points: ${error.message}`);
    }
  }

  /**
   * Get available rewards for a user
   */
  async getAvailableRewards(userId: string): Promise<Array<{
    id: string;
    name: string;
    description: string;
    pointsCost: number;
    canRedeem: boolean;
  }>> {
    try {
      this.logger.debug(`Getting available rewards for user: ${userId}`);

      // Get current points
      const currentPoints = await this.calculateTotalPoints(userId);

      // Get all rewards (in a real implementation, this would come from a rewards database)
      const allRewards = this.getAllRewards();

      // Mark which rewards the user can redeem
      const availableRewards = allRewards.map(reward => ({
        ...reward,
        canRedeem: currentPoints >= reward.pointsCost,
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
      // In a real implementation, this would query a loyalty_points table
      // For now, we'll simulate by calculating from booking history
      
      // Get all bookings for the user
      const bookings = await this.bookingRepository.find({
        where: { user: { id: userId } },
        relations: ['property'],
      });

      // Calculate points for each booking
      let totalPoints = 0;
      for (const booking of bookings) {
        totalPoints += this.calculatePointsForBooking(booking);
      }

      // Get points from other activities (simulated)
      const otherPoints = await this.getOtherPoints(userId);

      return totalPoints + otherPoints;
    } catch (error) {
      this.logger.error(`Error calculating total points: ${error.message}`, error.stack);
      return 0;
    }
  }

  /**
   * Calculate points for a booking
   */
  private calculatePointsForBooking(booking: BookingEntity): number {
    // Base points: 10 points per night
    const checkInDate = new Date(booking.checkInDate);
    const checkOutDate = new Date(booking.checkOutDate);
    const nights = Math.ceil((checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60 * 24));
    let points = nights * 10;

    // Additional points based on booking amount
    if (booking.totalAmount) {
      points += Math.floor(booking.totalAmount / 10); // 1 point per $10 spent
    }

    // Bonus for high-rated properties
    if (booking.property && booking.property.rating >= 4.5) {
      points += 20; // Bonus for excellent properties
    }

    return points;
  }

  /**
   * Get points from other activities (simulated)
   */
  private async getOtherPoints(userId: string): Promise<number> {
    // In a real implementation, this would query various activity records
    // For now, we'll return a random number to simulate
    return Math.floor(Math.random() * 50);
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
  private getNextTierInfo(currentTier: string, currentPoints: number): { nextTier: string; pointsNeeded: number } {
    switch (currentTier) {
      case 'Bronze':
        return { nextTier: 'Silver', pointsNeeded: 500 - currentPoints };
      case 'Silver':
        return { nextTier: 'Gold', pointsNeeded: 2000 - currentPoints };
      case 'Gold':
        return { nextTier: 'Platinum', pointsNeeded: 5000 - currentPoints };
      case 'Platinum':
        return { nextTier: 'Platinum+', pointsNeeded: 10000 - currentPoints };
      default:
        return { nextTier: 'Silver', pointsNeeded: 500 - currentPoints };
    }
  }

  /**
   * Get benefits for a loyalty tier
   */
  private getTierBenefits(tier: string): string[] {
    switch (tier) {
      case 'Bronze':
        return [
          'Earn 10 points per night',
          'Member-only rates',
          'Free Wi-Fi',
        ];
      case 'Silver':
        return [
          'All Bronze benefits',
          'Early check-in when available',
          '10% discount on selected properties',
          'Priority customer service',
        ];
      case 'Gold':
        return [
          'All Silver benefits',
          'Room upgrades when available',
          '15% discount on selected properties',
          'Late checkout when available',
          'Welcome gift on arrival',
        ];
      case 'Platinum':
        return [
          'All Gold benefits',
          'Guaranteed room availability',
          '20% discount on selected properties',
          'Free breakfast at participating properties',
          'Dedicated concierge service',
          'Annual free night certificate',
        ];
      default:
        return ['Earn 10 points per night'];
    }
  }

  /**
   * Add points to user's history
   */
  private async addPointsToHistory(
    userId: string,
    points: number,
    description: string,
    bookingId: string | null
  ): Promise<void> {
    // In a real implementation, this would insert a record into a loyalty_points_history table
    // For now, we'll just log it
    this.logger.debug(`Added ${points} points to user ${userId} for "${description}"`);
  }

  /**
   * Get points history for a user
   */
  private async getPointsHistory(
    userId: string
  ): Promise<Array<{ date: Date; description: string; points: number }>> {
    // In a real implementation, this would query a loyalty_points_history table
    // For now, we'll generate some sample history
    
    // Get user's bookings for real history items
    const bookings = await this.bookingRepository.find({
      where: { user: { id: userId } },
      relations: ['property'],
      order: { createdAt: 'DESC' },
      take: 10,
    });

    const history = bookings.map(booking => ({
      date: booking.createdAt,
      description: `Booking at ${booking.property.name}`,
      points: this.calculatePointsForBooking(booking),
    }));

    // Add some simulated redemptions
    if (history.length > 0) {
      history.push({
        date: new Date(Date.now() - 15 * 24 * 60 * 60 * 1000), // 15 days ago
        description: 'Redeemed for $50 travel credit',
        points: -500,
      });
    }

    return history;
  }

  /**
   * Get reward details
   */
  private getRewardDetails(rewardId: string): {
    id: string;
    name: string;
    description: string;
    pointsCost: number;
  } {
    // In a real implementation, this would query a rewards database
    // For now, we'll return hardcoded rewards
    const allRewards = this.getAllRewards();
    const reward = allRewards.find(r => r.id === rewardId);
    
    if (!reward) {
      throw new Error(`Reward with ID ${rewardId} not found`);
    }
    
    return reward;
  }

  /**
   * Get all available rewards
   */
  private getAllRewards(): Array<{
    id: string;
    name: string;
    description: string;
    pointsCost: number;
  }> {
    // In a real implementation, this would query a rewards database
    // For now, we'll return hardcoded rewards
    return [
      {
        id: 'reward1',
        name: '$25 Travel Credit',
        description: 'Get $25 off your next booking',
        pointsCost: 250,
      },
      {
        id: 'reward2',
        name: '$50 Travel Credit',
        description: 'Get $50 off your next booking',
        pointsCost: 500,
      },
      {
        id: 'reward3',
        name: 'Free Night Certificate',
        description: 'One free night at participating properties (up to $200 value)',
        pointsCost: 2000,
      },
      {
        id: 'reward4',
        name: 'Airport Lounge Access',
        description: 'One-time access to airport lounges worldwide',
        pointsCost: 1000,
      },
      {
        id: 'reward5',
        name: 'Room Upgrade Certificate',
        description: 'Guaranteed room upgrade on your next stay',
        pointsCost: 750,
      },
    ];
  }
}
