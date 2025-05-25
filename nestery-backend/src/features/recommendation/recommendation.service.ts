import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { PropertyEntity } from '../../properties/entities/property.entity';
import { UserEntity } from '../../users/entities/user.entity';
import { BookingEntity } from '../../bookings/entities/booking.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

@Injectable()
export class RecommendationService {
  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    @InjectRepository(PropertyEntity)
    private readonly propertyRepository: Repository<PropertyEntity>,
    @InjectRepository(BookingEntity)
    private readonly bookingRepository: Repository<BookingEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
  ) {
    this.logger.setContext('RecommendationService');
  }

  /**
   * Get personalized property recommendations for a user
   */
  async getRecommendationsForUser(userId: string, limit: number = 10): Promise<PropertyEntity[]> {
    try {
      this.logger.debug(`Getting recommendations for user: ${userId}`);

      // Get user's booking history
      const userBookings = await this.bookingRepository.find({
        where: { user: { id: userId } },
        relations: ['property'],
      });

      // If user has no booking history, return trending properties
      if (userBookings.length === 0) {
        this.logger.debug(`No booking history for user ${userId}, returning trending properties`);
        return this.getTrendingProperties(limit);
      }

      // Extract user preferences from booking history
      const userPreferences = this.extractUserPreferences(userBookings);

      // Get properties matching user preferences
      const recommendedProperties = await this.getPropertiesMatchingPreferences(userPreferences, limit);

      return recommendedProperties;
    } catch (error) {
      this.logger.error(`Error getting recommendations for user: ${error.message}`, error.stack);
      // Fallback to trending properties on error
      return this.getTrendingProperties(limit);
    }
  }

  /**
   * Get similar properties to a specific property
   */
  async getSimilarProperties(propertyId: string, limit: number = 5): Promise<PropertyEntity[]> {
    try {
      this.logger.debug(`Getting similar properties to: ${propertyId}`);

      // Get the reference property
      const property = await this.propertyRepository.findOne({
        where: { id: propertyId },
      });

      if (!property) {
        throw new Error(`Property with ID ${propertyId} not found`);
      }

      // Find properties with similar characteristics
      const similarProperties = await this.propertyRepository
        .createQueryBuilder('property')
        .where('property.id != :propertyId', { propertyId })
        .andWhere('property.city = :city', { city: property.city })
        .andWhere('property.propertyType = :propertyType', { propertyType: property.propertyType })
        .andWhere('property.price BETWEEN :minPrice AND :maxPrice', {
          minPrice: property.price * 0.7,
          maxPrice: property.price * 1.3,
        })
        .orderBy('property.rating', 'DESC')
        .limit(limit)
        .getMany();

      return similarProperties;
    } catch (error) {
      this.logger.error(`Error getting similar properties: ${error.message}`, error.stack);
      return [];
    }
  }

  /**
   * Get trending properties based on recent bookings and ratings
   */
  async getTrendingProperties(limit: number = 10): Promise<PropertyEntity[]> {
    try {
      this.logger.debug(`Getting trending properties`);

      // Get properties with recent bookings and high ratings
      const trendingProperties = await this.propertyRepository
        .createQueryBuilder('property')
        .leftJoin('property.bookings', 'booking')
        .where('booking.createdAt >= :recentDate', { recentDate: new Date(Date.now() - 30 * 24 * 60 * 60 * 1000) }) // Last 30 days
        .andWhere('property.rating >= :minRating', { minRating: 4.0 })
        .groupBy('property.id')
        .orderBy('COUNT(booking.id)', 'DESC')
        .addOrderBy('property.rating', 'DESC')
        .limit(limit)
        .getMany();

      // If not enough trending properties, supplement with highest-rated properties
      if (trendingProperties.length < limit) {
        const remainingLimit = limit - trendingProperties.length;
        const trendingIds = trendingProperties.map(p => p.id);

        const highRatedProperties = await this.propertyRepository
          .createQueryBuilder('property')
          .where('property.id NOT IN (:...trendingIds)', { trendingIds: trendingIds.length > 0 ? trendingIds : [''] })
          .orderBy('property.rating', 'DESC')
          .limit(remainingLimit)
          .getMany();

        trendingProperties.push(...highRatedProperties);
      }

      return trendingProperties;
    } catch (error) {
      this.logger.error(`Error getting trending properties: ${error.message}`, error.stack);
      
      // Fallback to highest-rated properties on error
      try {
        return await this.propertyRepository
          .createQueryBuilder('property')
          .orderBy('property.rating', 'DESC')
          .limit(limit)
          .getMany();
      } catch (fallbackError) {
        this.logger.error(`Fallback error getting highest-rated properties: ${fallbackError.message}`, fallbackError.stack);
        return [];
      }
    }
  }

  /**
   * Get properties for a specific destination that are currently popular
   */
  async getPopularPropertiesForDestination(destination: string, limit: number = 10): Promise<PropertyEntity[]> {
    try {
      this.logger.debug(`Getting popular properties for destination: ${destination}`);

      // Parse destination (could be city or country)
      const destinationParts = destination.split(',').map(part => part.trim());
      const city = destinationParts[0];
      const country = destinationParts.length > 1 ? destinationParts[1] : null;

      // Build query
      let query = this.propertyRepository
        .createQueryBuilder('property')
        .leftJoin('property.bookings', 'booking')
        .where('property.city = :city', { city });

      if (country) {
        query = query.andWhere('property.country = :country', { country });
      }

      // Get properties with recent bookings and good ratings
      const popularProperties = await query
        .andWhere('booking.createdAt >= :recentDate', { recentDate: new Date(Date.now() - 90 * 24 * 60 * 60 * 1000) }) // Last 90 days
        .groupBy('property.id')
        .orderBy('COUNT(booking.id)', 'DESC')
        .addOrderBy('property.rating', 'DESC')
        .limit(limit)
        .getMany();

      // If not enough popular properties, supplement with properties in that destination
      if (popularProperties.length < limit) {
        const remainingLimit = limit - popularProperties.length;
        const popularIds = popularProperties.map(p => p.id);

        let fallbackQuery = this.propertyRepository
          .createQueryBuilder('property')
          .where('property.city = :city', { city })
          .andWhere('property.id NOT IN (:...popularIds)', { popularIds: popularIds.length > 0 ? popularIds : [''] });

        if (country) {
          fallbackQuery = fallbackQuery.andWhere('property.country = :country', { country });
        }

        const additionalProperties = await fallbackQuery
          .orderBy('property.rating', 'DESC')
          .limit(remainingLimit)
          .getMany();

        popularProperties.push(...additionalProperties);
      }

      return popularProperties;
    } catch (error) {
      this.logger.error(`Error getting popular properties for destination: ${error.message}`, error.stack);
      return [];
    }
  }

  /**
   * Extract user preferences from booking history
   */
  private extractUserPreferences(bookings: BookingEntity[]): {
    cities: { [city: string]: number };
    countries: { [country: string]: number };
    propertyTypes: { [type: string]: number };
    amenities: { [amenity: string]: number };
    priceRange: { min: number; max: number; avg: number };
    ratings: number[];
  } {
    const preferences = {
      cities: {},
      countries: {},
      propertyTypes: {},
      amenities: {},
      priceRange: { min: Infinity, max: 0, avg: 0 },
      ratings: [],
    };

    let totalPrice = 0;

    for (const booking of bookings) {
      const property = booking.property;

      // Count cities
      preferences.cities[property.city] = (preferences.cities[property.city] || 0) + 1;

      // Count countries
      preferences.countries[property.country] = (preferences.countries[property.country] || 0) + 1;

      // Count property types
      if (property.propertyType) {
        preferences.propertyTypes[property.propertyType] = (preferences.propertyTypes[property.propertyType] || 0) + 1;
      }

      // Count amenities
      if (property.amenities && Array.isArray(property.amenities)) {
        for (const amenity of property.amenities) {
          preferences.amenities[amenity] = (preferences.amenities[amenity] || 0) + 1;
        }
      }

      // Track price range
      if (property.price) {
        preferences.priceRange.min = Math.min(preferences.priceRange.min, property.price);
        preferences.priceRange.max = Math.max(preferences.priceRange.max, property.price);
        totalPrice += property.price;
      }

      // Track ratings
      if (property.rating) {
        preferences.ratings.push(property.rating);
      }
    }

    // Calculate average price
    preferences.priceRange.avg = totalPrice / bookings.length;

    // Handle case where no prices were found
    if (preferences.priceRange.min === Infinity) {
      preferences.priceRange.min = 0;
    }

    return preferences;
  }

  /**
   * Get properties matching user preferences
   */
  private async getPropertiesMatchingPreferences(
    preferences: {
      cities: { [city: string]: number };
      countries: { [country: string]: number };
      propertyTypes: { [type: string]: number };
      amenities: { [amenity: string]: number };
      priceRange: { min: number; max: number; avg: number };
      ratings: number[];
    },
    limit: number
  ): Promise<PropertyEntity[]> {
    // Get top preferences
    const topCities = this.getTopKeys(preferences.cities, 3);
    const topCountries = this.getTopKeys(preferences.countries, 3);
    const topPropertyTypes = this.getTopKeys(preferences.propertyTypes, 3);
    const topAmenities = this.getTopKeys(preferences.amenities, 5);

    // Calculate preferred price range (±30% from average)
    const minPrice = preferences.priceRange.avg * 0.7;
    const maxPrice = preferences.priceRange.avg * 1.3;

    // Calculate average rating
    const avgRating = preferences.ratings.length > 0
      ? preferences.ratings.reduce((sum, rating) => sum + rating, 0) / preferences.ratings.length
      : 0;

    // Build query to find matching properties
    let query = this.propertyRepository
      .createQueryBuilder('property')
      .where('(property.city IN (:...topCities) OR property.country IN (:...topCountries))', {
        topCities,
        topCountries,
      });

    if (topPropertyTypes.length > 0) {
      query = query.andWhere('property.propertyType IN (:...topPropertyTypes)', { topPropertyTypes });
    }

    if (avgRating > 0) {
      query = query.andWhere('property.rating >= :minRating', { minRating: Math.max(avgRating - 0.5, 0) });
    }

    if (preferences.priceRange.avg > 0) {
      query = query.andWhere('property.price BETWEEN :minPrice AND :maxPrice', { minPrice, maxPrice });
    }

    // This is a simplified approach for amenities; in a real implementation, you would use a more sophisticated query
    // to match amenities, possibly with a JSON contains operator or a separate amenities table
    if (topAmenities.length > 0) {
      query = query.andWhere(`property.amenities @> ARRAY[:...topAmenities]::varchar[]`, { topAmenities });
    }

    // Get matching properties
    const matchingProperties = await query
      .orderBy('property.rating', 'DESC')
      .limit(limit)
      .getMany();

    return matchingProperties;
  }

  /**
   * Get top keys from a frequency map
   */
  private getTopKeys(frequencyMap: { [key: string]: number }, limit: number): string[] {
    return Object.entries(frequencyMap)
      .sort((a, b) => b[1] - a[1])
      .slice(0, limit)
      .map(entry => entry[0]);
  }
}
