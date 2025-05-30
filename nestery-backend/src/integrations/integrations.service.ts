import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';
import { BookingComService } from './booking-com/booking-com.service';
import { OyoService } from './oyo/oyo.service';
import { GoogleMapsService } from './google-maps/google-maps.service';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Supplier } from './entities/supplier.entity';
import { Property } from '../properties/entities/property.entity';

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
    @InjectRepository(Supplier)
    private readonly supplierRepository: Repository<Supplier>,
    @InjectRepository(Property)
    private readonly propertyRepository: Repository<Property>,
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
  async createBooking(
    bookingData: any,
  ): Promise<{ redirectUrl: string; sourceType: string } | any> {
    try {
      this.logger.log(`Creating booking: ${JSON.stringify(bookingData)}`);

      const { sourceType, propertyId, userId, ...restOfBookingData } = bookingData;

      if (!sourceType || !propertyId || !userId) {
        throw new BadRequestException(
          'Missing required fields: sourceType, propertyId, or userId.',
        );
      }

      if (sourceType === 'booking_com') {
        const nesteryProperty = await this.propertyRepository.findOne({
          where: { id: propertyId },
        });
        if (!nesteryProperty || !nesteryProperty.externalId) {
          throw new NotFoundException(
            `Property with Nestery ID ${propertyId} not found or has no external Booking.com ID.`,
          );
        }

        const bookingComSupplier = await this.supplierRepository.findOne({
          where: { type: 'booking' }, // Assuming 'booking' is the enum value for Booking.com
        });

        if (!bookingComSupplier) {
          throw new Error('Booking.com supplier configuration not found.');
        }

        // Prepare payload for generating redirect URL
        const redirectPayload = {
          hotelId: nesteryProperty.externalId, // Booking.com's specific hotel ID
          checkInDate: new Date(restOfBookingData.checkInDate),
          checkOutDate: new Date(restOfBookingData.checkOutDate),
          numberOfGuests: restOfBookingData.numberOfGuests,
          // Pass other relevant details if Booking.com's redirect construction needs them
          // e.g., guestName: restOfBookingData.guestName, guestEmail: restOfBookingData.guestEmail
        };

        const result = await this.bookingComService.generateBookingRedirectUrl(
          redirectPayload,
          bookingComSupplier,
        );
        if (result.success && result.redirectUrl) {
          return {
            success: true,
            redirectUrl: result.redirectUrl,
            sourceType: 'booking_com', // Add sourceType to help frontend distinguish
          };
        } else {
          throw new Error(result.error || 'Failed to get Booking.com redirect URL');
        }
      } else if (sourceType === 'oyo') {
        // OYO booking logic remains, assuming it might be a direct API or different flow
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
        // booking: undefined, // Ensure booking is undefined on error
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
