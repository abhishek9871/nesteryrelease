import { Test, TestingModule } from '@nestjs/testing';
import { LoyaltyService } from './loyalty.service';
import { LoggerService } from '../../core/logger/logger.service';
import { ConfigService } from '@nestjs/config';
import { getRepositoryToken } from '@nestjs/typeorm';
import { UserEntity } from '../../users/entities/user.entity';
import { LoyaltyTierDefinitionEntity } from './entities/loyalty-tier-definition.entity';
import { LoyaltyTransactionEntity } from './entities/loyalty-transaction.entity';
import { LoyaltyTierEnum } from './enums/loyalty-tier.enum';
import { LoyaltyTransactionTypeEnum } from './enums/loyalty-transaction-type.enum';
import { EventEmitter2 } from '@nestjs/event-emitter';
import { DataSource } from 'typeorm';

describe('LoyaltyService', () => {
  let service: LoyaltyService;
  let mockUserRepository: jest.Mocked<any>;
  let mockTierDefinitionRepository: jest.Mocked<any>;
  let mockTransactionRepository: jest.Mocked<any>;
  let mockEventEmitter: jest.Mocked<any>;
  let mockDataSource: jest.Mocked<any>;

  beforeEach(async () => {
    mockUserRepository = {
      findOneBy: jest.fn(),
      update: jest.fn(),
      save: jest.fn(),
    };

    mockTierDefinitionRepository = {
      findOneBy: jest.fn(),
      find: jest.fn(),
      create: jest.fn(),
      save: jest.fn(),
    };

    mockTransactionRepository = {
      findOne: jest.fn(),
      findAndCount: jest.fn(),
      create: jest.fn(),
      save: jest.fn(),
    };

    mockEventEmitter = {
      emit: jest.fn(),
    };

    const mockQueryRunner = {
      connect: jest.fn(),
      startTransaction: jest.fn(),
      commitTransaction: jest.fn(),
      rollbackTransaction: jest.fn(),
      release: jest.fn(),
      manager: {
        findOneBy: jest.fn(),
        find: jest.fn(),
        save: jest.fn(),
      },
    };

    mockDataSource = {
      createQueryRunner: jest.fn().mockReturnValue(mockQueryRunner),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LoyaltyService,
        {
          provide: LoggerService,
          useValue: {
            setContext: jest.fn(),
            debug: jest.fn(),
            log: jest.fn(),
            error: jest.fn(),
            warn: jest.fn(),
          },
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn().mockReturnValue(5),
          },
        },
        {
          provide: getRepositoryToken(UserEntity),
          useValue: mockUserRepository,
        },
        {
          provide: getRepositoryToken(LoyaltyTierDefinitionEntity),
          useValue: mockTierDefinitionRepository,
        },
        {
          provide: getRepositoryToken(LoyaltyTransactionEntity),
          useValue: mockTransactionRepository,
        },
        {
          provide: EventEmitter2,
          useValue: mockEventEmitter,
        },
        {
          provide: DataSource,
          useValue: mockDataSource,
        },
      ],
    }).compile();

    service = module.get<LoyaltyService>(LoyaltyService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getLoyaltyStatus', () => {
    it('should return loyalty status for a user', async () => {
      const userId = 'test-user-id';
      const mockUser = {
        id: userId,
        loyaltyMilesBalance: 1500,
        loyaltyTier: LoyaltyTierEnum.EXPLORER,
      };

      const mockTierDefinition = {
        tier: LoyaltyTierEnum.EXPLORER,
        name: 'Explorer',
        minMilesRequired: 1000,
        earningMultiplier: 1.25,
        benefitsDescription: 'Explorer benefits',
      };

      mockUserRepository.findOneBy.mockResolvedValue(mockUser);
      mockTierDefinitionRepository.findOneBy.mockResolvedValue(mockTierDefinition);
      mockTierDefinitionRepository.find.mockResolvedValue([
        { tier: LoyaltyTierEnum.SCOUT, name: 'Scout', minMilesRequired: 0 },
        { tier: LoyaltyTierEnum.EXPLORER, name: 'Explorer', minMilesRequired: 1000 },
        { tier: LoyaltyTierEnum.NAVIGATOR, name: 'Navigator', minMilesRequired: 5000 },
      ]);

      const result = await service.getLoyaltyStatus(userId);

      expect(result).toBeDefined();
      expect(result.loyaltyMilesBalance).toBe(1500);
      expect(result.loyaltyTier).toBe(LoyaltyTierEnum.EXPLORER);
      expect(result.tierName).toBe('Explorer');
      expect(result.nextTier).toBe('Navigator');
      expect(result.milesToNextTier).toBe(3500);
    });

    it('should throw an error if user not found', async () => {
      const userId = 'nonexistent-user';
      mockUserRepository.findOneBy.mockResolvedValue(null);

      await expect(service.getLoyaltyStatus(userId)).rejects.toThrow(
        'User with ID nonexistent-user not found',
      );
    });
  });

  describe('performDailyCheckIn', () => {
    it('should perform daily check-in successfully', async () => {
      const userId = 'test-user-id';
      const mockUser = {
        id: userId,
        loyaltyMilesBalance: 100,
        loyaltyTier: LoyaltyTierEnum.SCOUT,
      };

      mockUserRepository.findOneBy.mockResolvedValue(mockUser);
      mockTransactionRepository.findOne.mockResolvedValue(null); // No existing check-in today

      // Mock the awardMiles method by spying on it
      const awardMilesSpy = jest.spyOn(service, 'awardMiles').mockResolvedValue({
        id: 'transaction-id',
        userId,
        transactionType: LoyaltyTransactionTypeEnum.DAILY_CHECKIN_EARN,
        milesAmount: 5,
        description: 'Daily Check-in Bonus',
        createdAt: new Date(),
      } as any);

      const result = await service.performDailyCheckIn(userId);

      expect(result).toBeDefined();
      expect(awardMilesSpy).toHaveBeenCalledWith(
        userId,
        5,
        LoyaltyTransactionTypeEnum.DAILY_CHECKIN_EARN,
        'Daily Check-in Bonus',
      );
    });

    it('should throw an error if already checked in today', async () => {
      const userId = 'test-user-id';
      const mockUser = {
        id: userId,
        loyaltyMilesBalance: 100,
      };

      mockUserRepository.findOneBy.mockResolvedValue(mockUser);
      mockTransactionRepository.findOne.mockResolvedValue({ id: 'existing-checkin' }); // Existing check-in today

      await expect(service.performDailyCheckIn(userId)).rejects.toThrow(
        'Already checked in today.',
      );
    });
  });

  describe('getTransactionsHistory', () => {
    it('should return transaction history for a user', async () => {
      const userId = 'test-user-id';
      const page = 1;
      const limit = 10;

      const mockUser = {
        id: userId,
        loyaltyMilesBalance: 1000,
      };

      const mockTransactions = [
        {
          id: 'transaction-1',
          userId,
          transactionType: LoyaltyTransactionTypeEnum.DAILY_CHECKIN_EARN,
          milesAmount: 5,
          description: 'Daily Check-in Bonus',
          createdAt: new Date(),
        },
      ];

      mockUserRepository.findOneBy.mockResolvedValue(mockUser);
      mockTransactionRepository.findAndCount.mockResolvedValue([mockTransactions, 1]);

      const result = await service.getTransactionsHistory(userId, page, limit);

      expect(result).toBeDefined();
      expect(result.data).toEqual(mockTransactions);
      expect(result.total).toBe(1);
      expect(result.page).toBe(page);
      expect(result.limit).toBe(limit);
    });

    it('should throw an error if user not found', async () => {
      const userId = 'nonexistent-user';
      mockUserRepository.findOneBy.mockResolvedValue(null);

      await expect(service.getTransactionsHistory(userId, 1, 10)).rejects.toThrow('User not found');
    });
  });
});
