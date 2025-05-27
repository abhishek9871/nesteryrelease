import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Property } from '../../properties/entities/property.entity';

interface PredictionParams {
  propertyType: string;
  bedrooms: number;
  bathrooms: number;
  maxGuests: number;
  city: string;
  country: string;
  amenities: string[];
  latitude?: number;
  longitude?: number;
  seasonality?: string;
}

// Define types for lookup tables to avoid index signature issues
interface PopularDestinations {
  [key: string]: number;
  'New York': number;
  London: number;
  Paris: number;
  Tokyo: number;
  Sydney: number;
  Rome: number;
  Barcelona: number;
  Berlin: number;
  Bangkok: number;
  'Mexico City': number;
}

interface PropertyFactors {
  [key: string]: number;
  luxury_villa: number;
  penthouse: number;
  beachfront: number;
  ski_chalet: number;
  mansion: number;
  house: number;
  apartment: number;
  condo: number;
  cabin: number;
  room: number;
  shared_room: number;
}

@Injectable()
export class PricePredictionService {
  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
    @InjectRepository(Property)
    private readonly propertyRepository: Repository<Property>,
  ) {
    this.logger.setContext('PricePredictionService');
  }

  /**
   * Predict price for a property based on various factors
   */
  async predictPrice(params: PredictionParams): Promise<{
    predictedPrice: number;
    confidence: number;
    priceRange: { min: number; max: number };
    factors: Record<string, number>;
  }> {
    try {
      this.logger.debug(`Predicting price for property in ${params.city}, ${params.country}`);

      // Validate input parameters
      this.validateParams(params);

      // Get historical price data for similar properties
      const similarProperties = await this.getSimilarProperties(params);

      // Calculate base price from similar properties
      const basePrice = this.calculateBasePrice(similarProperties);

      // Apply various adjustment factors
      const locationFactor = await this.calculateLocationFactor(params);
      const seasonalityFactor = this.calculateSeasonalityFactor(params);
      const amenitiesFactor = this.calculateAmenitiesFactor(params.amenities);
      const sizeFactor = this.calculateSizeFactor(params.bedrooms, params.bathrooms);
      const occupancyFactor = this.calculateOccupancyFactor(params.maxGuests);
      const propertyTypeFactor = this.calculatePropertyTypeFactor(params.propertyType);

      // Calculate final predicted price
      const predictedPrice =
        basePrice *
        locationFactor *
        seasonalityFactor *
        amenitiesFactor *
        sizeFactor *
        occupancyFactor *
        propertyTypeFactor;

      // Calculate price range
      const priceRange = {
        min: predictedPrice * 0.85, // 15% below prediction
        max: predictedPrice * 1.15, // 15% above prediction
      };

      // Compile factors that influenced the price
      const factors = {
        basePrice,
        location: locationFactor,
        seasonality: seasonalityFactor,
        amenities: amenitiesFactor,
        size: sizeFactor,
        occupancy: occupancyFactor,
        propertyType: propertyTypeFactor,
      };

      return {
        predictedPrice: Math.round(predictedPrice),
        confidence: 0.85, // Confidence score (could be calculated based on data quality)
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
   * Validate prediction parameters
   */
  private validateParams(params: PredictionParams): void {
    if (!params.propertyType) {
      throw new Error('Property type is required');
    }

    if (!params.city || !params.country) {
      throw new Error('Location information is required');
    }

    if (params.bedrooms < 0 || params.bathrooms < 0 || params.maxGuests < 1) {
      throw new Error('Invalid property specifications');
    }
  }

  /**
   * Get similar properties based on location, type, and size
   */
  private async getSimilarProperties(params: PredictionParams): Promise<Property[]> {
    try {
      return await this.propertyRepository.find({
        where: {
          city: params.city,
          country: params.country,
          propertyType: params.propertyType,
          bedrooms: Between(params.bedrooms - 1, params.bedrooms + 1),
          bathrooms: Between(params.bathrooms - 1, params.bathrooms + 1),
          maxGuests: Between(params.maxGuests - 2, params.maxGuests + 2),
          isActive: true,
        },
        take: 20,
      });
    } catch (error) {
      this.logger.error(`Error getting similar properties: ${error.message}`, error.stack);
      return [];
    }
  }

  /**
   * Calculate base price from similar properties
   */
  private calculateBasePrice(similarProperties: Property[]): number {
    if (!similarProperties || similarProperties.length === 0) {
      return 100; // Default base price if no similar properties found
    }

    // Calculate weighted average price based on rating
    let totalWeight = 0;
    let weightedSum = 0;

    for (const property of similarProperties) {
      // Higher rated properties have more influence on the price
      // Note: rating field was moved to metadata object
      const rating = (property.metadata as any)?.rating || 0;
      const weight = rating ? rating / 5 : 0.5;
      totalWeight += weight;
      weightedSum += property.basePrice * weight;
    }

    return totalWeight > 0 ? weightedSum / totalWeight : 100;
  }

  /**
   * Calculate location factor based on city and country
   */
  private async calculateLocationFactor(params: PredictionParams): Promise<number> {
    // In a real implementation, this would use more sophisticated geospatial analysis
    // For now, we'll use a simple lookup table for popular destinations

    const popularDestinations: PopularDestinations = {
      'New York': 1.5,
      London: 1.4,
      Paris: 1.35,
      Tokyo: 1.3,
      Sydney: 1.25,
      Rome: 1.2,
      Barcelona: 1.15,
      Berlin: 1.1,
      Bangkok: 0.9,
      'Mexico City': 0.85,
    };

    // Use a type-safe lookup with fallback
    return popularDestinations[params.city as keyof PopularDestinations] || 1.0;
  }

  /**
   * Calculate seasonality factor based on current date and location
   */
  private calculateSeasonalityFactor(params: PredictionParams): number {
    const currentMonth = new Date().getMonth(); // 0-11 (Jan-Dec)

    // Example: Higher prices during summer months (June-August) for northern hemisphere
    if (['US', 'Canada', 'UK', 'France', 'Germany', 'Italy', 'Spain'].includes(params.country)) {
      if (currentMonth >= 5 && currentMonth <= 7) {
        // June-August
        return 1.25;
      } else if (currentMonth >= 11 || currentMonth <= 1) {
        // Dec-Feb
        return 0.9;
      }
    }

    // Example: Higher prices during winter months for ski destinations
    if (params.seasonality === 'ski' || params.propertyType === 'ski_chalet') {
      if (currentMonth >= 11 || currentMonth <= 2) {
        // Dec-Mar
        return 1.4;
      }
    }

    // Example: Higher prices during dry season for tropical destinations
    if (['Thailand', 'Indonesia', 'Malaysia', 'Philippines'].includes(params.country)) {
      if (currentMonth >= 10 || currentMonth <= 3) {
        // Nov-Apr (dry season)
        return 1.3;
      }
    }

    return 1.0;
  }

  /**
   * Calculate amenities factor based on available amenities
   */
  private calculateAmenitiesFactor(amenities: string[]): number {
    if (!amenities || amenities.length === 0) {
      return 1.0;
    }

    // Define premium amenities that increase price
    const premiumAmenities = [
      'pool',
      'hot_tub',
      'sauna',
      'gym',
      'beach_access',
      'ski_in_out',
      'waterfront',
      'mountain_view',
      'ocean_view',
      'private_garden',
      'rooftop_terrace',
      'private_chef',
      'concierge',
      'security',
      'ev_charger',
    ];

    // Calculate factor: each premium amenity adds 2% to the price, up to 30%
    const premiumCount = amenities.filter(a => premiumAmenities.includes(a)).length;
    const premiumFactor = 1 + Math.min(premiumCount * 0.02, 0.3);

    return premiumFactor;
  }

  /**
   * Calculate size factor based on bedrooms and bathrooms
   */
  private calculateSizeFactor(bedrooms: number, bathrooms: number): number {
    // First bedroom is base price
    let bedroomFactor = 1.0;

    // Each additional bedroom adds 25% to the price, with diminishing returns
    if (bedrooms > 1) {
      bedroomFactor += 0.25 * (bedrooms - 1) * (1 - (bedrooms - 1) * 0.05);
    }

    // Each bathroom adds 15% to the price
    const bathroomFactor = 1.0 + (bathrooms - 1) * 0.15;

    return bedroomFactor * bathroomFactor;
  }

  /**
   * Calculate occupancy factor based on maximum guests
   */
  private calculateOccupancyFactor(maxGuests: number): number {
    // First guest is base price
    let factor = 1.0;

    // Each additional guest adds 15% to the price, with diminishing returns
    if (maxGuests > 1) {
      factor += 0.15 * (maxGuests - 1) * (1 - (maxGuests - 1) * 0.02);
    }

    return factor;
  }

  /**
   * Calculate property type factor
   */
  private calculatePropertyTypeFactor(propertyType: string): number {
    const propertyFactors: PropertyFactors = {
      luxury_villa: 1.5,
      penthouse: 1.4,
      beachfront: 1.35,
      ski_chalet: 1.3,
      mansion: 1.25,
      house: 1.0,
      apartment: 0.9,
      condo: 0.95,
      cabin: 0.85,
      room: 0.7,
      shared_room: 0.5,
    };

    // Use a type-safe lookup with fallback
    return propertyFactors[propertyType as keyof PropertyFactors] || 1.0;
  }
}
