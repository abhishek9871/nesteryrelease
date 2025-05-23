import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Like } from 'typeorm';
import { Property } from './entities/property.entity';
import { CreatePropertyDto } from './dto/create-property.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';
import { SearchPropertiesDto } from './dto/search-properties.dto';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';
import { UtilsService } from '../core/utils/utils.service';

/**
 * Service handling property-related operations
 */
@Injectable()
export class PropertiesService {
  constructor(
    @InjectRepository(Property)
    private readonly propertiesRepository: Repository<Property>,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
    private readonly utilsService: UtilsService,
  ) {
    this.logger.setContext('PropertiesService');
  }

  /**
   * Create a new property
   */
  async create(createPropertyDto: CreatePropertyDto): Promise<Property> {
    try {
      const property = this.propertiesRepository.create(createPropertyDto);
      return await this.propertiesRepository.save(property);
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Find all properties with optional pagination
   */
  async findAll(page: number = 1, limit: number = 10): Promise<{ properties: Property[]; total: number }> {
    try {
      const [properties, total] = await this.propertiesRepository.findAndCount({
        skip: (page - 1) * limit,
        take: limit,
        order: {
          createdAt: 'DESC',
        },
      });

      return { properties, total };
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Search properties based on criteria
   */
  async search(searchDto: SearchPropertiesDto): Promise<{ properties: Property[]; total: number }> {
    try {
      const { city, country, minPrice, maxPrice, propertyType, starRating, page = 1, limit = 10 } = searchDto;

      // Build query conditions
      const whereConditions: any = {};

      if (city) {
        whereConditions.city = Like(`%${city}%`);
      }

      if (country) {
        whereConditions.country = Like(`%${country}%`);
      }

      if (propertyType) {
        whereConditions.propertyType = propertyType;
      }

      if (starRating) {
        whereConditions.starRating = starRating;
      }

      // Price range conditions
      if (minPrice !== undefined && maxPrice !== undefined) {
        whereConditions.basePrice = Between(minPrice, maxPrice);
      } else if (minPrice !== undefined) {
        whereConditions.basePrice = MoreThanOrEqual(minPrice);
      } else if (maxPrice !== undefined) {
        whereConditions.basePrice = LessThanOrEqual(maxPrice);
      }

      // Execute query with pagination
      const [properties, total] = await this.propertiesRepository.findAndCount({
        where: whereConditions,
        skip: (page - 1) * limit,
        take: limit,
        order: {
          basePrice: 'ASC',
        },
      });

      return { properties, total };
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Find a property by ID
   */
  async findById(id: string): Promise<Property> {
    try {
      const property = await this.propertiesRepository.findOne({ where: { id } });
      if (!property) {
        throw new NotFoundException(`Property with ID ${id} not found`);
      }
      return property;
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Find properties by external ID and source type
   */
  async findByExternalId(externalId: string, sourceType: string): Promise<Property | null> {
    try {
      return await this.propertiesRepository.findOne({
        where: { externalId, sourceType },
      });
    } catch (error) {
      this.exceptionService.handleException(error);
      return null;
    }
  }

  /**
   * Update a property
   */
  async update(id: string, updatePropertyDto: UpdatePropertyDto): Promise<Property> {
    try {
      const property = await this.findById(id);
      
      // Update property fields
      Object.assign(property, updatePropertyDto);
      
      return await this.propertiesRepository.save(property);
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Remove a property
   */
  async remove(id: string): Promise<void> {
    try {
      const result = await this.propertiesRepository.delete(id);
      if (result.affected === 0) {
        throw new NotFoundException(`Property with ID ${id} not found`);
      }
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Find nearby properties based on coordinates and radius
   */
  async findNearby(
    latitude: number,
    longitude: number,
    radiusKm: number = 5,
    limit: number = 10,
  ): Promise<Property[]> {
    try {
      // Get all properties (this would be optimized with a spatial query in a real implementation)
      const allProperties = await this.propertiesRepository.find();
      
      // Filter properties by distance
      const nearbyProperties = allProperties
        .map(property => {
          const distance = this.utilsService.calculateDistance(
            latitude,
            longitude,
            property.latitude,
            property.longitude,
          );
          return { property, distance };
        })
        .filter(item => item.distance <= radiusKm)
        .sort((a, b) => a.distance - b.distance)
        .slice(0, limit)
        .map(item => item.property);

      return nearbyProperties;
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }
}
