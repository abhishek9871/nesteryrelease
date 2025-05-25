import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';

@Injectable()
export class BookingComService {
  private readonly apiUrl: string;
  private readonly apiKey: string;
  private readonly apiSecret: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    this.apiUrl = this.configService.get<string>('BOOKING_COM_API_URL');
    this.apiKey = this.configService.get<string>('BOOKING_COM_API_KEY');
    this.apiSecret = this.configService.get<string>('BOOKING_COM_API_SECRET');
    
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
          extras: 'hotel_info,room_info,hotel_photos,hotel_facilities',
          language: 'en-us',
          currency: 'USD',
        },
        headers: this.getHeaders(),
      });
      
      this.logger.debug(`Found ${response.data.hotels?.length || 0} hotels`);
      return this.transformHotelsResponse(response.data);
    } catch (error) {
      this.logger.error(`Error searching hotels: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to search hotels on Booking.com');
    }
  }

  /**
   * Get hotel details by ID
   */
  async getHotelDetails(hotelId: string, params?: {
    language?: string;
    currency?: string;
  }) {
    try {
      this.logger.debug(`Getting hotel details for ID: ${hotelId}`);
      
      const response = await axios.get(`${this.apiUrl}/hotels/${hotelId}`, {
        params: {
          extras: 'hotel_info,room_info,hotel_photos,hotel_facilities,hotel_policies,hotel_description',
          language: params?.language || 'en-us',
          currency: params?.currency || 'USD',
        },
        headers: this.getHeaders(),
      });
      
      return this.transformHotelDetailsResponse(response.data);
    } catch (error) {
      this.logger.error(`Error getting hotel details: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to get hotel details from Booking.com');
    }
  }

  /**
   * Get room availability for a hotel
   */
  async getRoomAvailability(params: {
    hotelId: string;
    checkInDate: Date;
    checkOutDate: Date;
    adults: number;
    children?: number;
    rooms?: number;
    currency?: string;
  }) {
    try {
      this.logger.debug(`Getting room availability for hotel ID: ${params.hotelId}`);
      
      const response = await axios.get(`${this.apiUrl}/hotels/${params.hotelId}/availability`, {
        params: {
          checkin: this.formatDate(params.checkInDate),
          checkout: this.formatDate(params.checkOutDate),
          adults: params.adults,
          children: params.children,
          rooms: params.rooms || 1,
          currency: params.currency || 'USD',
        },
        headers: this.getHeaders(),
      });
      
      return this.transformAvailabilityResponse(response.data);
    } catch (error) {
      this.logger.error(`Error getting room availability: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to get room availability from Booking.com');
    }
  }

  /**
   * Create a booking
   */
  async createBooking(params: {
    hotelId: string;
    roomId: string;
    checkInDate: Date;
    checkOutDate: Date;
    adults: number;
    firstName: string;
    lastName: string;
    email: string;
    phone?: string;
    children?: number;
    rooms?: number;
    specialRequests?: string;
    currency?: string;
  }) {
    try {
      this.logger.debug(`Creating booking for hotel ID: ${params.hotelId}, room ID: ${params.roomId}`);
      
      const response = await axios.post(`${this.apiUrl}/bookings`, {
        hotel_id: params.hotelId,
        room_id: params.roomId,
        checkin: this.formatDate(params.checkInDate),
        checkout: this.formatDate(params.checkOutDate),
        adults: params.adults,
        children: params.children,
        rooms: params.rooms || 1,
        guest: {
          first_name: params.firstName,
          last_name: params.lastName,
          email: params.email,
          phone: params.phone,
        },
        special_requests: params.specialRequests,
        currency: params.currency || 'USD',
      }, {
        headers: this.getHeaders(),
      });
      
      this.logger.debug(`Booking created with ID: ${response.data.booking?.id}`);
      return this.transformBookingResponse(response.data);
    } catch (error) {
      this.logger.error(`Error creating booking: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to create booking on Booking.com');
    }
  }

  /**
   * Get booking details
   */
  async getBookingDetails(bookingId: string) {
    try {
      this.logger.debug(`Getting booking details for ID: ${bookingId}`);
      
      const response = await axios.get(`${this.apiUrl}/bookings/${bookingId}`, {
        headers: this.getHeaders(),
      });
      
      return this.transformBookingResponse(response.data);
    } catch (error) {
      this.logger.error(`Error getting booking details: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to get booking details from Booking.com');
    }
  }

  /**
   * Cancel booking
   */
  async cancelBooking(bookingId: string) {
    try {
      this.logger.debug(`Cancelling booking with ID: ${bookingId}`);
      
      const response = await axios.delete(`${this.apiUrl}/bookings/${bookingId}`, {
        headers: this.getHeaders(),
      });
      
      this.logger.debug(`Booking cancelled successfully`);
      return {
        success: true,
        message: 'Booking cancelled successfully',
        cancellationDetails: response.data,
      };
    } catch (error) {
      this.logger.error(`Error cancelling booking: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to cancel booking on Booking.com');
    }
  }

  /**
   * Transform hotels search response to standardized format
   */
  private transformHotelsResponse(data: any) {
    try {
      const hotels = data.hotels || [];
      
      return {
        hotels: hotels.map(hotel => ({
          id: hotel.hotel_id,
          name: hotel.name,
          description: hotel.description,
          address: hotel.address,
          city: hotel.city,
          country: hotel.country,
          zipCode: hotel.zip_code,
          latitude: hotel.latitude,
          longitude: hotel.longitude,
          rating: hotel.rating,
          reviewCount: hotel.review_count,
          price: hotel.price,
          currency: hotel.currency,
          thumbnailImage: hotel.photos?.[0]?.url,
          images: hotel.photos?.map(photo => photo.url) || [],
          amenities: hotel.facilities?.map(facility => facility.name) || [],
          sourceType: 'Booking.com',
          cancellationPolicy: hotel.policies?.cancellation,
        })),
        totalCount: data.total_count,
        pagination: data.pagination,
      };
    } catch (error) {
      this.logger.error(`Error transforming hotels response: ${error.message}`, error.stack);
      throw new Error('Failed to transform hotels response');
    }
  }

  /**
   * Transform hotel details response to standardized format
   */
  private transformHotelDetailsResponse(data: any) {
    try {
      const hotel = data.hotel || {};
      
      return {
        id: hotel.hotel_id,
        name: hotel.name,
        description: hotel.description,
        address: hotel.address,
        city: hotel.city,
        country: hotel.country,
        zipCode: hotel.zip_code,
        latitude: hotel.latitude,
        longitude: hotel.longitude,
        rating: hotel.rating,
        reviewCount: hotel.review_count,
        price: hotel.price,
        currency: hotel.currency,
        thumbnailImage: hotel.photos?.[0]?.url,
        images: hotel.photos?.map(photo => photo.url) || [],
        amenities: hotel.facilities?.map(facility => facility.name) || [],
        rooms: hotel.rooms?.map(room => ({
          id: room.room_id,
          name: room.name,
          description: room.description,
          price: room.price,
          currency: room.currency,
          capacity: room.capacity,
          amenities: room.facilities?.map(facility => facility.name) || [],
        })) || [],
        reviews: hotel.reviews?.map(review => ({
          id: review.review_id,
          title: review.title,
          comment: review.comment,
          rating: review.rating,
          date: review.date,
          author: review.author,
        })) || [],
        policies: {
          checkIn: hotel.policies?.check_in,
          checkOut: hotel.policies?.check_out,
          cancellation: hotel.policies?.cancellation,
          children: hotel.policies?.children,
          pets: hotel.policies?.pets,
        },
        sourceType: 'Booking.com',
      };
    } catch (error) {
      this.logger.error(`Error transforming hotel details response: ${error.message}`, error.stack);
      throw new Error('Failed to transform hotel details response');
    }
  }

  /**
   * Transform availability response to standardized format
   */
  private transformAvailabilityResponse(data: any) {
    try {
      const rooms = data.rooms || [];
      
      return {
        available: data.available,
        rooms: rooms.map(room => ({
          id: room.room_id,
          name: room.name,
          description: room.description,
          price: room.price,
          currency: room.currency,
          available: room.available,
          capacity: room.capacity,
          amenities: room.facilities?.map(facility => facility.name) || [],
        })),
        totalPrice: data.total_price,
        currency: data.currency,
        nights: data.nights,
      };
    } catch (error) {
      this.logger.error(`Error transforming availability response: ${error.message}`, error.stack);
      throw new Error('Failed to transform availability response');
    }
  }

  /**
   * Transform booking response to standardized format
   */
  private transformBookingResponse(data: any) {
    try {
      const booking = data.booking || {};
      
      return {
        id: booking.booking_id,
        hotelId: booking.hotel_id,
        roomId: booking.room_id,
        checkInDate: booking.checkin,
        checkOutDate: booking.checkout,
        adults: booking.adults,
        children: booking.children,
        rooms: booking.rooms,
        guestDetails: booking.guest,
        specialRequests: booking.special_requests,
        totalPrice: booking.total_price,
        currency: booking.currency,
        status: booking.status,
        createdAt: booking.created_at,
        updatedAt: booking.updated_at,
        sourceType: 'Booking.com',
      };
    } catch (error) {
      this.logger.error(`Error transforming booking response: ${error.message}`, error.stack);
      throw new Error('Failed to transform booking response');
    }
  }

  /**
   * Get headers for API requests
   */
  private getHeaders() {
    // Generate signature based on API key and secret
    const timestamp = Date.now().toString();
    const signature = this.generateSignature(timestamp);
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-Key': this.apiKey,
      'X-Signature': signature,
      'X-Timestamp': timestamp,
    };
  }

  /**
   * Generate signature for API authentication
   */
  private generateSignature(timestamp: string): string {
    // In a real implementation, this would use a proper hashing algorithm
    // For now, we'll just return a placeholder
    return 'signature-placeholder';
  }

  /**
   * Format date to YYYY-MM-DD
   */
  private formatDate(date: Date): string {
    return date.toISOString().split('T')[0];
  }
}
