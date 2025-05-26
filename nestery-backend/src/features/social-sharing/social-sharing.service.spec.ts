import { Test, TestingModule } from '@nestjs/testing';
import { SocialSharingService } from './social-sharing.service';
import { ConfigService } from '@nestjs/config';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../../users/entities/user.entity';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';

describe('SocialSharingService', () => {
  let service: SocialSharingService;
  let userRepository: any;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SocialSharingService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn().mockImplementation(key => {
              if (key === 'APP_URL') return 'https://nestery.com';
              return null;
            }),
          },
        },
        {
          provide: LoggerService,
          useValue: {
            setContext: jest.fn(),
            log: jest.fn(),
            error: jest.fn(),
            debug: jest.fn(),
            warn: jest.fn(),
          },
        },
        {
          provide: ExceptionService,
          useValue: {
            handleException: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(User),
          useValue: {
            findOne: jest.fn(),
            find: jest.fn(),
            save: jest.fn(),
            update: jest.fn(),
          },
        },
      ],
    }).compile();

    service = module.get<SocialSharingService>(SocialSharingService);
    userRepository = module.get(getRepositoryToken(User));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getSocialPlatforms', () => {
    it('should return all available social platforms', () => {
      const platforms = service.getSocialPlatforms();
      expect(platforms).toBeDefined();
      expect(platforms.length).toBeGreaterThan(0);
      expect(platforms[0].name).toBeDefined();
      expect(platforms[0].icon).toBeDefined();
      expect(platforms[0].color).toBeDefined();
    });
  });

  describe('generatePropertySharingLinks', () => {
    it('should generate sharing links for a property', () => {
      const propertyId = 'property1';
      const propertyName = 'Luxury Villa';
      const result = service.generatePropertySharingLinks(propertyId, propertyName);
      expect(result).toBeDefined();
      expect(result.url).toContain(propertyId);
      expect(result.text).toContain(propertyName);
      expect(result.links).toBeDefined();
      expect(Object.keys(result.links).length).toBeGreaterThan(0);
    });
  });

  describe('generateReferralCode', () => {
    it('should generate a referral code for a user', async () => {
      const userId = 'user1';
      const mockUser = new User();
      mockUser.id = userId;
      mockUser.firstName = 'John';
      mockUser.lastName = 'Doe';
      mockUser.email = 'john.doe@example.com';
      mockUser.name = 'John Doe';
      mockUser.password = 'hashedpassword';
      mockUser.role = 'user';

      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce(mockUser);
      jest.spyOn(userRepository, 'save').mockResolvedValueOnce(mockUser);

      const result = await service.generateReferralCode(userId);
      expect(result).toBeDefined();
      expect(result.length).toBeGreaterThan(5);
      expect(result.startsWith('JO')).toBeTruthy();
      expect(userRepository.save).toHaveBeenCalled();
    });

    it('should throw an error if user not found', async () => {
      const userId = 'nonexistent';
      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce(null);
      await expect(service.generateReferralCode(userId)).rejects.toThrow(
        `User with ID ${userId} not found`,
      );
    });
  });

  describe('getUserByReferralCode', () => {
    it('should return a user by referral code', async () => {
      const referralCode = 'JO1234';
      const mockUser = new User();
      mockUser.id = 'user1';
      mockUser.firstName = 'John';
      mockUser.lastName = 'Doe';
      mockUser.email = 'john.doe@example.com';
      mockUser.name = 'John Doe';
      mockUser.password = 'hashedpassword';
      mockUser.role = 'user';
      mockUser.referralCode = referralCode;

      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce(mockUser);

      const result = await service.getUserByReferralCode(referralCode);
      if (result) {
        // Add null check
        expect(result.id).toBe('user1');
        expect(result.referralCode).toBe(referralCode);
      }
      expect(result).toBeDefined();
    });

    it('should return null if no user found with referral code', async () => {
      const referralCode = 'INVALID';
      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce(null);
      const result = await service.getUserByReferralCode(referralCode);
      expect(result).toBeNull();
    });
  });

  describe('processReferral', () => {
    it('should process a valid referral', async () => {
      const referralCode = 'JO1234';

      const referrer = new User();
      referrer.id = 'user1';
      referrer.firstName = 'John';
      referrer.lastName = 'Doe';
      referrer.email = 'john.doe@example.com';
      referrer.name = 'John Doe';
      referrer.password = 'hashedpassword';
      referrer.role = 'user';
      referrer.referralCode = referralCode;

      const newUser = new User();
      newUser.id = 'user2';
      newUser.firstName = 'Jane';
      newUser.lastName = 'Smith';
      newUser.email = 'jane.smith@example.com';
      newUser.name = 'Jane Smith';
      newUser.password = 'hashedpassword';
      newUser.role = 'user';

      jest.spyOn(service, 'getUserByReferralCode').mockResolvedValueOnce(referrer);
      jest.spyOn(userRepository, 'save').mockResolvedValueOnce(newUser);

      const result = await service.processReferral(newUser, referralCode);
      expect(result).toBe(true);
      expect(newUser.referredBy).toBe('user1');
      expect(userRepository.save).toHaveBeenCalled();
    });

    it('should return false if user already has a referrer', async () => {
      const referralCode = 'JO1234';

      const newUser = new User();
      newUser.id = 'user2';
      newUser.firstName = 'Jane';
      newUser.lastName = 'Smith';
      newUser.email = 'jane.smith@example.com';
      newUser.name = 'Jane Smith';
      newUser.password = 'hashedpassword';
      newUser.role = 'user';
      newUser.referredBy = 'user3';

      const result = await service.processReferral(newUser, referralCode);
      expect(result).toBe(false);
    });

    it('should return false if referrer not found', async () => {
      const referralCode = 'INVALID';

      const newUser = new User();
      newUser.id = 'user2';
      newUser.firstName = 'Jane';
      newUser.lastName = 'Smith';
      newUser.email = 'jane.smith@example.com';
      newUser.name = 'Jane Smith';
      newUser.password = 'hashedpassword';
      newUser.role = 'user';

      jest.spyOn(service, 'getUserByReferralCode').mockResolvedValueOnce(null);

      const result = await service.processReferral(newUser, referralCode);
      expect(result).toBe(false);
    });
  });

  describe('processReferralSignup', () => {
    it('should process a valid referral signup', async () => {
      const referralCode = 'JO1234';
      const newUserId = 'user2';

      const newUser = new User();
      newUser.id = newUserId;
      newUser.firstName = 'Jane';
      newUser.lastName = 'Smith';
      newUser.email = 'jane.smith@example.com';
      newUser.name = 'Jane Smith';
      newUser.password = 'hashedpassword';
      newUser.role = 'user';

      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce(newUser);
      jest.spyOn(service, 'processReferral').mockResolvedValueOnce(true);

      const result = await service.processReferralSignup(referralCode, newUserId);
      expect(result).toBe(true);
    });

    it('should throw an error if user not found', async () => {
      const referralCode = 'JO1234';
      const newUserId = 'nonexistent';

      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce(null);

      await expect(service.processReferralSignup(referralCode, newUserId)).rejects.toThrow(
        `User with ID ${newUserId} not found`,
      );
    });
  });

  describe('getReferralInfo', () => {
    it('should return referral information for a user', async () => {
      const userId = 'user1';

      const mockUser = new User();
      mockUser.id = userId;
      mockUser.firstName = 'John';
      mockUser.lastName = 'Doe';
      mockUser.email = 'john.doe@example.com';
      mockUser.name = 'John Doe';
      mockUser.password = 'hashedpassword';
      mockUser.role = 'user';
      mockUser.referralCode = 'JO1234';
      mockUser.referredUsers = [];

      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce(mockUser);
      jest.spyOn(service, 'generateQRCode').mockResolvedValueOnce('data:image/png;base64,abc123');

      const result = await service.getReferralInfo(userId);
      expect(result).toBeDefined();
      expect(result.referralCode).toBe('JO1234');
      expect(result.referralLink).toContain('JO1234');
      expect(result.qrCode).toBeDefined();
      expect(result.referralStats).toBeDefined();
      expect(result.rewards).toBeDefined();
      expect(result.sharingLinks).toBeDefined();
    });

    it('should throw an error if user not found', async () => {
      const userId = 'nonexistent';
      jest.spyOn(userRepository, 'findOne').mockResolvedValueOnce(null);
      await expect(service.getReferralInfo(userId)).rejects.toThrow(
        `User with ID ${userId} not found`,
      );
    });
  });

  describe('getPropertySharingStats', () => {
    it('should return sharing statistics for a property', async () => {
      const propertyId = 'property1';
      const result = await service.getPropertySharingStats(propertyId);
      expect(result).toBeDefined();
      expect(result.totalShares).toBeDefined();
      expect(result.sharesByPlatform).toBeDefined();
      expect(result.clickThroughRate).toBeDefined();
    });
  });

  describe('generateShortenedMessage', () => {
    it('should return original message if within length limit', () => {
      const message = 'This is a short message';
      const platform = 'twitter';
      const result = service.generateShortenedMessage(message, platform);
      expect(result).toBe(message);
    });

    it('should shorten message if exceeds length limit', () => {
      const longMessage = 'A'.repeat(300);
      const platform = 'twitter';
      const result = service.generateShortenedMessage(longMessage, platform);
      expect(result.length).toBeLessThan(longMessage.length);
      expect(result.endsWith('...')).toBeTruthy();
    });
  });

  describe('shareBookingConfirmation', () => {
    it('should generate sharing link for booking confirmation', async () => {
      const bookingId = 'booking1';
      const platform = 'facebook';

      const result = await service.shareBookingConfirmation(bookingId, platform);
      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.platform).toBeDefined();
      expect(result.sharingLink).toBeDefined();
    });

    it('should throw error for unsupported platform', async () => {
      const bookingId = 'booking1';
      const platform = 'unsupported';

      await expect(service.shareBookingConfirmation(bookingId, platform)).rejects.toThrow(
        `Platform ${platform} not supported`,
      );
    });
  });
});
