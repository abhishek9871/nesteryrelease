import { Test, TestingModule } from '@nestjs/testing';
import { UsersService } from './users.service';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from './entities/user.entity';
import { PremiumSubscription } from '../features/subscriptions/entities/premium-subscription.entity';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { ConfigService } from '@nestjs/config';
import { LoyaltyTierEnum } from '../features/loyalty/enums/loyalty-tier.enum';

describe('UsersService', () => {
  let service: UsersService;
  let mockUserRepository: jest.Mocked<any>;
  let mockPremiumSubscriptionRepository: jest.Mocked<any>;
  let mockCacheManager: jest.Mocked<any>;

  const mockUser: User = {
    id: 'test-user-id',
    email: 'test@example.com',
    password: 'hashedpassword',
    firstName: 'John',
    lastName: 'Doe',
    phoneNumber: '+1234567890',
    profilePicture: 'https://example.com/profile.jpg',
    role: 'user',
    preferences: {},
    refreshToken: 'refresh-token',
    loyaltyMilesBalance: 1000,
    loyaltyTier: LoyaltyTierEnum.SCOUT,
    loyaltyPoints: 500,
    authProvider: 'local',
    authProviderId: 'auth-provider-id',
    stripeCustomerId: 'stripe-customer-id',
    emailVerified: true,
    phoneVerified: true,
    createdAt: new Date('2025-01-01'),
    updatedAt: new Date('2025-01-01'),
  } as User;

  const mockActiveSubscription: PremiumSubscription = {
    id: 'subscription-id',
    userId: 'test-user-id',
    user: mockUser,
    plan: 'monthly',
    status: 'active',
    startDate: new Date('2025-01-01'),
    endDate: new Date('2025-12-31'), // Future date
    pricePaid: 5.99,
    currency: 'USD',
    paymentMethod: 'stripe',
    stripeSubscriptionId: 'stripe-sub-id',
    autoRenew: true,
    cancelledAt: new Date('2025-01-01'),
    cancellationReason: 'test-reason',
    createdAt: new Date('2025-01-01'),
    updatedAt: new Date('2025-01-01'),
  } as PremiumSubscription;

  beforeEach(async () => {
    mockUserRepository = {
      create: jest.fn(),
      save: jest.fn(),
      findOne: jest.fn(),
      find: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };

    mockPremiumSubscriptionRepository = {
      findOne: jest.fn(),
      find: jest.fn(),
    };

    mockCacheManager = {
      del: jest.fn(),
      get: jest.fn(),
      set: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsersService,
        {
          provide: LoggerService,
          useValue: {
            setContext: jest.fn(),
            debug: jest.fn(),
            warn: jest.fn(),
            error: jest.fn(),
            log: jest.fn(),
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
          useValue: mockUserRepository,
        },
        {
          provide: getRepositoryToken(PremiumSubscription),
          useValue: mockPremiumSubscriptionRepository,
        },
        {
          provide: CACHE_MANAGER,
          useValue: mockCacheManager,
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn().mockReturnValue('v1'),
          },
        },
      ],
    }).compile();

    service = module.get<UsersService>(UsersService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('isUserPremium', () => {
    it('should return true when user has active subscription with future end date', async () => {
      mockPremiumSubscriptionRepository.findOne.mockResolvedValue(mockActiveSubscription);

      const result = await service.isUserPremium('test-user-id');

      expect(result).toBe(true);
      expect(mockPremiumSubscriptionRepository.findOne).toHaveBeenCalledWith({
        where: {
          userId: 'test-user-id',
          status: 'active',
        },
      });
    });

    it('should return false when user has no active subscription', async () => {
      mockPremiumSubscriptionRepository.findOne.mockResolvedValue(null);

      const result = await service.isUserPremium('test-user-id');

      expect(result).toBe(false);
    });

    it('should return false when subscription is expired despite active status', async () => {
      const expiredSubscription = {
        ...mockActiveSubscription,
        endDate: new Date('2024-01-01'), // Past date
      };
      mockPremiumSubscriptionRepository.findOne.mockResolvedValue(expiredSubscription);

      const result = await service.isUserPremium('test-user-id');

      expect(result).toBe(false);
    });

    it('should return false and handle errors gracefully', async () => {
      mockPremiumSubscriptionRepository.findOne.mockRejectedValue(new Error('Database error'));

      const result = await service.isUserPremium('test-user-id');

      expect(result).toBe(false);
    });
  });

  describe('getUserProfile', () => {
    it('should return user profile with isPremium true when user has active subscription', async () => {
      mockUserRepository.findOne.mockResolvedValue(mockUser);
      mockPremiumSubscriptionRepository.findOne.mockResolvedValue(mockActiveSubscription);

      const result = await service.getUserProfile('test-user-id');

      expect(result).toEqual({
        id: mockUser.id,
        email: mockUser.email,
        firstName: mockUser.firstName,
        lastName: mockUser.lastName,
        role: mockUser.role,
        profilePicture: mockUser.profilePicture,
        phoneNumber: mockUser.phoneNumber,
        loyaltyTier: mockUser.loyaltyTier,
        loyaltyPoints: mockUser.loyaltyPoints,
        isPremium: true,
        createdAt: mockUser.createdAt,
      });
    });

    it('should return user profile with isPremium false when user has no active subscription', async () => {
      mockUserRepository.findOne.mockResolvedValue(mockUser);
      mockPremiumSubscriptionRepository.findOne.mockResolvedValue(null);

      const result = await service.getUserProfile('test-user-id');

      expect(result).toEqual({
        id: mockUser.id,
        email: mockUser.email,
        firstName: mockUser.firstName,
        lastName: mockUser.lastName,
        role: mockUser.role,
        profilePicture: mockUser.profilePicture,
        phoneNumber: mockUser.phoneNumber,
        loyaltyTier: mockUser.loyaltyTier,
        loyaltyPoints: mockUser.loyaltyPoints,
        isPremium: false,
        createdAt: mockUser.createdAt,
      });
    });

    it('should return null when user is not found', async () => {
      mockUserRepository.findOne.mockResolvedValue(null);

      const result = await service.getUserProfile('non-existent-user-id');

      expect(result).toBeNull();
    });

    it('should return null and handle errors gracefully', async () => {
      mockUserRepository.findOne.mockRejectedValue(new Error('Database error'));

      const result = await service.getUserProfile('test-user-id');

      expect(result).toBeNull();
    });
  });

  describe('findById', () => {
    it('should return user when found', async () => {
      mockUserRepository.findOne.mockResolvedValue(mockUser);

      const result = await service.findById('test-user-id');

      expect(result).toEqual(mockUser);
      expect(mockUserRepository.findOne).toHaveBeenCalledWith({ where: { id: 'test-user-id' } });
    });

    it('should return null when user not found', async () => {
      mockUserRepository.findOne.mockResolvedValue(null);

      const result = await service.findById('non-existent-user-id');

      expect(result).toBeNull();
    });
  });
});
