import { Test, TestingModule } from '@nestjs/testing';
import { PricePredictionService } from './price-prediction.service';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { PropertyEntity } from '../../properties/entities/property.entity';
import { BookingEntity } from '../../bookings/entities/booking.entity';
import { Repository } from 'typeorm';

describe('PricePredictionService', () => {
  let service: PricePredictionService;
  let propertyRepository: Repository<PropertyEntity>;
  let bookingRepository: Repository<BookingEntity>;

  const mockPropertyRepository = {
    createQueryBuilder: jest.fn(() => ({
      where: jest.fn().mockReturnThis(),
      andWhere: jest.fn().mockReturnThis(),
      limit: jest.fn().mockReturnThis(),
      getMany: jest.fn().mockResolvedValue([
        {
          id: 'property1',
          name: 'Test Property 1',
          city: 'New York',
          country: 'US',
          price: 150,
          rating: 4.5,
          amenities: ['wifi', 'pool', 'gym'],
          propertyType: 'hotel',
        },
        {
          id: 'property2',
          name: 'Test Property 2',
          city: 'New York',
          country: 'US',
          price: 200,
          rating: 4.8,
          amenities: ['wifi', 'pool', 'spa'],
          propertyType: 'hotel',
        },
      ]),
      getCount: jest.fn().mockResolvedValue(10),
    })),
    findOne: jest.fn(),
  };

  const mockBookingRepository = {
    createQueryBuilder: jest.fn(() => ({
      innerJoin: jest.fn().mockReturnThis(),
      where: jest.fn().mockReturnThis(),
      andWhere: jest.fn().mockReturnThis(),
      getCount: jest.fn().mockResolvedValue(5),
    })),
    find: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PricePredictionService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key) => {
              if (key === 'GOOGLE_MAPS_API_KEY') return 'test-api-key';
              return null;
            }),
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
          provide: getRepositoryToken(PropertyEntity),
          useValue: mockPropertyRepository,
        },
        {
          provide: getRepositoryToken(BookingEntity),
          useValue: mockBookingRepository,
        },
      ],
    }).compile();

    service = module.get<PricePredictionService>(PricePredictionService);
    propertyRepository = module.get<Repository<PropertyEntity>>(getRepositoryToken(PropertyEntity));
    bookingRepository = module.get<Repository<BookingEntity>>(getRepositoryToken(BookingEntity));
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('predictPrice', () => {
    it('should predict price based on various factors', async () => {
      const params = {
        city: 'New York',
        country: 'US',
        checkInDate: new Date('2025-06-15'),
        checkOutDate: new Date('2025-06-20'),
        guestCount: 2,
        amenities: ['wifi', 'pool'],
        propertyType: 'hotel',
      };

      const result = await service.predictPrice(params);

      expect(result).toBeDefined();
      expect(result.predictedPrice).toBeGreaterThan(0);
      expect(result.currency).toBe('USD');
      expect(result.confidence).toBeGreaterThan(0);
      expect(result.confidence).toBeLessThanOrEqual(1);
      expect(result.priceRange).toBeDefined();
      expect(result.priceRange.min).toBeLessThan(result.priceRange.max);
      expect(result.factors).toHaveLength(4);
    });

    it('should handle errors gracefully', async () => {
      // Mock the repository to throw an error
      jest.spyOn(propertyRepository, 'createQueryBuilder').mockImplementation(() => {
        throw new Error('Database error');
      });

      const params = {
        city: 'New York',
        country: 'US',
        checkInDate: new Date('2025-06-15'),
        checkOutDate: new Date('2025-06-20'),
        guestCount: 2,
      };

      await expect(service.predictPrice(params)).rejects.toThrow('Failed to predict price');
    });
  });
});
