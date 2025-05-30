import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';
import { Supplier } from '../entities/supplier.entity';

// Define interfaces for BookingCom API responses
interface BookingComHotelImage {
  url: string;
  caption?: string;
}

interface BookingComHotelFacility {
  id: string;
  name: string;
  category?: string;
}

interface BookingComHotelRoom {
  id: string;
  name: string;
  description: string;
  maxOccupancy: number;
  price: number;
  currency: string;
  facilities?: BookingComHotelFacility[];
  photos?: BookingComHotelImage[];
}

interface BookingComHotelReview {
  id: string;
  rating: number;
  comment: string;
  author: string;
  date: string;
}

interface BookingComHotel {
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
  photos?: BookingComHotelImage[];
  facilities?: BookingComHotelFacility[];
  rooms?: BookingComHotelRoom[];
  reviews?: BookingComHotelReview[];
}

@Injectable()
export class BookingComService {
  private readonly apiUrl: string = '';
  private readonly apiKey: string = '';
  private readonly apiSecret: string = '';

  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
    // private readonly httpService: HttpService, // Consider using HttpService for better testability
  ) {
    // Use Booking.com Demand API v3.1 endpoints (2025)
    const apiUrl =
      this.configService.get<string>('BOOKING_COM_API_URL') || 'https://demandapi.booking.com/3.1';
    this.apiUrl = apiUrl;

    const apiKey = this.configService.get<string>('BOOKING_COM_API_KEY');
    if (apiKey) this.apiKey = apiKey;

    const apiSecret = this.configService.get<string>('BOOKING_COM_API_SECRET');
    if (apiSecret) this.apiSecret = apiSecret;

    this.logger.setContext('BookingComService');
    this.logger.log(`Initialized BookingComService with Demand API v3.1: ${this.apiUrl}`);
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
      this.logger.debug(`Searching hotels with params: ${JSON.stringify(params)}`);

      const response = await axios.get(`${this.apiUrl}/hotels`, {
        params: {
          city_ids: params.location,
          checkin: this.formatDate(params.checkInDate),
          checkout: this.formatDate(params.checkOutDate),
          adults: params.adults,
          children: params.children,
          rooms: params.rooms || 1,
          min_price: params.minPrice,
          max_price: params.maxPrice,
          amenities: params.amenities?.join(','),
          property_type: params.propertyType,
          min_rating: params.minRating,
        },
        headers: {
          Authorization: `Basic ${Buffer.from(`${this.apiKey}:${this.apiSecret}`).toString('base64')}`,
          'X-Affiliate-ID': this.configService.get<string>('BOOKING_COM_AFFILIATE_ID_HEADER') || '', // Add affiliate ID to header if required by Booking.com for tracking
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
      });

      const hotels = response.data.result || [];

      return {
        success: true,
        totalResults: hotels.length,
        hotels: hotels.map((hotel: BookingComHotel) => ({
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
          images: hotel.photos?.map((photo: BookingComHotelImage) => photo.url) || [],
          lowestPrice: Math.min(
            ...(hotel.rooms?.map((room: BookingComHotelRoom) => room.price) || [0]),
          ),
          currency: hotel.rooms?.[0]?.currency || 'USD',
          rooms: hotel.rooms?.map((room: BookingComHotelRoom) => ({
            id: room.id,
            name: room.name,
            description: room.description,
            maxOccupancy: room.maxOccupancy,
            price: room.price,
            currency: room.currency,
            images: room.photos?.map((photo: BookingComHotelImage) => photo.url) || [],
            amenities:
              room.facilities?.map((facility: BookingComHotelFacility) => facility.name) || [],
          })),
          reviews:
            hotel.reviews?.map((review: BookingComHotelReview) => ({
              rating: review.rating,
              comment: review.comment,
              author: review.author,
              date: review.date,
            })) || [],
          averageRating: this.calculateAverageRating(hotel.reviews || []),
          reviewCount: hotel.reviews?.length || 0,
        })),
      };
    } catch (error) {
      this.logger.error(`Error searching hotels: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        totalResults: 0,
        hotels: [],
        error: 'Failed to search hotels',
      };
    }
  }

  /**
   * Alias for searchHotels to match integration service interface
   */
  async searchProperties(params: any) {
    return this.searchHotels(params);
  }

  /**
   * Get hotel details by ID
   */
  async getHotelDetails(hotelId: string) {
    try {
      this.logger.debug(`Getting hotel details for ID: ${hotelId}`);

      const response = await axios.get(`${this.apiUrl}/hotels/${hotelId}`, {
        headers: {
          Authorization: `Basic ${Buffer.from(`${this.apiKey}:${this.apiSecret}`).toString('base64')}`,
          'X-Affiliate-ID': this.configService.get<string>('BOOKING_COM_AFFILIATE_ID_HEADER') || '',
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
      });

      const hotel = response.data.result;

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
          images: hotel.photos?.map((photo: BookingComHotelImage) => photo.url) || [],
          amenities:
            hotel.facilities?.map((facility: BookingComHotelFacility) => facility.name) || [],
          rooms: hotel.rooms?.map((room: BookingComHotelRoom) => ({
            id: room.id,
            name: room.name,
            description: room.description,
            maxOccupancy: room.maxOccupancy,
            price: room.price,
            currency: room.currency,
            images: room.photos?.map((photo: BookingComHotelImage) => photo.url) || [],
            amenities:
              room.facilities?.map((facility: BookingComHotelFacility) => facility.name) || [],
          })),
          reviews:
            hotel.reviews?.map((review: BookingComHotelReview) => ({
              rating: review.rating,
              comment: review.comment,
              author: review.author,
              date: review.date,
            })) || [],
          averageRating: this.calculateAverageRating(hotel.reviews || []),
          reviewCount: hotel.reviews?.length || 0,
        },
      };
    } catch (error) {
      this.logger.error(`Error getting hotel details: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        error: `Failed to get hotel details for ID ${hotelId}`,
      };
    }
  }

  /**
   * Alias for getHotelDetails to match integration service interface
   */
  async getPropertyDetails(propertyId: string) {
    return this.getHotelDetails(propertyId);
  }

  /**
   * Get room availability for a hotel
   */
  async getRoomAvailability(
    hotelId: string,
    checkInDate: Date,
    checkOutDate: Date,
    guests: number,
  ) {
    try {
      this.logger.debug(`Getting room availability for hotel ID: ${hotelId}`);

      const response = await axios.get(`${this.apiUrl}/hotels/${hotelId}/rooms`, {
        params: {
          checkin: this.formatDate(checkInDate),
          checkout: this.formatDate(checkOutDate),
          guests: guests,
        },
        headers: {
          Authorization: `Basic ${Buffer.from(`${this.apiKey}:${this.apiSecret}`).toString('base64')}`,
          'X-Affiliate-ID': this.configService.get<string>('BOOKING_COM_AFFILIATE_ID_HEADER') || '',
          Accept: 'application/json',
          'Content-Type': 'application/json',
        },
      });

      const rooms = response.data.result || [];

      return {
        success: true,
        hotelId,
        rooms: rooms.map((room: BookingComHotelRoom) => ({
          id: room.id,
          name: room.name,
          description: room.description,
          maxOccupancy: room.maxOccupancy,
          price: room.price,
          currency: room.currency,
          images: room.photos?.map((photo: BookingComHotelImage) => photo.url) || [],
          amenities:
            room.facilities?.map((facility: BookingComHotelFacility) => facility.name) || [],
        })),
      };
    } catch (error) {
      this.logger.error(`Error getting room availability: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        error: `Failed to get room availability for hotel ID ${hotelId}`,
      };
    }
  }

  /**
   * Helper method to format date for Booking.com API
   */
  private formatDate(date: Date): string {
    return date.toISOString().split('T')[0];
  }

  /**
   * Helper method to calculate average rating
   */
  private calculateAverageRating(reviews: BookingComHotelReview[]): number {
    if (reviews.length === 0) return 0;
    const sum = reviews.reduce((total, review) => total + review.rating, 0);
    return sum / reviews.length;
  }

  /**
   * Generate a redirect URL for Booking.com to complete the booking.
   * FRS: 1.1 (Commission Structure), 2.1 (API Integration Architecture)
   *
   * This method retrieves the complete redirect URL directly from Booking.com's
   * /accommodations/availability endpoint. The URL includes pre-filled details
   * and Nestery's affiliate ID for commission tracking.
   * Nestery does not handle payment for this flow.
   *
   * Booking Confirmation: For this redirect model, Nestery typically relies on
   * Booking.com's affiliate panel reporting for confirmed bookings and commission tracking.
   * Direct server-to-server notifications (webhooks) or return URLs for this specific
   * flow are less common than for full API integrations where the partner handles payment.
   * The simplest approach is to monitor the affiliate dashboard.
   */
  async generateBookingRedirectUrl(
    bookingApiPayload: {
      hotelId: string; // Booking.com's hotel ID
      checkInDate: Date;
      checkOutDate: Date;
      numberOfGuests: number;
      // Guest details can be passed to prefill Booking.com's form if their linking structure supports it.
      // For simplicity, we'll assume basic parameters for now.
      // guestName?: string;
      // guestEmail?: string;
      // currency?: string;
      // language?: string;
      // countryCode?: string; // User's country code
    },
    supplier: Supplier,
  ): Promise<{ success: boolean; redirectUrl?: string; error?: string }> {
    try {
      this.logger.log(
        `Generating Booking.com redirect URL for hotel ID: ${bookingApiPayload.hotelId}.`,
      );

      // Retrieve and validate API credentials
      const apiKey = supplier.apiKey;
      if (!apiKey) {
        this.logger.error('Booking.com API key not configured for supplier.');
        return {
          success: false,
          error: 'Booking.com API key not configured for supplier.',
        };
      }

      const affiliateId = (supplier.configuration as any)?.affiliateId;
      if (!affiliateId) {
        this.logger.error('Booking.com Affiliate ID not configured for supplier.');
        return {
          success: false,
          error: 'Booking.com Affiliate ID not configured for supplier.',
        };
      }

      // Format dates to YYYY-MM-DD format required by Booking.com API
      const checkInFormatted = this.formatDate(bookingApiPayload.checkInDate);
      const checkOutFormatted = this.formatDate(bookingApiPayload.checkOutDate);

      // Construct request body for /accommodations/availability endpoint
      const requestBody = {
        accommodation_ids: [bookingApiPayload.hotelId],
        checkin: checkInFormatted,
        checkout: checkOutFormatted,
        occupancies: [
          {
            adults: bookingApiPayload.numberOfGuests,
            children: [], // For simplicity, current implementation assumes no children
          },
        ],
        // Optional parameters can be added here if needed:
        // currency: userCurrency,
        // language_code: userLanguage,
      };

      this.logger.debug(
        `Calling Booking.com availability API for hotel ${bookingApiPayload.hotelId}, dates: ${checkInFormatted} to ${checkOutFormatted}`,
      );

      // Make API call to Booking.com /accommodations/availability endpoint
      const response = await axios.post(
        'https://demandapi.booking.com/3.1/accommodations/availability',
        requestBody,
        {
          headers: {
            Authorization: `Bearer ${apiKey}`,
            'X-Affiliate-Id': affiliateId,
            'Content-Type': 'application/json',
            Accept: 'application/json',
          },
        },
      );

      // Parse response and extract redirect URL
      if (!response.data) {
        this.logger.error('Empty response from Booking.com availability API');
        return {
          success: false,
          error: 'Empty response from Booking.com API.',
        };
      }

      // Check for URL in common response patterns
      let redirectUrl: string | undefined;

      // Pattern 1: Direct url field in response.data
      if (response.data.url && typeof response.data.url === 'string') {
        redirectUrl = response.data.url;
      }
      // Pattern 2: URL in response.data.data[0].url (array structure)
      else if (
        response.data.data &&
        Array.isArray(response.data.data) &&
        response.data.data.length > 0 &&
        response.data.data[0].url &&
        typeof response.data.data[0].url === 'string'
      ) {
        redirectUrl = response.data.data[0].url;
      }

      if (!redirectUrl) {
        this.logger.error(
          `Redirect URL not found in Booking.com API response for hotel ${bookingApiPayload.hotelId}. Response structure: ${JSON.stringify(response.data, null, 2)}`,
        );
        return {
          success: false,
          error: 'Redirect URL not found in Booking.com API response.',
        };
      }

      this.logger.log(
        `Successfully retrieved Booking.com redirect URL for hotel ID: ${bookingApiPayload.hotelId}`,
      );

      return {
        success: true,
        redirectUrl,
      };
    } catch (error) {
      // Comprehensive error handling for API errors
      if (error.response) {
        // API returned an error response
        const status = error.response.status;
        const errorData = error.response.data;

        this.logger.error(
          `Booking.com API error for hotel ${bookingApiPayload.hotelId}. Status: ${status}, Error: ${JSON.stringify(errorData)}`,
          error.stack,
        );

        // Extract specific error message if available
        const specificError = errorData?.message || errorData?.error || 'API error';

        return {
          success: false,
          error: `Failed to retrieve redirect URL from Booking.com. ${specificError}`,
        };
      } else {
        // Network or other error
        this.logger.error(
          `Network error while calling Booking.com API for hotel ${bookingApiPayload.hotelId}: ${error.message}`,
          error.stack,
        );

        this.exceptionService.handleException(error);

        return {
          success: false,
          error: 'Failed to retrieve redirect URL from Booking.com. Network error.',
        };
      }
    }
  }
}
