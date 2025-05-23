import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';
import { firstValueFrom } from 'rxjs';

/**
 * Service for integrating with Booking.com Demand API
 * Based on Booking.com Demand API v3.1 (May 2025)
 */
@Injectable()
export class BookingComService {
  private readonly apiUrl: string;
  private readonly apiKey: string;
  private readonly apiSecret: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    this.logger.setContext('BookingComService');
    this.apiUrl = this.configService.get<string>('BOOKING_COM_API_URL');
    this.apiKey = this.configService.get<string>('BOOKING_COM_API_KEY');
    this.apiSecret = this.configService.get<string>('BOOKING_COM_API_SECRET');
  }

  /**
   * Search for properties on Booking.com
   */
  async searchProperties(searchParams: any): Promise<any[]> {
    try {
      this.logger.log(`Searching Booking.com properties: ${JSON.stringify(searchParams)}`);
      
      const { city, country, checkIn, checkOut, guests, rooms, minPrice, maxPrice } = searchParams;
      
      // Prepare request parameters according to Booking.com API
      const params = {
        city,
        country,
        checkin: checkIn,
        checkout: checkOut,
        guests: guests || 1,
        rooms: rooms || 1,
        price_min: minPrice,
        price_max: maxPrice,
        currency: 'USD',
        language: 'en-us',
      };
      
      // Make API request
      const response = await firstValueFrom(
        this.httpService.get(`${this.apiUrl}/properties/search`, {
          params,
          headers: this.getHeaders(),
        }),
      );
      
      // Transform response to standard format
      return this.transformProperties(response.data.result);
    } catch (error) {
      this.logger.error(`Error searching Booking.com properties: ${error.message}`);
      this.exceptionService.handleException(error);
      // Return empty array instead of throwing to allow aggregation to continue
      return [];
    }
  }

  /**
   * Get property details from Booking.com
   */
  async getPropertyDetails(propertyId: string): Promise<any> {
    try {
      this.logger.log(`Getting Booking.com property details: ${propertyId}`);
      
      // Make API request
      const response = await firstValueFrom(
        this.httpService.get(`${this.apiUrl}/properties/${propertyId}`, {
          headers: this.getHeaders(),
        }),
      );
      
      // Transform response to standard format
      return this.transformPropertyDetails(response.data);
    } catch (error) {
      this.logger.error(`Error getting Booking.com property details: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Create a booking on Booking.com
   */
  async createBooking(bookingData: any): Promise<any> {
    try {
      this.logger.log(`Creating Booking.com booking: ${JSON.stringify(bookingData)}`);
      
      // Prepare booking data according to Booking.com API
      const payload = {
        property_id: bookingData.propertyId,
        checkin: bookingData.checkInDate,
        checkout: bookingData.checkOutDate,
        guests: bookingData.numberOfGuests,
        rooms: bookingData.rooms || 1,
        customer: {
          first_name: bookingData.firstName,
          last_name: bookingData.lastName,
          email: bookingData.email,
          phone: bookingData.phone,
        },
        payment: {
          type: bookingData.paymentMethod,
          card_token: bookingData.cardToken,
        },
        special_requests: bookingData.specialRequests,
      };
      
      // Make API request
      const response = await firstValueFrom(
        this.httpService.post(`${this.apiUrl}/bookings`, payload, {
          headers: this.getHeaders(),
        }),
      );
      
      // Transform response to standard format
      return {
        id: response.data.id,
        confirmationCode: response.data.confirmation_code,
        status: response.data.status,
        propertyId: response.data.property_id,
        checkInDate: response.data.checkin,
        checkOutDate: response.data.checkout,
        totalPrice: response.data.total_price,
        currency: response.data.currency,
        sourceType: 'booking_com',
        externalBookingId: response.data.id,
      };
    } catch (error) {
      this.logger.error(`Error creating Booking.com booking: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Get authentication headers for Booking.com API
   */
  private getHeaders(): Record<string, string> {
    // Generate timestamp for request
    const timestamp = Math.floor(Date.now() / 1000).toString();
    
    // In a real implementation, we would generate a proper signature
    // based on the API key, secret, and timestamp
    const signature = this.generateSignature(timestamp);
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': `Basic ${Buffer.from(`${this.apiKey}:${this.apiSecret}`).toString('base64')}`,
      'X-Timestamp': timestamp,
      'X-Signature': signature,
    };
  }

  /**
   * Generate signature for Booking.com API authentication
   */
  private generateSignature(timestamp: string): string {
    // In a real implementation, this would use crypto to generate a proper HMAC signature
    // For this example, we're using a placeholder
    return `signature_placeholder_${timestamp}`;
  }

  /**
   * Transform Booking.com property data to standard format
   */
  private transformProperties(properties: any[]): any[] {
    return properties.map(property => ({
      name: property.name,
      description: property.description,
      address: property.address.full_address,
      city: property.address.city,
      state: property.address.state,
      country: property.address.country,
      zipCode: property.address.zip_code,
      latitude: property.location.latitude,
      longitude: property.location.longitude,
      propertyType: this.mapPropertyType(property.type),
      starRating: property.star_rating,
      basePrice: property.price.amount,
      currency: property.price.currency,
      maxGuests: property.max_guests,
      bedrooms: property.rooms.bedrooms,
      bathrooms: property.rooms.bathrooms,
      amenities: property.amenities,
      images: property.images.map(img => img.url),
      thumbnailImage: property.images[0]?.url,
      sourceType: 'booking_com',
      externalId: property.id,
      externalUrl: property.url,
      metadata: {
        rating: property.rating,
        reviewCount: property.review_count,
        checkInTime: property.check_in_time,
        checkOutTime: property.check_out_time,
      },
    }));
  }

  /**
   * Transform Booking.com property details to standard format
   */
  private transformPropertyDetails(property: any): any {
    return {
      name: property.name,
      description: property.description,
      address: property.address.full_address,
      city: property.address.city,
      state: property.address.state,
      country: property.address.country,
      zipCode: property.address.zip_code,
      latitude: property.location.latitude,
      longitude: property.location.longitude,
      propertyType: this.mapPropertyType(property.type),
      starRating: property.star_rating,
      basePrice: property.price.amount,
      currency: property.price.currency,
      maxGuests: property.max_guests,
      bedrooms: property.rooms.bedrooms,
      bathrooms: property.rooms.bathrooms,
      amenities: property.amenities,
      images: property.images.map(img => img.url),
      thumbnailImage: property.images[0]?.url,
      sourceType: 'booking_com',
      externalId: property.id,
      externalUrl: property.url,
      metadata: {
        rating: property.rating,
        reviewCount: property.review_count,
        checkInTime: property.check_in_time,
        checkOutTime: property.check_out_time,
        policies: property.policies,
        roomTypes: property.room_types,
      },
    };
  }

  /**
   * Map Booking.com property types to standard types
   */
  private mapPropertyType(bookingComType: string): string {
    const typeMap = {
      'hotel': 'hotel',
      'apartment': 'apartment',
      'resort': 'resort',
      'villa': 'villa',
      'hostel': 'hostel',
      'guest_house': 'guesthouse',
      // Add more mappings as needed
    };
    
    return typeMap[bookingComType] || 'hotel';
  }
}
