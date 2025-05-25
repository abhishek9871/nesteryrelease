import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { PropertyEntity } from '../../properties/entities/property.entity';
import { UserEntity } from '../../users/entities/user.entity';
import { BookingEntity } from '../../bookings/entities/booking.entity';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';

@Injectable()
export class PricePredictionService {
  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    @InjectRepository(PropertyEntity)
    private readonly propertyRepository: Repository<PropertyEntity>,
    @InjectRepository(BookingEntity)
    private readonly bookingRepository: Repository<BookingEntity>,
  ) {
    this.logger.setContext('PricePredictionService');
  }

  /**
   * Predict price for a property based on various factors
   */
  async predictPrice(params: {
    propertyId?: string;
    city: string;
    country: string;
    checkInDate: Date;
    checkOutDate: Date;
    guestCount: number;
    amenities?: string[];
    propertyType?: string;
    rating?: number;
  }): Promise<{
    predictedPrice: number;
    currency: string;
    confidence: number;
    priceRange: { min: number; max: number };
    factors: Array<{ name: string; impact: number }>;
  }> {
    try {
      this.logger.debug(`Predicting price for property in ${params.city}, ${params.country}`);

      // Calculate number of nights
      const nights = this.calculateNights(params.checkInDate, params.checkOutDate);
      
      // Get historical price data for similar properties
      const similarProperties = await this.getSimilarProperties(params);
      
      // Calculate base price from similar properties
      const basePrice = this.calculateBasePrice(similarProperties);
      
      // Apply seasonal adjustments
      const seasonalFactor = this.calculateSeasonalFactor(params.city, params.country, params.checkInDate);
      
      // Apply demand adjustments
      const demandFactor = await this.calculateDemandFactor(params.city, params.country, params.checkInDate, params.checkOutDate);
      
      // Apply amenities adjustments
      const amenitiesFactor = this.calculateAmenitiesFactor(params.amenities);
      
      // Apply guest count adjustments
      const guestFactor = this.calculateGuestFactor(params.guestCount);
      
      // Calculate final predicted price
      const predictedPrice = basePrice * seasonalFactor * demandFactor * amenitiesFactor * guestFactor;
      
      // Calculate confidence score
      const confidence = this.calculateConfidence(similarProperties.length, params.checkInDate);
      
      // Calculate price range
      const priceRange = {
        min: predictedPrice * (1 - (1 - confidence) / 2),
        max: predictedPrice * (1 + (1 - confidence) / 2),
      };
      
      // Compile factors that influenced the price
      const factors = [
        { name: 'Seasonal Demand', impact: seasonalFactor - 1 },
        { name: 'Market Demand', impact: demandFactor - 1 },
        { name: 'Amenities', impact: amenitiesFactor - 1 },
        { name: 'Guest Count', impact: guestFactor - 1 },
      ];
      
      return {
        predictedPrice: Math.round(predictedPrice),
        currency: 'USD', // Default currency
        confidence,
        priceRange: {
          min: Math.round(priceRange.min),
          max: Math.round(priceRange.max),
        },
        factors,
      };
    } catch (error) {
      this.logger.error(`Error predicting price: ${error.message}`, error.stack);
      throw new Error(`Failed to predict price: ${error.message}`);
    }
  }

  /**
   * Get similar properties based on location, type, and amenities
   */
  private async getSimilarProperties(params: {
    propertyId?: string;
    city: string;
    country: string;
    amenities?: string[];
    propertyType?: string;
    rating?: number;
  }): Promise<PropertyEntity[]> {
    try {
      let query = this.propertyRepository
        .createQueryBuilder('property')
        .where('property.city = :city', { city: params.city })
        .andWhere('property.country = :country', { country: params.country });
      
      if (params.propertyId) {
        query = query.andWhere('property.id != :propertyId', { propertyId: params.propertyId });
      }
      
      if (params.propertyType) {
        query = query.andWhere('property.propertyType = :propertyType', { propertyType: params.propertyType });
      }
      
      if (params.rating) {
        query = query.andWhere('property.rating >= :minRating', { minRating: params.rating - 0.5 })
          .andWhere('property.rating <= :maxRating', { maxRating: params.rating + 0.5 });
      }
      
      // Get properties with at least 50% matching amenities if amenities are provided
      if (params.amenities && params.amenities.length > 0) {
        const amenitiesCount = params.amenities.length;
        const minMatchingAmenities = Math.ceil(amenitiesCount * 0.5);
        
        // This is a simplified approach; in a real implementation, you would use a more sophisticated query
        // to match amenities, possibly with a JSON contains operator or a separate amenities table
        query = query.andWhere(`property.amenities @> ARRAY[:...amenities]::varchar[]`, { amenities: params.amenities });
      }
      
      return await query.limit(20).getMany();
    } catch (error) {
      this.logger.error(`Error getting similar properties: ${error.message}`, error.stack);
      return [];
    }
  }

  /**
   * Calculate base price from similar properties
   */
  private calculateBasePrice(similarProperties: PropertyEntity[]): number {
    if (similarProperties.length === 0) {
      return 100; // Default base price if no similar properties found
    }
    
    // Calculate weighted average price based on rating
    let totalWeight = 0;
    let weightedSum = 0;
    
    for (const property of similarProperties) {
      const weight = property.rating || 1;
      totalWeight += weight;
      weightedSum += property.price * weight;
    }
    
    return weightedSum / totalWeight;
  }

  /**
   * Calculate seasonal factor based on location and date
   */
  private calculateSeasonalFactor(city: string, country: string, date: Date): number {
    const month = date.getMonth();
    
    // This is a simplified seasonal model; in a real implementation, you would use
    // a more sophisticated model based on historical data for each location
    
    // Example: Higher prices during summer months (June-August) for northern hemisphere
    if (country === 'US' || country === 'Canada' || country === 'UK' || country === 'France' || country === 'Germany') {
      if (month >= 5 && month <= 7) { // June-August
        return 1.2; // 20% increase
      } else if (month >= 11 || month <= 1) { // December-February
        return 0.9; // 10% decrease
      }
    }
    
    // Example: Higher prices during winter months for ski destinations
    if ((city === 'Aspen' || city === 'Vail' || city === 'Park City') && (month >= 11 || month <= 2)) {
      return 1.4; // 40% increase
    }
    
    // Example: Higher prices during dry season for tropical destinations
    if ((country === 'Thailand' || country === 'Indonesia' || country === 'Malaysia') && (month >= 10 || month <= 3)) {
      return 1.3; // 30% increase
    }
    
    return 1.0; // No seasonal adjustment
  }

  /**
   * Calculate demand factor based on bookings for the location and dates
   */
  private async calculateDemandFactor(city: string, country: string, checkInDate: Date, checkOutDate: Date): Promise<number> {
    try {
      // Get count of bookings for the same city and overlapping dates
      const bookingsCount = await this.bookingRepository
        .createQueryBuilder('booking')
        .innerJoin('booking.property', 'property')
        .where('property.city = :city', { city })
        .andWhere('property.country = :country', { country })
        .andWhere('booking.checkInDate <= :checkOutDate', { checkOutDate })
        .andWhere('booking.checkOutDate >= :checkInDate', { checkInDate })
        .getCount();
      
      // Get count of properties in the city
      const propertiesCount = await this.propertyRepository
        .createQueryBuilder('property')
        .where('property.city = :city', { city })
        .andWhere('property.country = :country', { country })
        .getCount();
      
      if (propertiesCount === 0) {
        return 1.0;
      }
      
      // Calculate occupancy rate
      const occupancyRate = bookingsCount / propertiesCount;
      
      // Adjust price based on occupancy rate
      if (occupancyRate > 0.8) {
        return 1.3; // High demand: 30% increase
      } else if (occupancyRate > 0.6) {
        return 1.15; // Medium-high demand: 15% increase
      } else if (occupancyRate > 0.4) {
        return 1.0; // Medium demand: no change
      } else if (occupancyRate > 0.2) {
        return 0.9; // Medium-low demand: 10% decrease
      } else {
        return 0.8; // Low demand: 20% decrease
      }
    } catch (error) {
      this.logger.error(`Error calculating demand factor: ${error.message}`, error.stack);
      return 1.0; // Default to no adjustment on error
    }
  }

  /**
   * Calculate amenities factor based on available amenities
   */
  private calculateAmenitiesFactor(amenities?: string[]): number {
    if (!amenities || amenities.length === 0) {
      return 1.0;
    }
    
    // Define premium amenities that increase price
    const premiumAmenities = [
      'pool', 'spa', 'gym', 'beach access', 'ocean view', 'mountain view',
      'private balcony', 'jacuzzi', 'sauna', 'concierge', 'room service',
      'free breakfast', 'free wifi', 'parking', 'pet friendly', 'kitchen',
    ];
    
    // Count matching premium amenities
    const matchingPremiumCount = amenities.filter(amenity => 
      premiumAmenities.some(premium => amenity.toLowerCase().includes(premium.toLowerCase()))
    ).length;
    
    // Calculate factor: each premium amenity adds 2% to the price, up to 30%
    const amenitiesFactor = 1 + Math.min(matchingPremiumCount * 0.02, 0.3);
    
    return amenitiesFactor;
  }

  /**
   * Calculate guest factor based on number of guests
   */
  private calculateGuestFactor(guestCount: number): number {
    // First guest is base price
    if (guestCount <= 1) {
      return 1.0;
    }
    
    // Each additional guest adds 15% to the price, with diminishing returns
    return 1.0 + (guestCount - 1) * 0.15 * Math.pow(0.9, guestCount - 2);
  }

  /**
   * Calculate confidence score for the prediction
   */
  private calculateConfidence(similarPropertiesCount: number, checkInDate: Date): number {
    // More similar properties = higher confidence
    const propertiesConfidence = Math.min(similarPropertiesCount / 10, 1);
    
    // Closer dates = higher confidence
    const daysUntilCheckIn = Math.max(0, (checkInDate.getTime() - Date.now()) / (1000 * 60 * 60 * 24));
    const dateConfidence = Math.max(0, 1 - daysUntilCheckIn / 365);
    
    // Combine factors with weights
    return 0.7 * propertiesConfidence + 0.3 * dateConfidence;
  }

  /**
   * Calculate number of nights between two dates
   */
  private calculateNights(checkInDate: Date, checkOutDate: Date): number {
    const diffTime = Math.abs(checkOutDate.getTime() - checkInDate.getTime());
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }
}
