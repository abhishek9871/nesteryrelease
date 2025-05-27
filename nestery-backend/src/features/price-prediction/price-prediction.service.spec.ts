import { Test, TestingModule } from '@nestjs/testing';
import { PricePredictionService } from './price-prediction.service';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';
import { ConfigService } from '@nestjs/config';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Property } from '../../properties/entities/property.entity';

describe('PricePredictionService', () => {
  let service: PricePredictionService;
  let mockPropertyRepository: jest.Mocked<any>;

  beforeEach(async () => {
    mockPropertyRepository = {
      find: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PricePredictionService,
        {
          provide: LoggerService,
          useValue: {
            setContext: jest.fn(),
            debug: jest.fn(),
            error: jest.fn(),
          },
        },
        {
          provide: ExceptionService,
          useValue: {
            handleException: jest.fn(),
          },
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn(),
          },
        },
        {
          provide: getRepositoryToken(Property),
          useValue: mockPropertyRepository,
        },
      ],
    }).compile();

    service = module.get<PricePredictionService>(PricePredictionService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('predictPrice', () => {
    it('should predict price for a property', async () => {
      const params = {
        propertyType: 'apartment',
        bedrooms: 2,
        bathrooms: 1,
        maxGuests: 4,
        city: 'New York',
        country: 'US',
        amenities: ['wifi', 'pool', 'gym'],
        latitude: 40.7128,
        longitude: -74.006,
      };

      const mockProperties = [
        {
          id: 'property1',
          pricePerNight: 150,
          rating: 4.5,
        },
        {
          id: 'property2',
          pricePerNight: 180,
          rating: 4.8,
        },
      ];

      mockPropertyRepository.find.mockResolvedValue(mockProperties);

      const result = await service.predictPrice(params);

      expect(result).toBeDefined();
      expect(result.predictedPrice).toBeGreaterThan(0);
      expect(result.confidence).toBeGreaterThan(0);
      expect(result.priceRange.min).toBeLessThan(result.predictedPrice);
      expect(result.priceRange.max).toBeGreaterThan(result.predictedPrice);
      expect(result.factors).toBeDefined();
    });

    it('should throw an error with invalid parameters', async () => {
      const params = {
        propertyType: 'apartment',
        bedrooms: 2,
        bathrooms: 1,
        maxGuests: 4,
        city: '', // Missing required field
        country: 'US',
        amenities: ['wifi', 'pool', 'gym'],
      };

      await expect(
        service.predictPrice(params as Parameters<typeof service.predictPrice>[0]),
      ).rejects.toThrow('Failed to predict price');
    });
  });
});
