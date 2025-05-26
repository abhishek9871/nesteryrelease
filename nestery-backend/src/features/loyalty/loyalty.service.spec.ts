import { Test, TestingModule } from '@nestjs/testing';
import { LoyaltyService } from './loyalty.service';
import { LoggerService } from '../../core/logger/logger.service';
import { ConfigService } from '@nestjs/config';
import { getRepositoryToken } from '@nestjs/typeorm';
import { UserEntity } from '../../users/entities/user.entity';
import { BookingEntity } from '../../bookings/entities/booking.entity';

describe('LoyaltyService', () => {
  let service: LoyaltyService;
  let mockUserRepository: any;
  let mockBookingRepository: any;

  beforeEach(async () => {
    mockUserRepository = {
      findOne: jest.fn(),
      update: jest.fn(),
      save: jest.fn(),
    };

    mockBookingRepository = {
      findOne: jest.fn(),
      find: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LoyaltyService,
        {
          provide: LoggerService,
          useValue: {
            setContext: jest.fn(),
            debug: jest.fn(),
            error: jest.fn(),
          },
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(UserEntity),
          useValue: mockUserRepository,
        },
        {
          provide: getRepositoryToken(BookingEntity),
          useValue: mockBookingRepository,
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
        loyaltyPoints: 1500,
      };

      const mockBookings = [
        {
          id: 'booking1',
          createdAt: new Date(),
          property: { name: 'Test Property' },
        },
      ];

      mockUserRepository.findOne.mockResolvedValue(mockUser);
      mockBookingRepository.find.mockResolvedValue(mockBookings);

      const result = await service.getLoyaltyStatus(userId);

      expect(result).toBeDefined();
      expect(result.tier).toBe('Silver');
      expect(result.points).toBe(1500);
      expect(result.nextTier).toBe('Gold');
      expect(result.pointsToNextTier).toBe(500);
      expect(result.benefits).toBeInstanceOf(Array);
      expect(result.history).toBeInstanceOf(Array);
    });

    it('should throw an error if user not found', async () => {
      const userId = 'nonexistent-user';
      mockUserRepository.findOne.mockResolvedValue(null);

      await expect(service.getLoyaltyStatus(userId)).rejects.toThrow('User not found');
    });
  });

  describe('awardPointsForBooking', () => {
    it('should award points for a completed booking', async () => {
      const bookingId = 'test-booking-id';
      const mockBooking = {
        id: bookingId,
        status: 'completed',
        user: {
          id: 'user1',
          loyaltyPoints: 500,
        },
        property: {
          name: 'Test Property',
          rating: 4.8,
        },
        checkInDate: new Date('2023-01-01'),
        checkOutDate: new Date('2023-01-05'),
        totalPrice: 1000,
      };

      mockBookingRepository.findOne.mockResolvedValue(mockBooking);
      mockUserRepository.update.mockResolvedValue({ affected: 1 });

      const result = await service.awardPointsForBooking(bookingId);

      expect(result).toBeDefined();
      expect(result.awarded).toBeGreaterThan(0);
      expect(result.newTotal).toBeGreaterThan(500);
      expect(result.tier).toBeDefined();
    });

    it('should throw an error if booking not found', async () => {
      const bookingId = 'nonexistent-booking';
      mockBookingRepository.findOne.mockResolvedValue(null);

      await expect(service.awardPointsForBooking(bookingId)).rejects.toThrow('Booking not found');
    });

    it('should throw an error if booking is not completed', async () => {
      const bookingId = 'pending-booking';
      const mockBooking = {
        id: bookingId,
        status: 'pending',
      };

      mockBookingRepository.findOne.mockResolvedValue(mockBooking);

      await expect(service.awardPointsForBooking(bookingId)).rejects.toThrow(
        'Cannot award points for non-completed booking',
      );
    });
  });

  describe('redeemPoints', () => {
    it('should redeem points for a reward', async () => {
      const userId = 'test-user-id';
      const rewardId = 'reward1';
      const pointsRequired = 500;

      const mockUser = {
        id: userId,
        loyaltyPoints: 1000,
      };

      mockUserRepository.findOne.mockResolvedValue(mockUser);
      mockUserRepository.update.mockResolvedValue({ affected: 1 });

      const result = await service.redeemPoints(userId, rewardId, pointsRequired);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.remainingPoints).toBe(500);
      expect(result.reward).toBeDefined();
      expect(result.reward.id).toBe(rewardId);
      expect(result.reward.pointsRequired).toBe(pointsRequired);
    });

    it('should throw an error if user not found', async () => {
      const userId = 'nonexistent-user';
      const rewardId = 'reward1';
      const pointsRequired = 500;

      mockUserRepository.findOne.mockResolvedValue(null);

      await expect(service.redeemPoints(userId, rewardId, pointsRequired)).rejects.toThrow(
        'User not found',
      );
    });

    it('should throw an error if insufficient points', async () => {
      const userId = 'test-user-id';
      const rewardId = 'reward1';
      const pointsRequired = 1500;

      const mockUser = {
        id: userId,
        loyaltyPoints: 1000,
      };

      mockUserRepository.findOne.mockResolvedValue(mockUser);

      await expect(service.redeemPoints(userId, rewardId, pointsRequired)).rejects.toThrow(
        'Insufficient points',
      );
    });
  });

  // Test for getAvailableRewards method
  describe('getAvailableRewards', () => {
    it('should return available rewards for a user', async () => {
      const userId = 'test-user-id';
      const mockUser = {
        id: userId,
        loyaltyPoints: 1000,
      };

      mockUserRepository.findOne.mockResolvedValue(mockUser);

      const result = await service.getAvailableRewards(userId);

      expect(result).toBeDefined();
      expect(result).toBeInstanceOf(Array);
      expect(result.length).toBeGreaterThan(0);
      expect(result[0]).toHaveProperty('id');
      expect(result[0]).toHaveProperty('name');
      expect(result[0]).toHaveProperty('pointsRequired');
      expect(result[0]).toHaveProperty('available');
    });

    it('should throw an error if user not found', async () => {
      const userId = 'nonexistent-user';
      mockUserRepository.findOne.mockResolvedValue(null);

      await expect(service.getAvailableRewards(userId)).rejects.toThrow(
        'Failed to get available rewards',
      );
    });
  });
});
