import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { PropertyEntity } from '../../properties/entities/property.entity';
import { UserEntity } from '../../users/entities/user.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

@Injectable()
export class SocialSharingService {
  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    @InjectRepository(PropertyEntity)
    private readonly propertyRepository: Repository<PropertyEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
  ) {
    this.logger.setContext('SocialSharingService');
  }

  /**
   * Generate shareable content for a property
   */
  async generateShareableContent(propertyId: string, platform: string): Promise<{
    title: string;
    description: string;
    imageUrl: string;
    shareUrl: string;
    hashtags: string[];
  }> {
    try {
      this.logger.debug(`Generating shareable content for property ${propertyId} on ${platform}`);

      // Get property details
      const property = await this.propertyRepository.findOne({
        where: { id: propertyId },
      });

      if (!property) {
        throw new Error(`Property with ID ${propertyId} not found`);
      }

      // Generate base content
      const baseContent = {
        title: `Discover ${property.name} in ${property.city}`,
        description: this.truncateDescription(property.description, platform),
        imageUrl: property.thumbnailImage || property.images?.[0] || '',
        shareUrl: `${this.configService.get<string>('APP_URL')}/properties/${propertyId}?utm_source=${platform}&utm_medium=social&utm_campaign=share`,
        hashtags: this.generateHashtags(property),
      };

      // Customize content based on platform
      return this.customizeForPlatform(baseContent, platform, property);
    } catch (error) {
      this.logger.error(`Error generating shareable content: ${error.message}`, error.stack);
      throw new Error(`Failed to generate shareable content: ${error.message}`);
    }
  }

  /**
   * Track social share event
   */
  async trackSocialShare(params: {
    userId: string;
    propertyId: string;
    platform: string;
    shareUrl: string;
  }): Promise<{
    success: boolean;
    shareId: string;
  }> {
    try {
      this.logger.debug(`Tracking social share for user ${params.userId}, property ${params.propertyId} on ${params.platform}`);

      // In a real implementation, this would insert a record into a social_shares table
      // For now, we'll just log it and return a simulated response
      
      const shareId = `share_${Date.now()}_${Math.floor(Math.random() * 1000)}`;
      
      return {
        success: true,
        shareId,
      };
    } catch (error) {
      this.logger.error(`Error tracking social share: ${error.message}`, error.stack);
      throw new Error(`Failed to track social share: ${error.message}`);
    }
  }

  /**
   * Get referral link for a user
   */
  async getReferralLink(userId: string): Promise<{
    referralCode: string;
    referralUrl: string;
    rewards: {
      referrerReward: string;
      refereeReward: string;
    };
  }> {
    try {
      this.logger.debug(`Getting referral link for user ${userId}`);

      // Get user details
      const user = await this.userRepository.findOne({
        where: { id: userId },
      });

      if (!user) {
        throw new Error(`User with ID ${userId} not found`);
      }

      // Generate or retrieve referral code
      const referralCode = user.referralCode || this.generateReferralCode(user);

      // If user doesn't have a referral code yet, save it
      if (!user.referralCode) {
        user.referralCode = referralCode;
        await this.userRepository.save(user);
      }

      return {
        referralCode,
        referralUrl: `${this.configService.get<string>('APP_URL')}/signup?ref=${referralCode}`,
        rewards: {
          referrerReward: '$25 credit after your friend's first booking',
          refereeReward: '$25 off your first booking',
        },
      };
    } catch (error) {
      this.logger.error(`Error getting referral link: ${error.message}`, error.stack);
      throw new Error(`Failed to get referral link: ${error.message}`);
    }
  }

  /**
   * Process referral signup
   */
  async processReferralSignup(referralCode: string, newUserId: string): Promise<{
    success: boolean;
    referrerUserId: string;
    refereeReward: {
      type: string;
      value: number;
      description: string;
    };
  }> {
    try {
      this.logger.debug(`Processing referral signup with code ${referralCode} for new user ${newUserId}`);

      // Find referrer user by referral code
      const referrer = await this.userRepository.findOne({
        where: { referralCode },
      });

      if (!referrer) {
        throw new Error(`Invalid referral code: ${referralCode}`);
      }

      // Check if new user already exists and hasn't been processed for referral yet
      const newUser = await this.userRepository.findOne({
        where: { id: newUserId },
      });

      if (!newUser) {
        throw new Error(`New user with ID ${newUserId} not found`);
      }

      if (newUser.referredBy) {
        throw new Error(`User ${newUserId} has already been processed for referral`);
      }

      // Update new user with referrer information
      newUser.referredBy = referrer.id;
      await this.userRepository.save(newUser);

      // In a real implementation, this would also create reward records for both users
      // For now, we'll just return the success response

      return {
        success: true,
        referrerUserId: referrer.id,
        refereeReward: {
          type: 'credit',
          value: 25,
          description: '$25 off your first booking',
        },
      };
    } catch (error) {
      this.logger.error(`Error processing referral signup: ${error.message}`, error.stack);
      throw new Error(`Failed to process referral signup: ${error.message}`);
    }
  }

  /**
   * Get sharing statistics for a property
   */
  async getPropertySharingStats(propertyId: string): Promise<{
    totalShares: number;
    platformBreakdown: { [platform: string]: number };
    topReferrers: Array<{ userId: string; shares: number }>;
    conversionRate: number;
  }> {
    try {
      this.logger.debug(`Getting sharing stats for property ${propertyId}`);

      // In a real implementation, this would query a social_shares table
      // For now, we'll return simulated statistics
      
      return {
        totalShares: Math.floor(Math.random() * 100) + 50,
        platformBreakdown: {
          facebook: Math.floor(Math.random() * 40) + 20,
          twitter: Math.floor(Math.random() * 30) + 10,
          instagram: Math.floor(Math.random() * 20) + 5,
          whatsapp: Math.floor(Math.random() * 15) + 5,
          email: Math.floor(Math.random() * 10) + 5,
        },
        topReferrers: [
          { userId: 'user1', shares: Math.floor(Math.random() * 10) + 5 },
          { userId: 'user2', shares: Math.floor(Math.random() * 8) + 3 },
          { userId: 'user3', shares: Math.floor(Math.random() * 5) + 2 },
        ],
        conversionRate: Math.random() * 0.1 + 0.05, // 5-15% conversion rate
      };
    } catch (error) {
      this.logger.error(`Error getting property sharing stats: ${error.message}`, error.stack);
      throw new Error(`Failed to get property sharing stats: ${error.message}`);
    }
  }

  /**
   * Truncate description to appropriate length for platform
   */
  private truncateDescription(description: string, platform: string): string {
    if (!description) return '';
    
    const maxLengths = {
      facebook: 300,
      twitter: 200,
      instagram: 250,
      whatsapp: 200,
      email: 500,
      default: 200,
    };
    
    const maxLength = maxLengths[platform] || maxLengths.default;
    
    if (description.length <= maxLength) {
      return description;
    }
    
    return description.substring(0, maxLength - 3) + '...';
  }

  /**
   * Generate hashtags based on property attributes
   */
  private generateHashtags(property: PropertyEntity): string[] {
    const hashtags = ['Nestery', 'Travel'];
    
    // Add location hashtags
    hashtags.push(property.city.replace(/\s+/g, ''));
    hashtags.push(property.country.replace(/\s+/g, ''));
    
    // Add property type hashtag
    if (property.propertyType) {
      hashtags.push(property.propertyType.replace(/\s+/g, ''));
    }
    
    // Add amenity hashtags (limited to 2)
    if (property.amenities && Array.isArray(property.amenities)) {
      const amenityHashtags = property.amenities
        .slice(0, 2)
        .map(amenity => amenity.replace(/\s+/g, ''));
      
      hashtags.push(...amenityHashtags);
    }
    
    return hashtags;
  }

  /**
   * Customize content for specific platforms
   */
  private customizeForPlatform(
    baseContent: {
      title: string;
      description: string;
      imageUrl: string;
      shareUrl: string;
      hashtags: string[];
    },
    platform: string,
    property: PropertyEntity
  ): {
    title: string;
    description: string;
    imageUrl: string;
    shareUrl: string;
    hashtags: string[];
  } {
    switch (platform) {
      case 'twitter':
        return {
          ...baseContent,
          title: `Check out ${property.name} in ${property.city}!`,
          description: this.truncateDescription(property.description, 'twitter'),
          hashtags: baseContent.hashtags.slice(0, 3), // Twitter works best with fewer hashtags
        };
        
      case 'facebook':
        return {
          ...baseContent,
          description: `I found this amazing place in ${property.city}! ${baseContent.description}`,
        };
        
      case 'instagram':
        return {
          ...baseContent,
          title: `Dreaming of ${property.city}? 😍`,
          description: `${baseContent.description}\n\n${baseContent.hashtags.map(tag => `#${tag}`).join(' ')}`,
          // Instagram doesn't use hashtags separately, they're in the description
          hashtags: [],
        };
        
      case 'whatsapp':
        return {
          ...baseContent,
          title: `${property.name} in ${property.city}`,
          description: `Hey! Check out this amazing place I found on Nestery: ${baseContent.description}`,
          // WhatsApp doesn't use hashtags
          hashtags: [],
        };
        
      case 'email':
        return {
          ...baseContent,
          title: `Discover ${property.name} in ${property.city} with Nestery`,
          description: `I thought you might be interested in this property I found on Nestery:\n\n${property.name} in ${property.city}\n\n${property.description}\n\nCheck it out at: ${baseContent.shareUrl}`,
          // Email doesn't use hashtags
          hashtags: [],
        };
        
      default:
        return baseContent;
    }
  }

  /**
   * Generate referral code for a user
   */
  private generateReferralCode(user: UserEntity): string {
    // Generate a code based on user info and random characters
    const namePrefix = user.firstName.substring(0, 2).toUpperCase();
    const randomChars = Math.random().toString(36).substring(2, 6).toUpperCase();
    
    return `${namePrefix}${randomChars}`;
  }
}
