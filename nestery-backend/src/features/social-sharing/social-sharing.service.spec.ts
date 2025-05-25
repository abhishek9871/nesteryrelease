import { Test, TestingModule } from '@nestjs/testing';
import { SocialSharingService } from './social-sharing.service';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { PropertyEntity } from '../../properties/entities/property.entity';
import { UserEntity } from '../../users/entities/user.entity';
import { Repository } from 'typeorm';

describe('SocialSharingService', () => {
  let service: SocialSharingService;
  let propertyRepository: Repository<PropertyEntity>;
  let userRepository: Repository<UserEntity>;

  const mockPropertyRepository = {
    findOne: jest.fn().mockResolvedValue({
      id: 'property1',
      name: 'Test Property 1',
      city: 'New York',
      country: 'US',
      description: 'A beautiful property in the heart of New York City with amazing views and amenities.',
      thumbnailImage: 'https://example.com/image.jpg',
      images: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
      propertyType: 'hotel',
      amenities: ['wifi', 'pool', 'gym'],
      rating: 4.5,
    }),
  };

  const mockUserRepository = {
    findOne: jest.fn().mockResolvedValue({
      id: 'user1',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      referralCode: 'JO1234',
    }),
    save: jest.fn().mockResolvedValue({
      id: 'user1',
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      referralCode: 'JO1234',
    }),
  };

  const mockConfigService = {
    get: jest.fn((key) => {
      if (key === 'APP_URL') return 'https://nestery.com';
      return null;
    }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SocialSharingService,
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
        {
          provide: LoggerService,
          useValue: {
            setContext: jest.fn(),
            debug: jest.fn(),
            error: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(PropertyEntity),
          useValue: mockPropertyRepository,
        },
        {
          provide: getRepositoryToken(UserEntity),
          useValue: mockUserRepository,
        },
      ],
    }).compile();

    service = module.get<SocialSharingService>(SocialSharingService);
    propertyRepository = module.get<Repository<PropertyEntity>>(getRepositoryToken(PropertyEntity));
    userRepository = module.get<Repository<UserEntity>>(getRepositoryToken(UserEntity));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('generateShareableContent', () => {
    it('should generate shareable content for Facebook', async () => {
      const propertyId = 'property1';
      const platform = 'facebook';

      const result = await service.generateShareableContent(propertyId, platform);

      expect(result).toBeDefined();
      expect(result.title).toContain('Test Property 1');
      expect(result.description).toBeDefined();
      expect(result.imageUrl).toBe('https://example.com/image.jpg');
      expect(result.shareUrl).toContain('utm_source=facebook');
      expect(result.hashtags).toBeDefined();
      expect(result.hashtags.length).toBeGreaterThan(0);
      expect(propertyRepository.findOne).toHaveBeenCalledWith({
        where: { id: propertyId },
      });
    });

    it('should generate shareable content for Twitter', async () => {
      const propertyId = 'property1';
      const platform = 'twitter';

      const result = await service.generateShareableContent(propertyId, platform);

      expect(result).toBeDefined();
      expect(result.title).toContain('Test Property 1');
      expect(result.description.length).toBeLessThanOrEqual(200); // Twitter has shorter description
      expect(result.imageUrl).toBe('https://example.com/image.jpg');
      expect(result.shareUrl).toContain('utm_source=twitter');
      expect(result.hashtags).toBeDefined();
      expect(result.hashtags.length).toBeLessThanOrEqual(3); // Twitter uses fewer hashtags
    });

    it('should throw an error if property not found', async () => {
      const propertyId = 'nonexistent';
      const platform = 'facebook';

      // Mock property not found
      jest.spyOn(propertyRepository, 'findOne').mockResolvedValueOnce(null);

      await expect(service.generateShareableContent(propertyId, platform)).rejects.toThrow(
        `Property with ID ${propertyId} not found`,
      );
    });

    it('should handle errors gracefully', async () => {
      const propertyId = 'property1';
      const platform = 'facebook';

      // Mock error
      jest.spyOn(propertyRepository, 'findOne').mockRejectedValueOnce(new Error('Database error'));

      await expect(service.generateShareableContent(propertyId, platform)).rejects.toThrow('Failed to generate shareable content');
    });
  });

  describe('trackSocialShare', () => {
    it('should track a social share event', async () => {
      const params = {
        userId: 'user1',
        propertyId: 'property1',
        platform: 'facebook',
        shareUrl: 'https://nestery.com/properties/property1?utm_source=facebook',
      };

      const result = await service.trackSocialShare(params);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.shareId).toBeDefined();
    });

    it('should handle errors gracefully', async () => {
      const params = {
        userId: 'user1',
        propertyId: 'property1',
        platform: 'facebook',
        shareUrl: 'https://nestery.com/properties/property1?utm_source=facebook',
      };

      // Mock implementation to throw error
      jest.spyOn(service as any, 'trackSocialShare').mockImplementationOnce(() => {
        throw new Error('Tracking error');
      });

      await expect(service.trackSocialShare(params)).rejects.toThrow('Failed to track social share');
    });
  });

  describe('getReferralLink', () => {
    it('should get referral link for a user with existing referral code', async () => {
      const userId = 'user1';

      const result = await service.getReferralLink(userId);

      expect(result).toBeDefined();
      expect(result.referralCode).toBe('JO1234');
      expect(result.referralUrl).toContain('ref=JO1234');
      expect(result.rewards).toBeDefined();
      expect(result.rewards.referrerReward).toBeDefined();
      expect(result.rewards.refereeReward).toBeDefined();
      expect(userRepository.findOne).toHaveBeenCalledWith({
        where: { id: userId },
      });
    });

    it('should generate and save referral code for a user without one', async () => {
      const userId = 'user2';

      // Mock user without referral code
      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce({
        id: 'user2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        referralCode: null,
      });

      const result = await service.getReferralLink(userId);

      expect(result).toBeDefined();
      expect(result.referralCode).toBeDefined();
      expect(result.referralUrl).toContain(`ref=${result.referralCode}`);
      expect(result.rewards).toBeDefined();
      expect(userRepository.save).toHaveBeenCalled();
    });

    it('should throw an error if user not found', async () => {
      const userId = 'nonexistent';

      // Mock user not found
      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce(null);

      await expect(service.getReferralLink(userId)).rejects.toThrow(
        `User with ID ${userId} not found`,
      );
    });

    it('should handle errors gracefully', async () => {
      const userId = 'user1';

      // Mock error
      jest.spyOn(userRepository, 'findOne').mockRejectedValueOnce(new Error('Database error'));

      await expect(service.getReferralLink(userId)).rejects.toThrow('Failed to get referral link');
    });
  });

  describe('processReferralSignup', () => {
    it('should process a valid referral signup', async () => {
      const referralCode = 'JO1234';
      const newUserId = 'user2';

      // Mock new user without referral
      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce({
        id: 'user1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        referralCode: 'JO1234',
      }).mockResolvedValueOnce({
        id: 'user2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        referredBy: null,
      });

      const result = await service.processReferralSignup(referralCode, newUserId);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.referrerUserId).toBe('user1');
      expect(result.refereeReward).toBeDefined();
      expect(result.refereeReward.type).toBe('credit');
      expect(result.refereeReward.value).toBe(25);
      expect(userRepository.save).toHaveBeenCalled();
    });

    it('should throw an error if referral code is invalid', async () => {
      const referralCode = 'INVALID';
      const newUserId = 'user2';

      // Mock invalid referral code
      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce(null);

      await expect(service.processReferralSignup(referralCode, newUserId)).rejects.toThrow(
        `Invalid referral code: ${referralCode}`,
      );
    });

    it('should throw an error if new user not found', async () => {
      const referralCode = 'JO1234';
      const newUserId = 'nonexistent';

      // Mock referrer found but new user not found
      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce({
        id: 'user1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        referralCode: 'JO1234',
      }).mockResolvedValueOnce(null);

      await expect(service.processReferralSignup(referralCode, newUserId)).rejects.toThrow(
        `New user with ID ${newUserId} not found`,
      );
    });

    it('should throw an error if user already processed for referral', async () => {
      const referralCode = 'JO1234';
      const newUserId = 'user2';

      // Mock user already referred
      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce({
        id: 'user1',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        referralCode: 'JO1234',
      }).mockResolvedValueOnce({
        id: 'user2',
        firstName: 'Jane',
        lastName: 'Smith',
        email: 'jane.smith@example.com',
        referredBy: 'user3',
      });

      await expect(service.processReferralSignup(referralCode, newUserId)).rejects.toThrow(
        `User ${newUserId} has already been processed for referral`,
      );
    });

    it('should handle errors gracefully', async () => {
      const referralCode = 'JO1234';
      const newUserId = 'user2';

      // Mock error
      jest.spyOn(userRepository, 'findOne').mockRejectedValueOnce(new Error('Database error'));

      await expect(service.processReferralSignup(referralCode, newUserId)).rejects.toThrow('Failed to process referral signup');
    });
  });

  describe('getPropertySharingStats', () => {
    it('should return sharing statistics for a property', async () => {
      const propertyId = 'property1';

      const result = await service.getPropertySharingStats(propertyId);

      expect(result).toBeDefined();
      expect(result.totalShares).toBeDefined();
      expect(result.platformBreakdown).toBeDefined();
      expect(result.topReferrers).toBeDefined();
      expect(result.conversionRate).toBeDefined();
      expect(result.conversionRate).toBeGreaterThan(0);
      expect(result.conversionRate).toBeLessThan(1);
    });

    it('should handle errors gracefully', async () => {
      const propertyId = 'property1';

      // Mock implementation to throw error
      jest.spyOn(service as any, 'getPropertySharingStats').mockImplementationOnce(() => {
        throw new Error('Stats error');
      });

      await expect(service.getPropertySharingStats(propertyId)).rejects.toThrow('Failed to get property sharing stats');
    });
  });
});
