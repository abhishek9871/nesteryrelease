import { Test, TestingModule } from '@nestjs/testing';
import { PropertiesService } from './properties.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Property } from './entities/property.entity';
import { Repository } from 'typeorm';
import { NotFoundException } from '@nestjs/common';

describe('PropertiesService', () => {
  let service: PropertiesService;
  let repository: Repository<Property>;

  const mockProperty = {
    id: 'test-id',
    name: 'Test Property',
    description: 'A test property',
    type: 'Hotel',
    sourceType: 'booking_com',
    sourceId: 'bcom_123',
    address: '123 Test St',
    city: 'Test City',
    country: 'Test Country',
    latitude: 0.0,
    longitude: 0.0,
    starRating: 4,
    basePrice: 100.0,
    currency: 'USD',
    amenities: ['WiFi', 'Pool'],
    images: ['https://example.com/image.jpg'],
    thumbnailImage: 'https://example.com/thumb.jpg',
    rating: 4.5,
    reviewCount: 100,
    isFeatured: true,
    isPremium: false,
    createdAt: new Date(),
    updatedAt: new Date(),
  };

  const mockPropertiesRepository = {
    find: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    update: jest.fn(),
    delete: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PropertiesService,
        {
          provide: getRepositoryToken(Property),
          useValue: mockPropertiesRepository,
        },
      ],
    }).compile();

    service = module.get<PropertiesService>(PropertiesService);
    repository = module.get<Repository<Property>>(getRepositoryToken(Property));

    // Reset mocks
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('findAll', () => {
    it('should return an array of properties', async () => {
      mockPropertiesRepository.find.mockResolvedValue([mockProperty]);
      
      const result = await service.findAll();
      
      expect(result).toEqual([mockProperty]);
      expect(mockPropertiesRepository.find).toHaveBeenCalled();
    });
  });

  describe('findOne', () => {
    it('should return a property when it exists', async () => {
      mockPropertiesRepository.findOne.mockResolvedValue(mockProperty);
      
      const result = await service.findOne('test-id');
      
      expect(result).toEqual(mockProperty);
      expect(mockPropertiesRepository.findOne).toHaveBeenCalledWith({ where: { id: 'test-id' } });
    });

    it('should throw NotFoundException when property does not exist', async () => {
      mockPropertiesRepository.findOne.mockResolvedValue(null);
      
      await expect(service.findOne('nonexistent-id')).rejects.toThrow(NotFoundException);
      expect(mockPropertiesRepository.findOne).toHaveBeenCalledWith({ where: { id: 'nonexistent-id' } });
    });
  });

  describe('create', () => {
    it('should create and return a new property', async () => {
      const createPropertyDto = {
        name: 'New Property',
        description: 'A new property',
        type: 'Hotel',
        sourceType: 'booking_com',
        sourceId: 'bcom_456',
        address: '456 New St',
        city: 'New City',
        country: 'New Country',
        latitude: 1.0,
        longitude: 1.0,
        starRating: 5,
        basePrice: 200.0,
        currency: 'USD',
        amenities: ['WiFi', 'Pool', 'Spa'],
        images: ['https://example.com/new.jpg'],
        thumbnailImage: 'https://example.com/new_thumb.jpg',
        rating: 4.8,
        reviewCount: 50,
        isFeatured: false,
        isPremium: true,
      };
      
      const newProperty = { ...createPropertyDto, id: 'new-id', createdAt: new Date(), updatedAt: new Date() };
      
      mockPropertiesRepository.create.mockReturnValue(newProperty);
      mockPropertiesRepository.save.mockResolvedValue(newProperty);
      
      const result = await service.create(createPropertyDto);
      
      expect(result).toEqual(newProperty);
      expect(mockPropertiesRepository.create).toHaveBeenCalledWith(createPropertyDto);
      expect(mockPropertiesRepository.save).toHaveBeenCalledWith(newProperty);
    });
  });

  describe('update', () => {
    it('should update and return the property when it exists', async () => {
      const updatePropertyDto = {
        name: 'Updated Property',
        description: 'An updated property',
      };
      
      const updatedProperty = { ...mockProperty, ...updatePropertyDto, updatedAt: new Date() };
      
      mockPropertiesRepository.findOne.mockResolvedValue(mockProperty);
      mockPropertiesRepository.save.mockResolvedValue(updatedProperty);
      
      const result = await service.update('test-id', updatePropertyDto);
      
      expect(result).toEqual(updatedProperty);
      expect(mockPropertiesRepository.findOne).toHaveBeenCalledWith({ where: { id: 'test-id' } });
      expect(mockPropertiesRepository.save).toHaveBeenCalled();
    });

    it('should throw NotFoundException when property does not exist', async () => {
      mockPropertiesRepository.findOne.mockResolvedValue(null);
      
      await expect(service.update('nonexistent-id', { name: 'Updated' })).rejects.toThrow(NotFoundException);
      expect(mockPropertiesRepository.findOne).toHaveBeenCalledWith({ where: { id: 'nonexistent-id' } });
    });
  });

  describe('remove', () => {
    it('should delete the property when it exists', async () => {
      mockPropertiesRepository.findOne.mockResolvedValue(mockProperty);
      mockPropertiesRepository.delete.mockResolvedValue({ affected: 1 });
      
      await service.remove('test-id');
      
      expect(mockPropertiesRepository.findOne).toHaveBeenCalledWith({ where: { id: 'test-id' } });
      expect(mockPropertiesRepository.delete).toHaveBeenCalledWith('test-id');
    });

    it('should throw NotFoundException when property does not exist', async () => {
      mockPropertiesRepository.findOne.mockResolvedValue(null);
      
      await expect(service.remove('nonexistent-id')).rejects.toThrow(NotFoundException);
      expect(mockPropertiesRepository.findOne).toHaveBeenCalledWith({ where: { id: 'nonexistent-id' } });
    });
  });

  describe('search', () => {
    it('should return properties matching search criteria', async () => {
      const searchDto = {
        city: 'Test City',
        checkIn: new Date(),
        checkOut: new Date(new Date().getTime() + 86400000), // Tomorrow
        guests: 2,
        rooms: 1,
      };
      
      mockPropertiesRepository.find.mockResolvedValue([mockProperty]);
      
      const result = await service.search(searchDto);
      
      expect(result).toEqual([mockProperty]);
      expect(mockPropertiesRepository.find).toHaveBeenCalled();
    });

    it('should apply filters correctly', async () => {
      const searchDto = {
        city: 'Test City',
        checkIn: new Date(),
        checkOut: new Date(new Date().getTime() + 86400000), // Tomorrow
        guests: 2,
        rooms: 1,
        type: 'Hotel',
        minPrice: 50,
        maxPrice: 150,
        starRating: 4,
      };
      
      mockPropertiesRepository.find.mockResolvedValue([mockProperty]);
      
      const result = await service.search(searchDto);
      
      expect(result).toEqual([mockProperty]);
      expect(mockPropertiesRepository.find).toHaveBeenCalled();
      // Verify that the query includes all filters
      const queryOptions = mockPropertiesRepository.find.mock.calls[0][0];
      expect(queryOptions.where).toBeDefined();
    });
  });

  describe('getFeaturedProperties', () => {
    it('should return featured properties', async () => {
      mockPropertiesRepository.find.mockResolvedValue([mockProperty]);
      
      const result = await service.getFeaturedProperties();
      
      expect(result).toEqual([mockProperty]);
      expect(mockPropertiesRepository.find).toHaveBeenCalledWith({
        where: { isFeatured: true },
        take: 10,
      });
    });
  });

  describe('getTrendingDestinations', () => {
    it('should return trending destinations', async () => {
      const mockDestinations = [
        { city: 'Test City', country: 'Test Country', count: 10 },
      ];
      
      // Mock the raw query result
      mockPropertiesRepository.query = jest.fn().mockResolvedValue(mockDestinations);
      
      const result = await service.getTrendingDestinations();
      
      expect(result).toEqual(mockDestinations);
      expect(mockPropertiesRepository.query).toHaveBeenCalled();
    });
  });
});
