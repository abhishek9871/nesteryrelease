import { Test, TestingModule } from '@nestjs/testing';
import { LoyaltyService } from './loyalty.service';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { UserEntity } from '../../users/entities/user.entity';
import { BookingEntity } from '../../bookings/entities/booking.entity';
import { Repository } from 'typeorm';

describe('LoyaltyService', () => {
  let service: LoyaltyService;
  let userRepository: Repository<UserEntity>;
  let bookingRepository: Repository<BookingEntity>;

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

  const mockBookingRepository = {
    find: jest.fn().mockResolvedValue([
      {
        id: 'booking1',
        user: { id: 'user1' },
        property: {
          id: 'property1',
          name: 'Test Property 1',
          price: 150,
          rating: 4.5,
        },
        checkInDate: new Date('2025-06-15'),
        checkOutDate: new Date('2025-06-20'),
        totalAmount: 750,
        createdAt: new Date(),
      },
      {
        id: 'booking2',
        user: { id: 'user1' },
        property: {
          id: 'property2',
          name: 'Test Property 2',
          price: 200,
          rating: 4.8,
        },
        checkInDate: new Date('2025-07-10'),
        checkOutDate: new Date('2025-07-15'),
        totalAmount: 1000,
        createdAt: new Date(),
      },
    ]),
    findOne: jest.fn().mockResolvedValue({
      id: 'booking1',
      user: { id: 'user1' },
      property: {
        id: 'property1',
        name: 'Test Property 1',
        price: 150,
        rating: 4.5,
      },
      checkInDate: new Date('2025-06-15'),
      checkOutDate: new Date('2025-06-20'),
      totalAmount: 750,
      createdAt: new Date(),
    }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        LoyaltyService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn(),
          },
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
    userRepository = module.get<Repository<UserEntity>>(getRepositoryToken(UserEntity));
    bookingRepository = module.get<Repository<BookingEntity>>(getRepositoryToken(BookingEntity));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getLoyaltyStatus', () => {
    it('should return loyalty status and points for a user', async () => {
      const userId = 'user1';

      const result = await service.getLoyaltyStatus(userId);

      expect(result).toBeDefined();
      expect(result.tier).toBeDefined();
      expect(result.points).toBeGreaterThan(0);
      expect(result.nextTier).toBeDefined();
      expect(result.pointsToNextTier).toBeDefined();
      expect(result.benefits).toBeDefined();
      expect(result.benefits.length).toBeGreaterThan(0);
      expect(result.history).toBeDefined();
      expect(bookingRepository.find).toHaveBeenCalledWith({
        where: { user: { id: userId } },
        relations: ['property'],
        order: { createdAt: 'DESC' },
      });
    });

    it('should handle errors gracefully', async () => {
      const userId = 'user1';

      // Mock error
      jest.spyOn(bookingRepository, 'find').mockRejectedValueOnce(new Error('Database error'));

      await expect(service.getLoyaltyStatus(userId)).rejects.toThrow('Failed to get loyalty status');
    });
  });

  describe('awardPointsForBooking', () => {
    it('should award points for a booking', async () => {
      const bookingId = 'booking1';

      const result = await service.awardPointsForBooking(bookingId);

      expect(result).toBeDefined();
      expect(result.pointsAwarded).toBeGreaterThan(0);
      expect(result.newTotal).toBeGreaterThan(0);
      expect(result.tier).toBeDefined();
      expect(result.tierChanged).toBeDefined();
      expect(bookingRepository.findOne).toHaveBeenCalledWith({
        where: { id: bookingId },
        relations: ['user', 'property'],
      });
    });

    it('should throw an error if booking not found', async () => {
      const bookingId = 'nonexistent';

      // Mock booking not found
      jest.spyOn(bookingRepository, 'findOne').mockResolvedValueOnce(null);

      await expect(service.awardPointsForBooking(bookingId)).rejects.toThrow(
        `Booking with ID ${bookingId} not found`,
      );
    });

    it('should handle errors gracefully', async () => {
      const bookingId = 'booking1';

      // Mock error
      jest.spyOn(bookingRepository, 'findOne').mockRejectedValueOnce(new Error('Database error'));

      await expect(service.awardPointsForBooking(bookingId)).rejects.toThrow('Failed to award points for booking');
    });
  });

  describe('redeemPoints', () => {
    it('should redeem points for a reward', async () => {
      const userId = 'user1';
      const rewardId = 'reward1';
      const pointsCost = 250;

      const result = await service.redeemPoints(userId, rewardId, pointsCost);

      expect(result).toBeDefined();
      expect(result.success).toBe(true);
      expect(result.remainingPoints).toBeDefined();
      expect(result.reward).toBeDefined();
      expect(result.reward.id).toBe(rewardId);
      expect(result.reward.name).toBeDefined();
      expect(result.reward.description).toBeDefined();
      expect(result.reward.pointsCost).toBe(pointsCost);
    });

    it('should throw an error if user has insufficient points', async () => {
      const userId = 'user1';
      const rewardId = 'reward1';
      const pointsCost = 10000; // Very high cost

      await expect(service.redeemPoints(userId, rewardId, pointsCost)).rejects.toThrow('Insufficient points');
    });

    it('should handle errors gracefully', async () => {
      const userId = 'user1';
      const rewardId = 'nonexistent';
      const pointsCost = 250;

      await expect(service.redeemPoints(userId, rewardId, pointsCost)).rejects.toThrow('Failed to redeem points');
    });
  });

  describe('getAvailableRewards', () => {
    it('should return available rewards for a user', async () => {
      const userId = 'user1';

      const result = await service.getAvailableRewards(userId);

      expect(result).toBeDefined();
      expect(result.length).toBeGreaterThan(0);
      expect(result[0].id).toBeDefined();
      expect(result[0].name).toBeDefined();
      expect(result[0].description).toBeDefined();
      expect(result[0].pointsCost).toBeDefined();
      expect(result[0].canRedeem).toBeDefined();
    });

    it('should handle errors gracefully', async () => {
      const userId = 'user1';

      // Mock error
      jest.spyOn(service as any, 'calculateTotalPoints').mockRejectedValueOnce(new Error('Database error'));

      await expect(service.getAvailableRewards(userId)).rejects.toThrow('Failed to get available rewards');
    });
  });
});
