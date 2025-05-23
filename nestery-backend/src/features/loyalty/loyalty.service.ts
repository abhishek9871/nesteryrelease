import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';
import { UsersService } from '../../users/users.service';

/**
 * Service for managing the loyalty program
 */
@Injectable()
export class LoyaltyService {
  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
    private readonly usersService: UsersService,
  ) {
    this.logger.setContext('LoyaltyService');
  }

  /**
   * Get loyalty program details for a user
   */
  async getLoyaltyDetails(userId: string): Promise<any> {
    try {
      this.logger.log(`Getting loyalty details for user ${userId}`);
      
      // Get user details
      const user = await this.usersService.findById(userId);
      
      // Calculate tier based on points
      const tier = this.calculateLoyaltyTier(user.loyaltyPoints);
      
      // Calculate benefits based on tier
      const benefits = this.getLoyaltyBenefits(tier);
      
      // Calculate points needed for next tier
      const nextTier = this.getNextLoyaltyTier(tier);
      const pointsForNextTier = nextTier ? this.getPointsRequiredForTier(nextTier) : null;
      const pointsNeededForNextTier = pointsForNextTier ? Math.max(0, pointsForNextTier - user.loyaltyPoints) : null;
      
      return {
        userId,
        loyaltyPoints: user.loyaltyPoints,
        isPremium: user.isPremium,
        tier,
        benefits,
        nextTier,
        pointsNeededForNextTier,
        pointHistory: await this.getLoyaltyPointHistory(userId),
      };
    } catch (error) {
      this.logger.error(`Error getting loyalty details: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Add loyalty points to a user
   */
  async addLoyaltyPoints(userId: string, points: number, reason: string): Promise<any> {
    try {
      this.logger.log(`Adding ${points} loyalty points to user ${userId} for ${reason}`);
      
      // Update user's loyalty points
      const user = await this.usersService.addLoyaltyPoints(userId, points);
      
      // Record point transaction
      await this.recordPointTransaction(userId, points, reason);
      
      // Check if user has reached a new tier
      const oldTier = this.calculateLoyaltyTier(user.loyaltyPoints - points);
      const newTier = this.calculateLoyaltyTier(user.loyaltyPoints);
      
      // If tier has changed, trigger tier upgrade event
      if (newTier !== oldTier) {
        await this.handleTierUpgrade(userId, oldTier, newTier);
      }
      
      return {
        userId,
        loyaltyPoints: user.loyaltyPoints,
        pointsAdded: points,
        reason,
        tier: newTier,
      };
    } catch (error) {
      this.logger.error(`Error adding loyalty points: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Redeem loyalty points for a reward
   */
  async redeemLoyaltyPoints(userId: string, points: number, rewardId: string): Promise<any> {
    try {
      this.logger.log(`Redeeming ${points} loyalty points for reward ${rewardId} by user ${userId}`);
      
      // Get user details
      const user = await this.usersService.findById(userId);
      
      // Check if user has enough points
      if (user.loyaltyPoints < points) {
        throw new Error('Insufficient loyalty points');
      }
      
      // Get reward details
      const reward = await this.getRewardById(rewardId);
      
      // Check if reward is available
      if (!reward.isAvailable) {
        throw new Error('Reward is not available');
      }
      
      // Check if points match reward cost
      if (reward.pointsCost !== points) {
        throw new Error('Points do not match reward cost');
      }
      
      // Deduct points from user
      await this.usersService.addLoyaltyPoints(userId, -points);
      
      // Record redemption
      await this.recordRedemption(userId, points, rewardId);
      
      return {
        userId,
        loyaltyPoints: user.loyaltyPoints - points,
        pointsRedeemed: points,
        reward,
      };
    } catch (error) {
      this.logger.error(`Error redeeming loyalty points: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Get available rewards for a user
   */
  async getAvailableRewards(userId: string): Promise<any[]> {
    try {
      this.logger.log(`Getting available rewards for user ${userId}`);
      
      // Get user details
      const user = await this.usersService.findById(userId);
      
      // Get all rewards
      const allRewards = await this.getAllRewards();
      
      // Filter rewards based on user's tier and points
      const availableRewards = allRewards.filter(reward => {
        // Check if user has enough points
        if (user.loyaltyPoints < reward.pointsCost) {
          return false;
        }
        
        // Check if reward is tier-restricted and user meets tier requirement
        if (reward.requiredTier && this.getTierValue(this.calculateLoyaltyTier(user.loyaltyPoints)) < this.getTierValue(reward.requiredTier)) {
          return false;
        }
        
        return reward.isAvailable;
      });
      
      return availableRewards;
    } catch (error) {
      this.logger.error(`Error getting available rewards: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Calculate loyalty tier based on points
   */
  private calculateLoyaltyTier(points: number): string {
    if (points >= 5000) {
      return 'platinum';
    } else if (points >= 2000) {
      return 'gold';
    } else if (points >= 500) {
      return 'silver';
    } else {
      return 'bronze';
    }
  }

  /**
   * Get next loyalty tier
   */
  private getNextLoyaltyTier(currentTier: string): string | null {
    const tiers = ['bronze', 'silver', 'gold', 'platinum'];
    const currentIndex = tiers.indexOf(currentTier);
    
    if (currentIndex < tiers.length - 1) {
      return tiers[currentIndex + 1];
    }
    
    return null;
  }

  /**
   * Get points required for a tier
   */
  private getPointsRequiredForTier(tier: string): number {
    switch (tier) {
      case 'bronze':
        return 0;
      case 'silver':
        return 500;
      case 'gold':
        return 2000;
      case 'platinum':
        return 5000;
      default:
        return 0;
    }
  }

  /**
   * Get tier value for comparison
   */
  private getTierValue(tier: string): number {
    switch (tier) {
      case 'bronze':
        return 1;
      case 'silver':
        return 2;
      case 'gold':
        return 3;
      case 'platinum':
        return 4;
      default:
        return 0;
    }
  }

  /**
   * Get loyalty benefits based on tier
   */
  private getLoyaltyBenefits(tier: string): any[] {
    const benefits = [];
    
    // Base benefits for all tiers
    benefits.push({
      id: 'points_earning',
      name: 'Points Earning',
      description: 'Earn 1 point for every $1 spent on bookings',
    });
    
    // Tier-specific benefits
    switch (tier) {
      case 'platinum':
        benefits.push({
          id: 'premium_discount',
          name: 'Premium Discount',
          description: '15% discount on all bookings',
        });
        benefits.push({
          id: 'priority_support',
          name: 'Priority Support',
          description: 'Priority customer support with dedicated agent',
        });
        benefits.push({
          id: 'free_upgrades',
          name: 'Free Upgrades',
          description: 'Complimentary room upgrades when available',
        });
        benefits.push({
          id: 'late_checkout',
          name: 'Late Checkout',
          description: 'Guaranteed late checkout until 2 PM',
        });
        // Fall through to include gold benefits
        
      case 'gold':
        if (tier === 'gold') {
          benefits.push({
            id: 'premium_discount',
            name: 'Premium Discount',
            description: '10% discount on all bookings',
          });
          benefits.push({
            id: 'priority_support',
            name: 'Priority Support',
            description: 'Priority customer support',
          });
        }
        benefits.push({
          id: 'bonus_points',
          name: 'Bonus Points',
          description: '25% bonus points on all bookings',
        });
        benefits.push({
          id: 'early_access',
          name: 'Early Access',
          description: 'Early access to promotions and deals',
        });
        // Fall through to include silver benefits
        
      case 'silver':
        if (tier === 'silver') {
          benefits.push({
            id: 'premium_discount',
            name: 'Premium Discount',
            description: '5% discount on all bookings',
          });
          benefits.push({
            id: 'bonus_points',
            name: 'Bonus Points',
            description: '10% bonus points on all bookings',
          });
        }
        benefits.push({
          id: 'free_wifi',
          name: 'Free WiFi',
          description: 'Free WiFi at participating properties',
        });
        break;
        
      default: // bronze
        // No additional benefits for bronze tier
        break;
    }
    
    return benefits;
  }

  /**
   * Handle tier upgrade event
   */
  private async handleTierUpgrade(userId: string, oldTier: string, newTier: string): Promise<void> {
    this.logger.log(`User ${userId} upgraded from ${oldTier} to ${newTier} tier`);
    
    // In a real implementation, this would trigger notifications, emails, etc.
    // For this example, we're just logging the event
    
    // If user reached gold or platinum, enable premium status
    if (newTier === 'gold' || newTier === 'platinum') {
      await this.usersService.updatePremiumStatus(userId, true);
    }
  }

  /**
   * Record loyalty point transaction
   * This is a mock implementation for demonstration purposes
   */
  private async recordPointTransaction(userId: string, points: number, reason: string): Promise<void> {
    // In a real implementation, this would save to a database
    this.logger.log(`Recorded ${points} points for user ${userId}: ${reason}`);
  }

  /**
   * Record loyalty point redemption
   * This is a mock implementation for demonstration purposes
   */
  private async recordRedemption(userId: string, points: number, rewardId: string): Promise<void> {
    // In a real implementation, this would save to a database
    this.logger.log(`Recorded redemption of ${points} points for reward ${rewardId} by user ${userId}`);
  }

  /**
   * Get loyalty point history for a user
   * This is a mock implementation for demonstration purposes
   */
  private async getLoyaltyPointHistory(userId: string): Promise<any[]> {
    // In a real implementation, this would query the database
    return [
      {
        id: '1',
        date: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000).toISOString(),
        points: 100,
        type: 'earn',
        reason: 'Booking completion',
        balance: 100,
      },
      {
        id: '2',
        date: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000).toISOString(),
        points: 50,
        type: 'earn',
        reason: 'Review submission',
        balance: 150,
      },
      {
        id: '3',
        date: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000).toISOString(),
        points: -100,
        type: 'redeem',
        reason: 'Discount coupon',
        balance: 50,
      },
      {
        id: '4',
        date: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000).toISOString(),
        points: 200,
        type: 'earn',
        reason: 'Booking completion',
        balance: 250,
      },
    ];
  }

  /**
   * Get reward by ID
   * This is a mock implementation for demonstration purposes
   */
  private async getRewardById(rewardId: string): Promise<any> {
    const allRewards = await this.getAllRewards();
    const reward = allRewards.find(r => r.id === rewardId);
    
    if (!reward) {
      throw new Error(`Reward with ID ${rewardId} not found`);
    }
    
    return reward;
  }

  /**
   * Get all rewards
   * This is a mock implementation for demonstration purposes
   */
  private async getAllRewards(): Promise<any[]> {
    return [
      {
        id: 'discount_10',
        name: '10% Discount Coupon',
        description: 'Get 10% off your next booking',
        pointsCost: 100,
        isAvailable: true,
        requiredTier: null,
        expiryDays: 30,
      },
      {
        id: 'discount_20',
        name: '20% Discount Coupon',
        description: 'Get 20% off your next booking',
        pointsCost: 200,
        isAvailable: true,
        requiredTier: 'silver',
        expiryDays: 60,
      },
      {
        id: 'free_night',
        name: 'Free Night Stay',
        description: 'Get one night free on a booking of 3+ nights',
        pointsCost: 500,
        isAvailable: true,
        requiredTier: 'gold',
        expiryDays: 90,
      },
      {
        id: 'airport_transfer',
        name: 'Free Airport Transfer',
        description: 'Free airport transfer for your next booking',
        pointsCost: 300,
        isAvailable: true,
        requiredTier: 'silver',
        expiryDays: 60,
      },
      {
        id: 'premium_upgrade',
        name: 'Premium Status Upgrade',
        description: 'Upgrade to Premium status for 3 months',
        pointsCost: 1000,
        isAvailable: true,
        requiredTier: 'gold',
        expiryDays: null,
      },
    ];
  }
}
