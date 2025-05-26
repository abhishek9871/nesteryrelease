import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';

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
  ) {
    const apiUrl = this.configService.get<string>('BOOKING_COM_API_URL');
    if (apiUrl) this.apiUrl = apiUrl;

    const apiKey = this.configService.get<string>('BOOKING_COM_API_KEY');
    if (apiKey) this.apiKey = apiKey;

    const apiSecret = this.configService.get<string>('BOOKING_COM_API_SECRET');
    if (apiSecret) this.apiSecret = apiSecret;

    this.logger.setContext('BookingComService');
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
}
