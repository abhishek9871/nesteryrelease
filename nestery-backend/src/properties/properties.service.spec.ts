import { Test, TestingModule } from '@nestjs/testing';
import { PropertiesService } from './properties.service';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Property } from './entities/property.entity';

describe('PropertiesService', () => {
  let service: PropertiesService;
  let mockPropertyRepository: jest.Mocked<any>;

  beforeEach(async () => {
    mockPropertyRepository = {
      create: jest.fn(),
      save: jest.fn(),
      findOne: jest.fn(),
      find: jest.fn(),
      findAndCount: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PropertiesService,
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
          provide: getRepositoryToken(Property),
          useValue: mockPropertyRepository,
        },
      ],
    }).compile();

    service = module.get<PropertiesService>(PropertiesService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('create', () => {
    it('should create a property', async () => {
      const createPropertyDto = {
        name: 'Test Property',
        description: 'A test property',
        propertyType: 'apartment',
        bedrooms: 2,
        bathrooms: 1,
        maxGuests: 4,
        basePrice: 100,
        city: 'Test City',
        state: 'Test State',
        country: 'Test Country',
        address: 'Test Address',
        zipCode: '12345',
        latitude: 40.7128,
        longitude: -74.006,
        starRating: 4,
        currency: 'USD',
        sourceType: 'internal',
        externalId: 'test-external-id',
      };

      const mockProperty = {
        id: 'test-id',
        ...createPropertyDto,
        createdAt: new Date(),
        updatedAt: new Date(),
        isActive: true,
      };

      mockPropertyRepository.create.mockReturnValue(mockProperty);
      mockPropertyRepository.save.mockResolvedValue(mockProperty);

      const result = await service.create(createPropertyDto);

      expect(result).toBe(mockProperty);
      expect(mockPropertyRepository.create).toHaveBeenCalledWith(createPropertyDto);
      expect(mockPropertyRepository.save).toHaveBeenCalledWith(mockProperty);
    });
  });

  describe('findAll', () => {
    it('should return properties with pagination', async () => {
      const mockProperties = [
        { id: 'property1', name: 'Property 1' },
        { id: 'property2', name: 'Property 2' },
      ];

      mockPropertyRepository.findAndCount.mockResolvedValue([mockProperties, 2]);

      const result = await service.findAll(1, 10);

      expect(result.properties).toBe(mockProperties);
      expect(result.total).toBe(2);
      expect(mockPropertyRepository.findAndCount).toHaveBeenCalledWith({
        skip: 0,
        take: 10,
        where: { isActive: true },
      });
    });
  });

  describe('findById', () => {
    it('should find a property by id', async () => {
      const mockProperty = { id: 'test-id', name: 'Test Property' };
      mockPropertyRepository.findOne.mockResolvedValue(mockProperty);

      const result = await service.findById('test-id');

      expect(result).toBe(mockProperty);
      expect(mockPropertyRepository.findOne).toHaveBeenCalledWith({
        where: { id: 'test-id' },
      });
    });

    it('should throw an error if property not found', async () => {
      mockPropertyRepository.findOne.mockResolvedValue(null);

      await expect(service.findById('nonexistent-id')).rejects.toThrow(Error);
    });
  });

  describe('update', () => {
    it('should update a property', async () => {
      const updatePropertyDto = {
        name: 'Updated Property',
        description: 'An updated property',
      };

      const mockProperty = {
        id: 'test-id',
        name: 'Test Property',
        description: 'A test property',
      };

      const updatedProperty = {
        ...mockProperty,
        ...updatePropertyDto,
      };

      mockPropertyRepository.findOne.mockResolvedValue(mockProperty);
      mockPropertyRepository.save.mockResolvedValue(updatedProperty);

      const result = await service.update('test-id', updatePropertyDto);

      expect(result).toBe(updatedProperty);
      expect(mockPropertyRepository.findOne).toHaveBeenCalledWith({
        where: { id: 'test-id' },
      });
      expect(mockPropertyRepository.save).toHaveBeenCalled();
    });
  });

  describe('remove', () => {
    it('should soft delete a property', async () => {
      const mockProperty = {
        id: 'test-id',
        name: 'Test Property',
        isActive: true,
      };

      mockPropertyRepository.findOne.mockResolvedValue(mockProperty);
      mockPropertyRepository.save.mockResolvedValue({ ...mockProperty, isActive: false });

      await service.remove('test-id');

      expect(mockPropertyRepository.findOne).toHaveBeenCalledWith({
        where: { id: 'test-id' },
      });
      expect(mockPropertyRepository.save).toHaveBeenCalledWith({
        ...mockProperty,
        isActive: false,
      });
    });
  });

  describe('findNearby', () => {
    it('should find properties near a location', async () => {
      const mockProperties = [
        { id: 'property1', name: 'Property 1' },
        { id: 'property2', name: 'Property 2' },
      ];

      mockPropertyRepository.find.mockResolvedValue(mockProperties);

      const result = await service.findNearby(1.0, 1.0, 5, 10);

      expect(result).toBe(mockProperties);
      expect(mockPropertyRepository.find).toHaveBeenCalledWith({
        take: 10,
        where: { isActive: true },
      });
    });
  });

  describe('getFeaturedProperties', () => {
    it('should get featured properties', async () => {
      const mockProperties = [
        { id: 'property1', name: 'Property 1' },
        { id: 'property2', name: 'Property 2' },
      ];

      mockPropertyRepository.find.mockResolvedValue(mockProperties);

      const result = await service.getFeaturedProperties(5);

      expect(result).toBe(mockProperties);
    });
  });

  describe('getTrendingDestinations', () => {
    it('should get trending destinations', async () => {
      const result = await service.getTrendingDestinations();

      expect(result).toBeInstanceOf(Array);
      expect(result.length).toBeGreaterThan(0);
      expect(result[0]).toHaveProperty('city');
      expect(result[0]).toHaveProperty('country');
      expect(result[0]).toHaveProperty('count');
    });
  });
});
