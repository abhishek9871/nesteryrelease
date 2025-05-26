import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, MoreThanOrEqual, LessThanOrEqual } from 'typeorm';
import { Property } from '../../properties/entities/property.entity';
import { User } from '../../users/entities/user.entity';
import { Booking } from '../../bookings/entities/booking.entity';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';

interface PropertyPreferences {
  location: {
    lat: number;
    lng: number;
    radius: number;
  };
  priceRange: {
    min: number;
    max: number;
    avg: number;
  };
  amenities: Record<string, number>;
  propertyTypes: Record<string, number>;
  ratings: number[];
  avgRating: number;
}

@Injectable()
export class RecommendationService {
  constructor(
    @InjectRepository(Property)
    private readonly propertyRepository: Repository<Property>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(Booking)
    private readonly bookingRepository: Repository<Booking>,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    this.logger.setContext('RecommendationService');
  }

  /**
   * Get personalized property recommendations for a user
   */
  async getPersonalizedRecommendations(userId: string, limit: number = 10) {
    try {
      this.logger.debug(`Getting personalized recommendations for user ${userId}`);

      // Get user preferences based on booking history
      const preferences = await this.getUserPreferences(userId);

      if (!preferences) {
        // If no preferences found, return popular properties instead
        return this.getPopularProperties(limit);
      }

      // Find properties that match user preferences
      const recommendations = await this.findMatchingProperties(preferences, limit);

      return {
        success: true,
        recommendations,
        basedOn: 'user_preferences',
      };
    } catch (error) {
      this.logger.error(
        `Error getting personalized recommendations: ${error.message}`,
        error.stack,
      );
      this.exceptionService.handleException(error);

      // Fallback to popular properties
      return this.getPopularProperties(limit);
    }
  }

  /**
   * Alias for getPersonalizedRecommendations to maintain compatibility with tests
   */
  async getRecommendationsForUser(userId: string, limit: number = 10) {
    return this.getPersonalizedRecommendations(userId, limit);
  }

