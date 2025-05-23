import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';
import { firstValueFrom } from 'rxjs';

/**
 * Service for integrating with OYO API
 * Note: As mentioned in research, there is limited public documentation for OYO API
 * This implementation uses a best-effort approach based on available information
 */
@Injectable()
export class OyoService {
  private readonly apiUrl: string;
  private readonly apiKey: string;
  private readonly apiSecret: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    this.logger.setContext('OyoService');
    // These would be configured in .env file
    this.apiUrl = this.configService.get<string>('OYO_API_URL', 'https://api.oyorooms.com');
    this.apiKey = this.configService.get<string>('OYO_API_KEY', '');
    this.apiSecret = this.configService.get<string>('OYO_API_SECRET', '');
  }

  /**
   * Search for properties on OYO
   */
  async searchProperties(searchParams: any): Promise<any[]> {
    try {
      this.logger.log(`Searching OYO properties: ${JSON.stringify(searchParams)}`);
      
      const { city, country, checkIn, checkOut, guests } = searchParams;
      
      // Prepare request parameters according to OYO API
      const params = {
        city,
        country,
        check_in: checkIn,
        check_out: checkOut,
        guests: guests || 1,
        // Add other parameters as needed
      };
      
      // Make API request
      const response = await firstValueFrom(
        this.httpService.get(`${this.apiUrl}/v1/properties/search`, {
          params,
          headers: this.getHeaders(),
        }),
      );
      
      // Transform response to standard format
      return this.transformProperties(response.data.properties || []);
    } catch (error) {
      this.logger.error(`Error searching OYO properties: ${error.message}`);
      this.exceptionService.handleException(error);
      
      // Implement fallback strategy
      this.logger.log('Using fallback strategy for OYO properties');
      return this.getFallbackProperties(searchParams);
    }
  }

  /**
   * Get property details from OYO
   */
  async getPropertyDetails(propertyId: string): Promise<any> {
    try {
      this.logger.log(`Getting OYO property details: ${propertyId}`);
      
      // Make API request
      const response = await firstValueFrom(
        this.httpService.get(`${this.apiUrl}/v1/properties/${propertyId}`, {
          headers: this.getHeaders(),
        }),
      );
      
      // Transform response to standard format
      return this.transformPropertyDetails(response.data.property);
    } catch (error) {
      this.logger.error(`Error getting OYO property details: ${error.message}`);
      this.exceptionService.handleException(error);
      
      // Implement fallback strategy
      this.logger.log('Using fallback strategy for OYO property details');
      return this.getFallbackPropertyDetails(propertyId);
    }
  }

  /**
   * Create a booking on OYO
   */
  async createBooking(bookingData: any): Promise<any> {
    try {
      this.logger.log(`Creating OYO booking: ${JSON.stringify(bookingData)}`);
      
      // Prepare booking data according to OYO API
      const payload = {
        property_id: bookingData.propertyId,
        check_in: bookingData.checkInDate,
        check_out: bookingData.checkOutDate,
        guests: bookingData.numberOfGuests,
        customer: {
          first_name: bookingData.firstName,
          last_name: bookingData.lastName,
          email: bookingData.email,
          phone: bookingData.phone,
        },
        payment: {
          method: bookingData.paymentMethod,
          token: bookingData.cardToken,
        },
        special_requests: bookingData.specialRequests,
      };
      
      // Make API request
      const response = await firstValueFrom(
        this.httpService.post(`${this.apiUrl}/v1/bookings`, payload, {
          headers: this.getHeaders(),
        }),
      );
      
      // Transform response to standard format
      return {
        id: response.data.booking.id,
        confirmationCode: response.data.booking.confirmation_code,
        status: response.data.booking.status,
        propertyId: response.data.booking.property_id,
        checkInDate: response.data.booking.check_in,
        checkOutDate: response.data.booking.check_out,
        totalPrice: response.data.booking.total_price,
        currency: response.data.booking.currency,
        sourceType: 'oyo',
        externalBookingId: response.data.booking.id,
      };
    } catch (error) {
      this.logger.error(`Error creating OYO booking: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Get authentication headers for OYO API
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
      'X-API-Key': this.apiKey,
      'X-Timestamp': timestamp,
      'X-Signature': signature,
    };
  }

  /**
   * Generate signature for OYO API authentication
   */
  private generateSignature(timestamp: string): string {
    // In a real implementation, this would use crypto to generate a proper HMAC signature
    // For this example, we're using a placeholder
    return `signature_placeholder_${timestamp}`;
  }

  /**
   * Transform OYO property data to standard format
   */
  private transformProperties(properties: any[]): any[] {
    return properties.map(property => ({
      name: property.name,
      description: property.description,
      address: property.address,
      city: property.city,
      state: property.state,
      country: property.country,
      zipCode: property.zip_code,
      latitude: property.latitude,
      longitude: property.longitude,
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
      sourceType: 'oyo',
      externalId: property.id,
      externalUrl: property.url,
      metadata: {
        rating: property.rating,
        reviewCount: property.review_count,
      },
    }));
  }

  /**
   * Transform OYO property details to standard format
   */
  private transformPropertyDetails(property: any): any {
    return {
      name: property.name,
      description: property.description,
      address: property.address,
      city: property.city,
      state: property.state,
      country: property.country,
      zipCode: property.zip_code,
      latitude: property.latitude,
      longitude: property.longitude,
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
      sourceType: 'oyo',
      externalId: property.id,
      externalUrl: property.url,
      metadata: {
        rating: property.rating,
        reviewCount: property.review_count,
        policies: property.policies,
        roomTypes: property.room_types,
      },
    };
  }

  /**
   * Map OYO property types to standard types
   */
  private mapPropertyType(oyoType: string): string {
    const typeMap = {
      'hotel': 'hotel',
      'apartment': 'apartment',
      'resort': 'resort',
      'villa': 'villa',
      'hostel': 'hostel',
      'guest_house': 'guesthouse',
      // Add more mappings as needed
    };
    
    return typeMap[oyoType] || 'hotel';
  }

  /**
   * Fallback method to get properties when API fails
   * This is a placeholder implementation that would be replaced with actual fallback logic
   */
  private getFallbackProperties(searchParams: any): any[] {
    this.logger.log('Using fallback data for OYO properties');
    
    // In a real implementation, this could use cached data, a secondary API, or other fallback mechanisms
    return [
      {
        name: 'OYO Premium Hotel',
        description: 'A comfortable stay in the heart of the city',
        address: '123 Main Street',
        city: searchParams.city || 'Mumbai',
        state: 'Maharashtra',
        country: searchParams.country || 'India',
        zipCode: '400001',
        latitude: 19.0760,
        longitude: 72.8777,
        propertyType: 'hotel',
        starRating: 3,
        basePrice: 45.99,
        currency: 'USD',
        maxGuests: 2,
        bedrooms: 1,
        bathrooms: 1,
        amenities: ['wifi', 'ac', 'tv', 'breakfast'],
        images: [
          'https://example.com/oyo/hotel1_1.jpg',
          'https://example.com/oyo/hotel1_2.jpg',
        ],
        thumbnailImage: 'https://example.com/oyo/hotel1_thumb.jpg',
        sourceType: 'oyo',
        externalId: 'OYO12345',
        externalUrl: 'https://www.oyorooms.com/hotels/12345',
        metadata: {
          rating: 4.2,
          reviewCount: 128,
        },
      },
      // Add more fallback properties as needed
    ];
  }

  /**
   * Fallback method to get property details when API fails
   * This is a placeholder implementation that would be replaced with actual fallback logic
   */
  private getFallbackPropertyDetails(propertyId: string): any {
    this.logger.log(`Using fallback data for OYO property details: ${propertyId}`);
    
    // In a real implementation, this could use cached data, a secondary API, or other fallback mechanisms
    return {
      name: 'OYO Premium Hotel',
      description: 'A comfortable stay in the heart of the city',
      address: '123 Main Street',
      city: 'Mumbai',
      state: 'Maharashtra',
      country: 'India',
      zipCode: '400001',
      latitude: 19.0760,
      longitude: 72.8777,
      propertyType: 'hotel',
      starRating: 3,
      basePrice: 45.99,
      currency: 'USD',
      maxGuests: 2,
      bedrooms: 1,
      bathrooms: 1,
      amenities: ['wifi', 'ac', 'tv', 'breakfast'],
      images: [
        'https://example.com/oyo/hotel1_1.jpg',
        'https://example.com/oyo/hotel1_2.jpg',
      ],
      thumbnailImage: 'https://example.com/oyo/hotel1_thumb.jpg',
      sourceType: 'oyo',
      externalId: propertyId,
      externalUrl: `https://www.oyorooms.com/hotels/${propertyId}`,
      metadata: {
        rating: 4.2,
        reviewCount: 128,
        policies: {
          checkIn: '14:00',
          checkOut: '11:00',
          cancellation: 'Free cancellation up to 24 hours before check-in',
        },
        roomTypes: [
          {
            id: 'standard',
            name: 'Standard Room',
            description: 'Comfortable room with all basic amenities',
            price: 45.99,
          },
          {
            id: 'deluxe',
            name: 'Deluxe Room',
            description: 'Spacious room with premium amenities',
            price: 65.99,
          },
        ],
      },
    };
  }
}
