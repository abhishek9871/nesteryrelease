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
        ...bookingComResults,
        ...oyoResults,
      ]);
      
      return combinedResults;
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Get property details from the appropriate provider
   */
  async getPropertyDetails(propertyId: string, sourceType: string) {
    try {
      this.logger.log(`Getting property details for ${propertyId} from ${sourceType}`);
      
      switch (sourceType.toLowerCase()) {
        case 'booking_com':
          return this.bookingComService.getPropertyDetails(propertyId);
        case 'oyo':
          return this.oyoService.getPropertyDetails(propertyId);
        default:
          throw new Error(`Unsupported source type: ${sourceType}`);
      }
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Create a booking with the appropriate provider
   */
  async createBooking(bookingData: any, sourceType: string) {
    try {
      this.logger.log(`Creating booking with ${sourceType}`);
      
      switch (sourceType.toLowerCase()) {
        case 'booking_com':
          return this.bookingComService.createBooking(bookingData);
        case 'oyo':
          return this.oyoService.createBooking(bookingData);
        default:
          throw new Error(`Unsupported source type: ${sourceType}`);
      }
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Get geocoding information for an address
   */
  async geocodeAddress(address: string) {
    try {
      return this.googleMapsService.geocodeAddress(address);
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Get nearby places of interest
   */
  async getNearbyPlaces(latitude: number, longitude: number, radius: number, type?: string) {
    try {
      return this.googleMapsService.getNearbyPlaces(latitude, longitude, radius, type);
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * De-duplicate results from multiple providers
   * Uses a simple algorithm based on name and address similarity
   */
  private deduplicateResults(properties: any[]): any[] {
    const uniqueProperties = [];
    const seenProperties = new Set();
    
    for (const property of properties) {
      // Create a unique key based on property attributes
      const key = `${property.name.toLowerCase()}-${property.address.toLowerCase()}`;
      
      if (!seenProperties.has(key)) {
        seenProperties.add(key);
        uniqueProperties.push(property);
      }
    }
    
    return uniqueProperties;
  }
}