  /**
   * Get similar properties to a given property
   */
  async getSimilarProperties(propertyId: string, limit: number = 5) {
    try {
      this.logger.debug(`Getting similar properties to ${propertyId}`);

      // Get the reference property
      const property = await this.propertyRepository.findOne({
        where: { id: propertyId },
      });

      if (!property) {
        throw new Error(`Property with ID ${propertyId} not found`);
      }

      // Create preferences based on this property
      const preferences: PropertyPreferences = {
        location: {
          lat: property.latitude,
          lng: property.longitude,
          radius: 10, // 10km radius
        },
        priceRange: {
          min: property.pricePerNight * 0.8,
          max: property.pricePerNight * 1.2,
          avg: property.pricePerNight,
        },
        amenities: {},
        propertyTypes: {
          [property.type]: 1,
        },
        ratings: [property.rating || 0],
        avgRating: property.rating || 0,
      };

      // Add amenities
      if (property.amenities && Array.isArray(property.amenities)) {
        for (const amenity of property.amenities) {
          preferences.amenities[amenity] = 1;
        }
      }

      // Find similar properties
      const similarProperties = await this.findMatchingProperties(preferences, limit + 1);

      // Filter out the original property
      const recommendations = similarProperties.filter(p => p.id !== propertyId);

      return {
        success: true,
        recommendations: recommendations.slice(0, limit),
        basedOn: 'similar_property',
      };
    } catch (error) {
      this.logger.error(`Error getting similar properties: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      // Fallback to popular properties
      return this.getPopularProperties(limit);
    }
  }

  /**
   * Get trending properties based on recent bookings and views
   */
  async getTrendingProperties(limit: number = 10) {
    try {
      this.logger.debug(`Getting trending properties, limit: ${limit}`);

      // Get properties with recent bookings (last 7 days)
      const sevenDaysAgo = new Date();
      sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

      const recentBookings = await this.bookingRepository.find({
        where: {
          createdAt: MoreThanOrEqual(sevenDaysAgo),
        },
        relations: ['property'],
      });

      // Count bookings per property
      const bookingCounts: Record<string, number> = {};
      for (const booking of recentBookings) {
        if (booking.property) {
          const propertyId = booking.property.id;
          bookingCounts[propertyId] = (bookingCounts[propertyId] || 0) + 1;
        }
      }

      // Get property IDs sorted by booking count
      const trendingPropertyIds = Object.entries(bookingCounts)
        .sort((a, b) => b[1] - a[1])
        .map(entry => entry[0])
        .slice(0, limit);

      // If we don't have enough trending properties, get popular ones
      if (trendingPropertyIds.length < limit) {
        const popularProperties = await this.getPopularProperties(
          limit - trendingPropertyIds.length,
        );
        return {
          success: true,
          recommendations: [
            ...(await this.propertyRepository.findByIds(trendingPropertyIds)),
            ...popularProperties.recommendations,
          ],
          basedOn: 'trending_and_popular',
        };
      }

      // Get the trending properties
      const trendingProperties = await this.propertyRepository.findByIds(trendingPropertyIds);

      return {
        success: true,
        recommendations: trendingProperties,
        basedOn: 'trending',
      };
    } catch (error) {
      this.logger.error(`Error getting trending properties: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      // Fallback to popular properties
      return this.getPopularProperties(limit);
    }
  }

  /**
   * Get popular properties based on ratings and booking count
   */
  async getPopularProperties(limit: number = 10) {
    try {
      this.logger.debug(`Getting popular properties, limit: ${limit}`);

      // Get properties with high ratings
      const popularProperties = await this.propertyRepository.find({
        where: {
          rating: MoreThanOrEqual(4),
          isActive: true,
        },
        order: {
          rating: 'DESC',
          reviewCount: 'DESC',
        },
        take: limit,
      });

      return {
        success: true,
        recommendations: popularProperties,
        basedOn: 'popularity',
      };
    } catch (error) {
      this.logger.error(`Error getting popular properties: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      // Return empty array as last resort
      return {
        success: false,
        recommendations: [],
        basedOn: 'none',
        error: error.message,
      };
    }
  }

  /**
   * Get popular properties for a specific destination
   * This is an alias method to maintain compatibility with tests
   */
  async getPopularPropertiesForDestination(destination: string, limit: number = 10) {
    try {
      this.logger.debug(
        `Getting popular properties for destination ${destination}, limit: ${limit}`,
      );

      // Get properties in the specified destination with high ratings
      const popularProperties = await this.propertyRepository.find({
        where: {
          city: destination,
          rating: MoreThanOrEqual(4),
          isActive: true,
        },
        order: {
          rating: 'DESC',
          reviewCount: 'DESC',
        },
        take: limit,
      });

      return {
        success: true,
        recommendations: popularProperties,
        basedOn: 'destination_popularity',
        destination,
      };
    } catch (error) {
      this.logger.error(
        `Error getting popular properties for destination: ${error.message}`,
        error.stack,
      );
      this.exceptionService.handleException(error);

      // Return empty array as last resort
      return {
        success: false,
        recommendations: [],
        basedOn: 'none',
        destination,
        error: error.message,
      };
    }
  }

  /**
   * Get user preferences based on booking history
   */
  private async getUserPreferences(userId: string): Promise<PropertyPreferences | null> {
    try {
      // Get user's booking history
      const bookings = await this.bookingRepository.find({
        where: { userId },
        relations: ['property'],
      });

      if (bookings.length === 0) {
        return null;
      }

      // Initialize preferences
      const preferences: PropertyPreferences = {
        location: {
          lat: 0,
          lng: 0,
          radius: 20, // Default 20km radius
        },
        priceRange: {
          min: Number.MAX_VALUE,
          max: 0,
          avg: 0,
        },
        amenities: {},
        propertyTypes: {},
        ratings: [],
        avgRating: 0,
      };

      let totalLat = 0;
      let totalLng = 0;
      let totalPrice = 0;
      let validLocationCount = 0;

      // Analyze booking history
      for (const booking of bookings) {
        const property = booking.property;
        if (!property) continue;

        // Location
        if (property.latitude && property.longitude) {
          totalLat += property.latitude;
          totalLng += property.longitude;
          validLocationCount++;
        }

        // Property type
        if (property.type) {
          preferences.propertyTypes[property.type] =
            (preferences.propertyTypes[property.type] || 0) + 1;
        }

        // Amenities
        if (property.amenities && Array.isArray(property.amenities)) {
          for (const amenity of property.amenities) {
            preferences.amenities[amenity] = (preferences.amenities[amenity] || 0) + 1;
          }
        }

        // Price
        if (property.pricePerNight) {
          preferences.priceRange.min = Math.min(preferences.priceRange.min, property.pricePerNight);
          preferences.priceRange.max = Math.max(preferences.priceRange.max, property.pricePerNight);
          totalPrice += property.pricePerNight;
        }

        // Rating
        if (property.rating) {
          preferences.ratings.push(property.rating);
        }
      }

      // Calculate averages
      if (validLocationCount > 0) {
        preferences.location.lat = totalLat / validLocationCount;
        preferences.location.lng = totalLng / validLocationCount;
      }

      if (bookings.length > 0) {
        preferences.priceRange.avg = totalPrice / bookings.length;
      }

      if (preferences.ratings.length > 0) {
        const sum = preferences.ratings.reduce((a, b) => a + b, 0);
        preferences.avgRating = sum / preferences.ratings.length;
      }

      return preferences;
    } catch (error) {
      this.logger.error(`Error getting user preferences: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return null;
    }
  }

  /**
   * Find properties that match the given preferences
   */
  private async findMatchingProperties(
    preferences: PropertyPreferences,
    limit: number,
  ): Promise<Property[]> {
    try {
      // Build query based on preferences
      const query = this.propertyRepository
        .createQueryBuilder('property')
        .where('property.isActive = :isActive', { isActive: true });

      // Location filter (if valid)
      if (preferences.location.lat !== 0 && preferences.location.lng !== 0) {
        // Using Haversine formula to calculate distance
        query.andWhere(
          `
          (6371 * acos(cos(radians(:lat)) * cos(radians(property.latitude)) * 
          cos(radians(property.longitude) - radians(:lng)) + 
          sin(radians(:lat)) * sin(radians(property.latitude)))) < :radius
        `,
          {
            lat: preferences.location.lat,
            lng: preferences.location.lng,
            radius: preferences.location.radius,
          },
        );
      }

      // Price range filter
      if (preferences.priceRange.min < Number.MAX_VALUE && preferences.priceRange.max > 0) {
        // Add some flexibility to the price range
        const minPrice = preferences.priceRange.min * 0.8;
        const maxPrice = preferences.priceRange.max * 1.2;

        query.andWhere('property.pricePerNight BETWEEN :minPrice AND :maxPrice', {
          minPrice,
          maxPrice,
        });
      }

      // Property type filter (if we have preferences)
      if (Object.keys(preferences.propertyTypes).length > 0) {
        const preferredTypes = Object.keys(preferences.propertyTypes);
        query.andWhere('property.type IN (:...types)', { types: preferredTypes });
      }

      // Rating filter (if we have ratings)
      if (preferences.avgRating > 0) {
        // Look for properties with similar or better ratings
        query.andWhere('property.rating >= :minRating', {
          minRating: Math.max(3.5, preferences.avgRating - 0.5),
        });
      }

      // Order by relevance (we could implement a more sophisticated scoring system here)
      query.orderBy('property.rating', 'DESC');

      // Limit results
      query.take(limit);

      return await query.getMany();
    } catch (error) {
      this.logger.error(`Error finding matching properties: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return [];
    }
  }
}
