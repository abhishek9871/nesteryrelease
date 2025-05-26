import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';
import { BookingComService } from './booking-com/booking-com.service';
import { OyoService } from './oyo/oyo.service';
import { GoogleMapsService } from './google-maps/google-maps.service';

/**
 * Main service for handling external API integrations
 * Acts as a facade for specific integration services
 */
@Injectable()
export class IntegrationsService {
  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
    private readonly bookingComService: BookingComService,
    private readonly oyoService: OyoService,
    private readonly googleMapsService: GoogleMapsService,
  ) {
    this.logger.setContext('IntegrationsService');
  }

  /**
   * Search properties across all integrated providers
   */
  async searchProperties(searchParams: any) {
    try {
      this.logger.log(`Searching properties across all providers: ${JSON.stringify(searchParams)}`);

      // Collect results from all providers in parallel
      const [bookingComResults, oyoResults] = await Promise.all([
        this.bookingComService.searchProperties(searchParams),
        this.oyoService.searchProperties(searchParams),
      ]);

      // Combine and de-duplicate results
      const combinedResults = this.deduplicateResults([
        ...(bookingComResults?.hotels || []),
        ...(oyoResults?.hotels || []),
      ]);

      return {
        success: true,
        totalResults: combinedResults.length,
        hotels: combinedResults,
      };
    } catch (error) {
      this.logger.error(`Error searching properties: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        totalResults: 0,
        hotels: [],
        error: 'Failed to search properties',
      };
    }
  }

  /**
   * Get property details from the appropriate provider
   */
  async getPropertyDetails(propertyId: string, sourceType: string) {
    try {
      this.logger.log(`Getting property details for ID ${propertyId} from source ${sourceType}`);

      // Route to the appropriate provider
      if (sourceType === 'booking_com') {
        return this.bookingComService.getPropertyDetails(propertyId);
      } else if (sourceType === 'oyo') {
        return this.oyoService.getPropertyDetails(propertyId);
      } else {
        throw new Error(`Unsupported source type: ${sourceType}`);
      }
    } catch (error) {
      this.logger.error(`Error getting property details: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        error: `Failed to get property details for ID ${propertyId}`,
      };
    }
  }

  /**
   * Create a booking with the appropriate provider
   */
  async createBooking(bookingData: any) {
    try {
      this.logger.log(`Creating booking: ${JSON.stringify(bookingData)}`);

      const { sourceType } = bookingData;

      // Route to the appropriate provider
      if (sourceType === 'booking_com') {
        // Implement BookingCom booking creation
        throw new Error('Booking.com booking creation not implemented');
      } else if (sourceType === 'oyo') {
        return this.oyoService.createBooking(bookingData);
      } else {
        throw new Error(`Unsupported source type: ${sourceType}`);
      }
    } catch (error) {
      this.logger.error(`Error creating booking: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        error: 'Failed to create booking',
      };
    }
  }

  /**
   * Get nearby places using Google Maps API
   */
  async getNearbyPlaces(
    latitude: number,
    longitude: number,
    radius: number = 1000,
    type: string = 'restaurant',
  ) {
    try {
      this.logger.log(
        `Getting nearby places at ${latitude},${longitude} with radius ${radius}m and type ${type}`,
      );

      return this.googleMapsService.getNearbyPlaces(latitude, longitude, radius, type);
    } catch (error) {
      this.logger.error(`Error getting nearby places: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        error: 'Failed to get nearby places',
      };
    }
  }

  /**
   * Helper method to deduplicate results from multiple providers
   */
  private deduplicateResults(results: any[]) {
    // Use a Map to deduplicate by ID
    const uniqueMap = new Map();

    results.forEach(result => {
      // Skip if no ID
      if (!result.id) return;

      // If we already have this ID, only replace if the new one has more info
      if (uniqueMap.has(result.id)) {
        const existing = uniqueMap.get(result.id);

        // Simple heuristic: replace if the new one has more fields
        const existingKeys = Object.keys(existing).length;
        const newKeys = Object.keys(result).length;

        if (newKeys > existingKeys) {
          uniqueMap.set(result.id, result);
        }
      } else {
        uniqueMap.set(result.id, result);
      }
    });

    return Array.from(uniqueMap.values());
  }
}
