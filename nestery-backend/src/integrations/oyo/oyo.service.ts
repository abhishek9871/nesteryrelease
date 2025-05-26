import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';
import * as crypto from 'crypto';

// Define interfaces for OYO API responses
interface OyoHotelImage {
  url: string;
  caption?: string;
}

interface OyoHotelFacility {
  id: string;
  description: string;
  category?: string;
}

interface OyoHotelRoom {
  id: string;
  name: string;
  description: string;
  maxOccupancy: number;
  price: number;
  currency: string;
  facilities?: OyoHotelFacility[];
  images?: OyoHotelImage[];
}

interface OyoHotelReview {
  id: string;
  rating: number;
  comment: string;
  author: string;
  date: string;
}

interface OyoHotelReviews {
  averageRating: number;
  totalCount: number;
  reviews: OyoHotelReview[];
}

interface OyoHotel {
  id: string;
  name: string;
  description: string;
  address: string;
  city: string;
  state: string;
  country: string;
  zipCode: string;
  latitude: number;
  longitude: number;
  starRating: number;
  images?: OyoHotelImage[];
  facilities?: OyoHotelFacility[];
  rooms?: OyoHotelRoom[];
  reviews?: OyoHotelReviews;
}

@Injectable()
export class OyoService {
  private readonly apiUrl: string = '';
  private readonly apiKey: string = '';
  private readonly partnerId: string = '';

  // Fallback B2B aggregator credentials
  private readonly hotelbedsApiUrl: string = '';
  private readonly hotelbedsApiKey: string = '';
  private readonly hotelbedsApiSecret: string = '';

  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    const apiUrl = this.configService.get<string>('OYO_API_URL');
    if (apiUrl) this.apiUrl = apiUrl;

    const apiKey = this.configService.get<string>('OYO_API_KEY');
    if (apiKey) this.apiKey = apiKey;

    const partnerId = this.configService.get<string>('OYO_PARTNER_ID');
    if (partnerId) this.partnerId = partnerId;

    const hotelbedsApiUrl = this.configService.get<string>('HOTELBEDS_API_URL');
    if (hotelbedsApiUrl) this.hotelbedsApiUrl = hotelbedsApiUrl;

    const hotelbedsApiKey = this.configService.get<string>('HOTELBEDS_API_KEY');
    if (hotelbedsApiKey) this.hotelbedsApiKey = hotelbedsApiKey;

    const hotelbedsApiSecret = this.configService.get<string>('HOTELBEDS_API_SECRET');
    if (hotelbedsApiSecret) this.hotelbedsApiSecret = hotelbedsApiSecret;

