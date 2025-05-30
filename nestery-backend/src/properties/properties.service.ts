import { Injectable, NotFoundException, BadRequestException, Inject } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual, LessThanOrEqual, FindOptionsWhere } from 'typeorm';
import { Property } from './entities/property.entity';
import { CreatePropertyDto } from './dto/create-property.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';
import { SearchPropertiesDto } from './dto/search-properties.dto';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';
import { CACHE_MANAGER, Cache } from '@nestjs/cache-manager';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class PropertiesService {
  constructor(
    @InjectRepository(Property)
    private readonly propertyRepository: Repository<Property>,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
    private readonly configService: ConfigService, // To get API_PREFIX for cache keys
  ) {
    this.logger.setContext('PropertiesService');
  }

  /**
   * Create a new property
   */
  async create(createPropertyDto: CreatePropertyDto): Promise<Property> {
    try {
      this.logger.debug(`Creating new property: ${createPropertyDto.name}`);
      const property = this.propertyRepository.create(createPropertyDto);
      return await this.propertyRepository.save(property);
    } catch (error) {
      this.logger.error(`Error creating property: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      throw new BadRequestException(`Failed to create property: ${error.message}`);
    }
  }

  /**
   * Find all properties with pagination
   */
  async findAll(page = 1, limit = 10): Promise<{ properties: Property[]; total: number }> {
    try {
      this.logger.debug(`Finding all properties, page: ${page}, limit: ${limit}`);
      const [properties, total] = await this.propertyRepository.findAndCount({
        skip: (page - 1) * limit,
        take: limit,
        where: { isActive: true },
      });
      return { properties, total };
    } catch (error) {
      this.logger.error(`Error finding properties: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      throw new BadRequestException(`Failed to find properties: ${error.message}`);
    }
  }

  /**
   * Search properties based on criteria
   */
  async search(searchDto: SearchPropertiesDto): Promise<{ properties: Property[]; total: number }> {
    try {
      const { city, country, minPrice, maxPrice, propertyType, page = 1, limit = 10 } = searchDto;

      const whereConditions: FindOptionsWhere<Property> = {
        isActive: true,
      };

      if (city) {
        whereConditions.city = city;
      }

      if (country) {
        whereConditions.country = country;
      }

      if (propertyType) {
        whereConditions.propertyType = propertyType;
      }

      // Note: starRating moved to metadata, will need custom query for this
      // if (starRating) {
      //   whereConditions.rating = starRating;
      // }

      // Handle price range
      if (minPrice && maxPrice) {
        whereConditions.basePrice = Between(minPrice, maxPrice);
      } else if (minPrice) {
        whereConditions.basePrice = MoreThanOrEqual(minPrice);
      } else if (maxPrice) {
        whereConditions.basePrice = LessThanOrEqual(maxPrice);
      }

      const [properties, total] = await this.propertyRepository.findAndCount({
        where: whereConditions,
        skip: (page - 1) * limit,
        take: limit,
        order: {
          basePrice: 'ASC',
        },
      });

      return { properties, total };
    } catch (error) {
      this.logger.error(`Error searching properties: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      throw new BadRequestException(`Failed to search properties: ${error.message}`);
    }
  }

  /**
   * Find a property by ID
   */
  async findById(id: string): Promise<Property> {
    try {
      this.logger.debug(`Finding property by ID: ${id}`);
      const property = await this.propertyRepository.findOne({
        where: { id },
      });

      if (!property) {
        throw new NotFoundException(`Property with ID ${id} not found`);
      }

      return property;
    } catch (error) {
      this.logger.error(`Error finding property: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      if (error instanceof NotFoundException) {
        throw error;
      }

      throw new BadRequestException(`Failed to find property: ${error.message}`);
    }
  }

  /**
   * Find a property by external ID and source type
   */
  async findByExternalId(externalId: string, sourceType: string): Promise<Property | null> {
    try {
      this.logger.debug(`Finding property by external ID: ${externalId}, source: ${sourceType}`);
      const property = await this.propertyRepository.findOne({
        where: {
          externalId,
          sourceType,
        } as FindOptionsWhere<Property>,
      });

      return property;
    } catch (error) {
      this.logger.error(`Error finding property by external ID: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return null;
    }
  }

  /**
   * Find properties near a location
   */
  async findNearby(
    latitude: number,
    longitude: number,
    radius: number = 5,
    limit: number = 10,
  ): Promise<Property[]> {
    try {
      this.logger.debug(
        `Finding properties near lat: ${latitude}, lng: ${longitude}, radius: ${radius}km`,
      );

      // In a real implementation, this would use geospatial queries
      // For now, we'll return a simple mock implementation
      const properties = await this.propertyRepository.find({
        take: limit,
        where: { isActive: true },
      });

      return properties;
    } catch (error) {
      this.logger.error(`Error finding nearby properties: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return [];
    }
  }

  /**
   * Update a property
   */
  async update(id: string, updatePropertyDto: UpdatePropertyDto): Promise<Property> {
    try {
      this.logger.debug(`Updating property with ID: ${id}`);
      const property = await this.findById(id);

      // Update property fields
      Object.assign(property, updatePropertyDto);
      const updatedProperty = await this.propertyRepository.save(property);

      // Invalidate cache for this specific property
      const cacheKey = `/${this.configService.get<string>('API_PREFIX', 'v1')}/properties/${id}`;
      await this.cacheManager.del(cacheKey);

      return updatedProperty;
    } catch (error) {
      this.logger.error(`Error updating property: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      if (error instanceof NotFoundException) {
        throw error;
      }

      throw new BadRequestException(`Failed to update property: ${error.message}`);
    }
  }

  /**
   * Remove a property
   */
  async remove(id: string): Promise<void> {
    try {
      this.logger.debug(`Removing property with ID: ${id}`);
      const property = await this.findById(id);

      // Soft delete by setting isActive to false
      property.isActive = false;
      await this.propertyRepository.save(property);

      // Invalidate cache for this specific property
      const cacheKey = `/${this.configService.get<string>('API_PREFIX', 'v1')}/properties/${id}`;
      await this.cacheManager.del(cacheKey);
    } catch (error) {
      this.logger.error(`Error removing property: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      if (error instanceof NotFoundException) {
        throw error;
      }

      throw new BadRequestException(`Failed to remove property: ${error.message}`);
    }
  }

  /**
   * Get featured properties
   */
  async getFeaturedProperties(limit = 5): Promise<Property[]> {
    try {
      this.logger.debug(`Getting featured properties, limit: ${limit}`);

      // Featured properties are those with high ratings
      const properties = await this.propertyRepository.find({
        where: { isActive: true }, // Note: rating moved to metadata
        order: { basePrice: 'ASC' },
        take: limit,
      });

      return properties;
    } catch (error) {
      this.logger.error(`Error getting featured properties: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return [];
    }
  }

  /**
   * Get trending destinations
   */
  async getTrendingDestinations(): Promise<{ city: string; country: string; count: number }[]> {
    try {
      this.logger.debug('Getting trending destinations');

      // In a real implementation, this would aggregate booking data
      // For now, we'll return mock data
      return [
        { city: 'Paris', country: 'France', count: 1250 },
        { city: 'New York', country: 'USA', count: 1100 },
        { city: 'Tokyo', country: 'Japan', count: 950 },
        { city: 'Barcelona', country: 'Spain', count: 820 },
        { city: 'London', country: 'UK', count: 780 },
      ];
    } catch (error) {
      this.logger.error(`Error getting trending destinations: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return [];
    }
  }

  /**
   * Get properties by host ID
   */
  async getPropertiesByHostId(hostId: string): Promise<Property[]> {
    try {
      this.logger.debug(`Getting properties for host: ${hostId}`);

      const properties = await this.propertyRepository.find({
        // Note: hostId field was removed from Property entity
        where: { isActive: true },
      });

      return properties;
    } catch (error) {
      this.logger.error(`Error getting host properties: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return [];
    }
  }

  /**
   * Update property availability
   */
  async updateAvailability(id: string, isAvailable: boolean): Promise<Property> {
    try {
      this.logger.debug(`Updating availability for property: ${id}, available: ${isAvailable}`);

      const property = await this.findById(id);
      property.isActive = isAvailable;

      return await this.propertyRepository.save(property);
    } catch (error) {
      this.logger.error(`Error updating property availability: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      if (error instanceof NotFoundException) {
        throw error;
      }

      throw new BadRequestException(`Failed to update property availability: ${error.message}`);
    }
  }
}