    this.logger.setContext('OyoService');
  }

  /**
   * Search for hotels based on criteria
   */
  async searchHotels(params: {
    location: string;
    checkInDate: Date;
    checkOutDate: Date;
    adults: number;
    children?: number;
    rooms?: number;
    minPrice?: number;
    maxPrice?: number;
    amenities?: string[];
    propertyType?: string;
    minRating?: number;
  }) {
    try {
      // Check if OYO API is configured
      if (!this.apiUrl || !this.apiKey) {
        this.logger.warn('OYO API not configured, falling back to Hotelbeds API');
        return this.searchHotelsHotelbeds(params);
      }

      // Format dates for OYO API
      const checkInFormatted = params.checkInDate.toISOString().split('T')[0];
      const checkOutFormatted = params.checkOutDate.toISOString().split('T')[0];

      // Prepare request parameters
      const requestParams = {
        partner_id: this.partnerId,
        api_key: this.apiKey,
        location: params.location,
        check_in: checkInFormatted,
        check_out: checkOutFormatted,
        adults: params.adults,
        children: params.children || 0,
        rooms: params.rooms || 1,
        min_price: params.minPrice,
        max_price: params.maxPrice,
        amenities: params.amenities?.join(','),
        property_type: params.propertyType,
        min_rating: params.minRating,
      };

      // Make API request
      const response = await axios.get(`${this.apiUrl}/hotels/search`, {
        params: requestParams,
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
      });

      // Process response
      const hotels = response.data.hotels || [];

      return {
        success: true,
        totalResults: hotels.length,
        hotels: hotels.map((hotel: OyoHotel) => ({
          id: hotel.id,
          name: hotel.name,
          description: hotel.description,
          address: hotel.address,
          city: hotel.city,
          state: hotel.state,
          country: hotel.country,
          zipCode: hotel.zipCode,
          latitude: hotel.latitude,
          longitude: hotel.longitude,
          starRating: hotel.starRating,
          images: hotel.images?.map((image: OyoHotelImage) => image.url) || [],
          lowestPrice: Math.min(...(hotel.rooms?.map((room: OyoHotelRoom) => room.price) || [0])),
          currency: hotel.rooms?.[0]?.currency || 'USD',
          rooms: hotel.rooms?.map((room: OyoHotelRoom) => ({
            id: room.id,
            name: room.name,
            description: room.description,
            maxOccupancy: room.maxOccupancy,
            price: room.price,
            currency: room.currency,
            images: room.images?.map((image: OyoHotelImage) => image.url) || [],
            amenities:
              room.facilities?.map((facility: OyoHotelFacility) => facility.description) || [],
          })),
          reviews:
            hotel.reviews?.reviews?.map((review: OyoHotelReview) => ({
              rating: review.rating,
              comment: review.comment,
              author: review.author,
              date: review.date,
            })) || [],
          averageRating: hotel.reviews?.averageRating || 0,
          reviewCount: hotel.reviews?.totalCount || 0,
        })),
      };
    } catch (error) {
      this.logger.error(`Error searching OYO hotels: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      // Fallback to Hotelbeds API
      this.logger.warn('Falling back to Hotelbeds API');
      return this.searchHotelsHotelbeds(params);
    }
  }

  /**
   * Alias for searchHotels to match integration service interface
   */
  async searchProperties(params: Record<string, unknown>) {
    return this.searchHotels(params as any);
  }

  /**
   * Fallback method to search hotels using Hotelbeds API
   */
  private async searchHotelsHotelbeds(params: {
    location: string;
    checkInDate: Date;
    checkOutDate: Date;
    adults: number;
    children?: number;
    rooms?: number;
    minPrice?: number;
    maxPrice?: number;
    amenities?: string[];
    propertyType?: string;
    minRating?: number;
  }) {
    try {
      // Check if Hotelbeds API is configured
      if (!this.hotelbedsApiUrl || !this.hotelbedsApiKey || !this.hotelbedsApiSecret) {
        throw new Error('Hotelbeds API not configured');
      }

      // Format dates for Hotelbeds API
      const checkInFormatted = params.checkInDate.toISOString().split('T')[0];
      const checkOutFormatted = params.checkOutDate.toISOString().split('T')[0];

      // Generate signature for Hotelbeds API
      const timestamp = Math.floor(Date.now() / 1000);
      const signature = this.generateHotelbedsSignature(timestamp);

      // Prepare request body
      const requestBody = {
        stay: {
          checkIn: checkInFormatted,
          checkOut: checkOutFormatted,
        },
        occupancies: [
          {
            rooms: params.rooms || 1,
            adults: params.adults,
            children: params.children || 0,
          },
        ],
        destination: {
          code: params.location,
        },
        filter: {
          minRate: params.minPrice,
          maxRate: params.maxPrice,
          minCategory: params.minRating,
        },
      };

      // Make API request
      const response = await axios.post(
        `${this.hotelbedsApiUrl}/hotel-api/1.0/hotels`,
        requestBody,
        {
          headers: {
            'Api-Key': this.hotelbedsApiKey,
            'X-Signature': signature,
            Accept: 'application/json',
            'Content-Type': 'application/json',
          },
        },
      );

      // Process response
      const hotels = response.data.hotels?.hotels || [];
      const rooms = response.data.hotels?.rooms || [];

      return {
        success: true,
        totalResults: hotels.length,
        hotels: hotels.map((hotel: Record<string, any>) => ({
          id: hotel.code,
          name: hotel.name,
          description: hotel.description || 'No description available',
          address: hotel.address?.content || 'No address available',
          city: hotel.city?.content || 'Unknown',
          state: hotel.state?.content || 'Unknown',
          country: hotel.country?.content || 'Unknown',
          zipCode: hotel.postalCode || 'Unknown',
          latitude: hotel.coordinates?.latitude || 0,
          longitude: hotel.coordinates?.longitude || 0,
          starRating: hotel.categoryCode || 0,
          images: hotel.images?.map((image: Record<string, any>) => image.url) || [],
          lowestPrice: Math.min(
            ...rooms
              .filter((room: Record<string, any>) => room.hotelCode === hotel.code)
              .map((room: Record<string, any>) => room.rates[0]?.net || 0),
          ),
          currency:
            rooms.find((room: Record<string, any>) => room.hotelCode === hotel.code)?.rates[0]
              ?.currency || 'USD',
          rooms: rooms
            .filter((room: Record<string, any>) => room.hotelCode === hotel.code)
            .map((room: Record<string, any>) => ({
              id: room.code,
              name: room.name,
              description: room.description || 'No description available',
              maxOccupancy: room.occupancy?.maxAdults || 2,
              price: room.rates[0]?.net || 0,
              currency: room.rates[0]?.currency || 'USD',
              images: room.images?.map((image: Record<string, any>) => image.url) || [],
              amenities:
                room.facilities?.map((facility: Record<string, any>) => facility.description) || [],
            })),
          reviews: [],
          averageRating: hotel.reviews?.rating || 0,
          reviewCount: hotel.reviews?.count || 0,
        })),
      };
    } catch (error) {
      this.logger.error(`Error searching Hotelbeds hotels: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      // Return empty result
      return {
        success: false,
        totalResults: 0,
        hotels: [],
        error: 'Failed to search hotels',
      };
    }
  }

  /**
   * Get hotel details by ID
   */
  async getHotelDetails(hotelId: string) {
    try {
      // Check if OYO API is configured
      if (!this.apiUrl || !this.apiKey) {
        this.logger.warn('OYO API not configured, falling back to Hotelbeds API');
        return this.getHotelDetailsHotelbeds(hotelId);
      }

      // Make API request
      const response = await axios.get(`${this.apiUrl}/hotels/${hotelId}`, {
        params: {
          partner_id: this.partnerId,
          api_key: this.apiKey,
        },
        headers: {
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
      });

      // Process response
      const hotel = response.data.hotel;

      if (!hotel) {
        throw new Error(`Hotel with ID ${hotelId} not found`);
      }

      return {
        success: true,
        hotel: {
          id: hotel.id,
          name: hotel.name,
          description: hotel.description,
          address: hotel.address,
          city: hotel.city,
          state: hotel.state,
          country: hotel.country,
          zipCode: hotel.zipCode,
          latitude: hotel.latitude,
          longitude: hotel.longitude,
          starRating: hotel.starRating,
          images: hotel.images?.map((image: OyoHotelImage) => image.url) || [],
          amenities:
            hotel.facilities?.map((facility: OyoHotelFacility) => facility.description) || [],
          rooms:
            hotel.rooms?.map((room: OyoHotelRoom) => ({
              id: room.id,
              name: room.name,
              description: room.description,
              maxOccupancy: room.maxOccupancy,
              price: room.price,
              currency: room.currency,
              images: room.images?.map((image: OyoHotelImage) => image.url) || [],
              amenities:
                room.facilities?.map((facility: OyoHotelFacility) => facility.description) || [],
            })) || [],
          reviews:
            hotel.reviews?.reviews?.map((review: OyoHotelReview) => ({
              rating: review.rating,
              comment: review.comment,
              author: review.author,
              date: review.date,
            })) || [],
          averageRating: hotel.reviews?.averageRating || 0,
          reviewCount: hotel.reviews?.totalCount || 0,
        },
      };
    } catch (error) {
      this.logger.error(`Error getting OYO hotel details: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      // Fallback to Hotelbeds API
      this.logger.warn('Falling back to Hotelbeds API');
      return this.getHotelDetailsHotelbeds(hotelId);
    }
  }

  /**
   * Alias for getHotelDetails to match integration service interface
   */
  async getPropertyDetails(propertyId: string) {
    return this.getHotelDetails(propertyId);
  }

  /**
   * Create a booking
   */
  async createBooking(_bookingData: Record<string, unknown>): Promise<{
    success: boolean;
    booking?: Record<string, unknown>;
    error?: string;
  }> {
    try {
      // Implementation would go here
      return {
        success: true,
        booking: {
          id: 'mock-booking-id',
          // Other booking details
        },
      };
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
   * Fallback method to get hotel details using Hotelbeds API
   */
  private async getHotelDetailsHotelbeds(hotelId: string) {
    try {
      // Check if Hotelbeds API is configured
      if (!this.hotelbedsApiUrl || !this.hotelbedsApiKey || !this.hotelbedsApiSecret) {
        throw new Error('Hotelbeds API not configured');
      }

      // Generate signature for Hotelbeds API
      const timestamp = Math.floor(Date.now() / 1000);
      const signature = this.generateHotelbedsSignature(timestamp);

      // Make API request
      const response = await axios.get(`${this.hotelbedsApiUrl}/hotel-api/1.0/hotels/${hotelId}`, {
        headers: {
          'Api-Key': this.hotelbedsApiKey,
          'X-Signature': signature,
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
      });

      // Process response
      const hotel = response.data.hotel;
      const rooms = response.data.rooms || [];

      if (!hotel) {
        throw new Error(`Hotel with ID ${hotelId} not found`);
      }

      return {
        success: true,
        hotel: {
          id: hotel.code,
          name: hotel.name,
          description: hotel.description || 'No description available',
          address: hotel.address?.content || 'No address available',
          city: hotel.city?.content || 'Unknown',
          state: hotel.state?.content || 'Unknown',
          country: hotel.country?.content || 'Unknown',
          zipCode: hotel.postalCode || 'Unknown',
          latitude: hotel.coordinates?.latitude || 0,
          longitude: hotel.coordinates?.longitude || 0,
          starRating: hotel.categoryCode || 0,
          images: hotel.images?.map((image: Record<string, any>) => image.url) || [],
          amenities:
            hotel.facilities?.map((facility: Record<string, any>) => facility.description) || [],
          rooms: rooms.map((room: Record<string, any>) => ({
            id: room.code,
            name: room.name,
            description: room.description || 'No description available',
            maxOccupancy: room.occupancy?.maxAdults || 2,
            price: room.rates[0]?.net || 0,
            currency: room.rates[0]?.currency || 'USD',
            images: room.images?.map((image: Record<string, any>) => image.url) || [],
            amenities:
              room.facilities?.map((facility: Record<string, any>) => facility.description) || [],
          })),
          reviews: [],
          averageRating: hotel.reviews?.rating || 0,
          reviewCount: hotel.reviews?.count || 0,
        },
      };
    } catch (error) {
      this.logger.error(`Error getting Hotelbeds hotel details: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);

      // Return empty result
      return {
        success: false,
        hotel: null,
        error: 'Failed to get hotel details',
      };
    }
  }

  /**
   * Generate signature for Hotelbeds API
   */
  private generateHotelbedsSignature(timestamp: number): string {
    try {
      return crypto
        .createHash('sha256')
        .update(`${this.hotelbedsApiKey}${this.hotelbedsApiSecret}${timestamp}`)
        .digest('hex');
    } catch (error) {
      this.logger.error(`Error generating signature: ${error.message}`, error.stack);
      return '';
    }
  }
}
