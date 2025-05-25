import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';

@Injectable()
export class OyoService {
  private readonly apiUrl: string;
  private readonly apiKey: string;
  private readonly partnerId: string;
  
  // Fallback B2B aggregator credentials
  private readonly hotelbedsApiUrl: string;
  private readonly hotelbedsApiKey: string;
  private readonly hotelbedsApiSecret: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    this.apiUrl = this.configService.get<string>('OYO_API_URL');
    this.apiKey = this.configService.get<string>('OYO_API_KEY');
    this.partnerId = this.configService.get<string>('OYO_PARTNER_ID');
    
    this.hotelbedsApiUrl = this.configService.get<string>('HOTELBEDS_API_URL');
    this.hotelbedsApiKey = this.configService.get<string>('HOTELBEDS_API_KEY');
    this.hotelbedsApiSecret = this.configService.get<string>('HOTELBEDS_API_SECRET');
    
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
      this.logger.debug(`Searching OYO hotels with params: ${JSON.stringify(params)}`);
      
      const response = await axios.get(`${this.apiUrl}/hotels/search`, {
        params: {
          city: params.location,
          check_in: this.formatDate(params.checkInDate),
          check_out: this.formatDate(params.checkOutDate),
          guests: params.adults + (params.children || 0),
          rooms: params.rooms || 1,
          price_min: params.minPrice,
          price_max: params.maxPrice,
          amenities: params.amenities?.join(','),
          category: params.propertyType,
          rating_min: params.minRating,
          include_details: true,
        },
        headers: this.getOyoHeaders(),
      });
      
      this.logger.debug(`Found ${response.data.hotels?.length || 0} OYO hotels`);
      return this.transformHotelsResponse(response.data);
    } catch (error) {
      this.logger.warn(`Error searching OYO hotels: ${error.message}. Falling back to B2B aggregator.`);
      
      // Fallback to B2B aggregator if OYO API fails
      try {
        return await this.searchHotelsViaAggregator(params);
      } catch (fallbackError) {
        this.logger.error(`Fallback also failed: ${fallbackError.message}`, fallbackError.stack);
        throw this.exceptionService.handleHttpError(fallbackError, 'Failed to search hotels on OYO and fallback');
      }
    }
  }

  /**
   * Get hotel details by ID
   */
  async getHotelDetails(hotelId: string) {
    try {
      this.logger.debug(`Getting OYO hotel details for ID: ${hotelId}`);
      
      const response = await axios.get(`${this.apiUrl}/hotels/${hotelId}`, {
        params: {
          include_rooms: true,
          include_amenities: true,
          include_photos: true,
          include_policies: true,
        },
        headers: this.getOyoHeaders(),
      });
      
      return this.transformHotelDetailsResponse(response.data);
    } catch (error) {
      this.logger.warn(`Error getting OYO hotel details: ${error.message}. Falling back to B2B aggregator.`);
      
      // Fallback to B2B aggregator if OYO API fails
      try {
        return await this.getHotelDetailsViaAggregator(hotelId);
      } catch (fallbackError) {
        this.logger.error(`Fallback also failed: ${fallbackError.message}`, fallbackError.stack);
        throw this.exceptionService.handleHttpError(fallbackError, 'Failed to get hotel details from OYO and fallback');
      }
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
  }) {
    try {
      this.logger.debug(`Getting OYO room availability for hotel ID: ${params.hotelId}`);
      
      const response = await axios.get(`${this.apiUrl}/hotels/${params.hotelId}/availability`, {
        params: {
          check_in: this.formatDate(params.checkInDate),
          check_out: this.formatDate(params.checkOutDate),
          guests: params.adults + (params.children || 0),
          rooms: params.rooms || 1,
        },
        headers: this.getOyoHeaders(),
      });
      
      return this.transformAvailabilityResponse(response.data);
    } catch (error) {
      this.logger.warn(`Error getting OYO room availability: ${error.message}. Falling back to B2B aggregator.`);
      
      // Fallback to B2B aggregator if OYO API fails
      try {
        return await this.getRoomAvailabilityViaAggregator(params);
      } catch (fallbackError) {
        this.logger.error(`Fallback also failed: ${fallbackError.message}`, fallbackError.stack);
        throw this.exceptionService.handleHttpError(fallbackError, 'Failed to get room availability from OYO and fallback');
      }
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
  }) {
    try {
      this.logger.debug(`Creating OYO booking for hotel ID: ${params.hotelId}, room ID: ${params.roomId}`);
      
      const response = await axios.post(`${this.apiUrl}/bookings`, {
        hotel_id: params.hotelId,
        room_id: params.roomId,
        check_in: this.formatDate(params.checkInDate),
        check_out: this.formatDate(params.checkOutDate),
        guests: params.adults + (params.children || 0),
        rooms: params.rooms || 1,
        guest_details: {
          first_name: params.firstName,
          last_name: params.lastName,
          email: params.email,
          phone: params.phone,
        },
        special_requests: params.specialRequests,
      }, {
        headers: this.getOyoHeaders(),
      });
      
      this.logger.debug(`OYO booking created with ID: ${response.data.booking?.id}`);
      return this.transformBookingResponse(response.data);
    } catch (error) {
      this.logger.warn(`Error creating OYO booking: ${error.message}. Falling back to B2B aggregator.`);
      
      // Fallback to B2B aggregator if OYO API fails
      try {
        return await this.createBookingViaAggregator(params);
      } catch (fallbackError) {
        this.logger.error(`Fallback also failed: ${fallbackError.message}`, fallbackError.stack);
        throw this.exceptionService.handleHttpError(fallbackError, 'Failed to create booking on OYO and fallback');
      }
    }
  }

  /**
   * Get booking details
   */
  async getBookingDetails(bookingId: string) {
    try {
      this.logger.debug(`Getting OYO booking details for ID: ${bookingId}`);
      
      const response = await axios.get(`${this.apiUrl}/bookings/${bookingId}`, {
        headers: this.getOyoHeaders(),
      });
      
      return this.transformBookingResponse(response.data);
    } catch (error) {
      this.logger.warn(`Error getting OYO booking details: ${error.message}. Falling back to B2B aggregator.`);
      
      // Fallback to B2B aggregator if OYO API fails
      try {
        return await this.getBookingDetailsViaAggregator(bookingId);
      } catch (fallbackError) {
        this.logger.error(`Fallback also failed: ${fallbackError.message}`, fallbackError.stack);
        throw this.exceptionService.handleHttpError(fallbackError, 'Failed to get booking details from OYO and fallback');
      }
    }
  }

  /**
   * Cancel booking
   */
  async cancelBooking(bookingId: string) {
    try {
      this.logger.debug(`Cancelling OYO booking with ID: ${bookingId}`);
      
      const response = await axios.delete(`${this.apiUrl}/bookings/${bookingId}`, {
        headers: this.getOyoHeaders(),
      });
      
      this.logger.debug(`OYO booking cancelled successfully`);
      return {
        success: true,
        message: 'Booking cancelled successfully',
        bookingId: bookingId,
        cancellationDetails: response.data,
      };
    } catch (error) {
      this.logger.warn(`Error cancelling OYO booking: ${error.message}. Falling back to B2B aggregator.`);
      
      // Fallback to B2B aggregator if OYO API fails
      try {
        return await this.cancelBookingViaAggregator(bookingId);
      } catch (fallbackError) {
        this.logger.error(`Fallback also failed: ${fallbackError.message}`, fallbackError.stack);
        throw this.exceptionService.handleHttpError(fallbackError, 'Failed to cancel booking on OYO and fallback');
      }
    }
  }

  /**
   * Fallback: Search hotels via B2B aggregator
   */
  private async searchHotelsViaAggregator(params: {
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
    this.logger.debug(`Searching hotels via B2B aggregator with params: ${JSON.stringify(params)}`);
    
    const response = await axios.post(`${this.hotelbedsApiUrl}/hotels`, {
      stay: {
        checkIn: this.formatDate(params.checkInDate),
        checkOut: this.formatDate(params.checkOutDate),
      },
      occupancies: [
        {
          rooms: params.rooms || 1,
          adults: params.adults,
          children: params.children || 0,
        }
      ],
      destination: {
        code: params.location,
      },
      filter: {
        minRate: params.minPrice,
        maxRate: params.maxPrice,
        minCategory: params.minRating ? (params.minRating * 2).toFixed(0) : undefined,
        amenities: params.amenities,
      },
    }, {
      headers: this.getHotelbedsHeaders(),
    });
    
    this.logger.debug(`Found ${response.data.hotels?.hotels?.length || 0} hotels via B2B aggregator`);
    return this.transformHotelbedsHotelsResponse(response.data);
  }

  /**
   * Fallback: Get hotel details via B2B aggregator
   */
  private async getHotelDetailsViaAggregator(hotelId: string) {
    this.logger.debug(`Getting hotel details via B2B aggregator for ID: ${hotelId}`);
    
    const response = await axios.get(`${this.hotelbedsApiUrl}/hotels/${hotelId}`, {
      headers: this.getHotelbedsHeaders(),
    });
    
    return this.transformHotelbedsHotelDetailsResponse(response.data);
  }

  /**
   * Fallback: Get room availability via B2B aggregator
   */
  private async getRoomAvailabilityViaAggregator(params: {
    hotelId: string;
    checkInDate: Date;
    checkOutDate: Date;
    adults: number;
    children?: number;
    rooms?: number;
  }) {
    this.logger.debug(`Getting room availability via B2B aggregator for hotel ID: ${params.hotelId}`);
    
    const response = await axios.post(`${this.hotelbedsApiUrl}/hotels`, {
      stay: {
        checkIn: this.formatDate(params.checkInDate),
        checkOut: this.formatDate(params.checkOutDate),
      },
      occupancies: [
        {
          rooms: params.rooms || 1,
          adults: params.adults,
          children: params.children || 0,
        }
      ],
      hotels: {
        hotel: [params.hotelId],
      },
    }, {
      headers: this.getHotelbedsHeaders(),
    });
    
    return this.transformHotelbedsAvailabilityResponse(response.data);
  }

  /**
   * Fallback: Create booking via B2B aggregator
   */
  private async createBookingViaAggregator(params: {
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
  }) {
    this.logger.debug(`Creating booking via B2B aggregator for hotel ID: ${params.hotelId}, room ID: ${params.roomId}`);
    
    const response = await axios.post(`${this.hotelbedsApiUrl}/bookings`, {
      holder: {
        name: params.firstName,
        surname: params.lastName,
        email: params.email,
        phone: params.phone,
      },
      rooms: [
        {
          rateKey: params.roomId,
          paxes: [
            {
              roomId: 1,
              type: 'AD',
              name: params.firstName,
              surname: params.lastName,
            }
          ],
        }
      ],
      clientReference: `NESTERY-${Date.now()}`,
      remark: params.specialRequests,
    }, {
      headers: this.getHotelbedsHeaders(),
    });
    
    this.logger.debug(`Booking created via B2B aggregator with ID: ${response.data.booking?.reference}`);
    return this.transformHotelbedsBookingResponse(response.data);
  }

  /**
   * Fallback: Get booking details via B2B aggregator
   */
  private async getBookingDetailsViaAggregator(bookingId: string) {
    this.logger.debug(`Getting booking details via B2B aggregator for ID: ${bookingId}`);
    
    const response = await axios.get(`${this.hotelbedsApiUrl}/bookings/${bookingId}`, {
      headers: this.getHotelbedsHeaders(),
    });
    
    return this.transformHotelbedsBookingResponse(response.data);
  }

  /**
   * Fallback: Cancel booking via B2B aggregator
   */
  private async cancelBookingViaAggregator(bookingId: string) {
    this.logger.debug(`Cancelling booking via B2B aggregator with ID: ${bookingId}`);
    
    const response = await axios.delete(`${this.hotelbedsApiUrl}/bookings/${bookingId}`, {
      headers: this.getHotelbedsHeaders(),
    });
    
    this.logger.debug(`Booking cancelled successfully via B2B aggregator`);
    return {
      success: true,
      message: 'Booking cancelled successfully',
      bookingId: bookingId,
      cancellationFee: response.data.booking?.cancellationFee,
      refundAmount: response.data.booking?.refundAmount,
    };
  }

  /**
   * Transform OYO hotels response to standardized format
   */
  private transformHotelsResponse(data: any) {
    try {
      const hotels = data.hotels || [];
      
      return {
        hotels: hotels.map(hotel => ({
          id: hotel.id,
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
          thumbnailImage: hotel.images?.[0],
          images: hotel.images || [],
          amenities: hotel.amenities || [],
          sourceType: 'OYO',
          cancellationPolicy: hotel.cancellation_policy,
        })),
        totalCount: data.total_count,
        pagination: data.pagination,
      };
    } catch (error) {
      this.logger.error(`Error transforming OYO hotels response: ${error.message}`, error.stack);
      throw new Error('Failed to transform OYO hotels response');
    }
  }

  /**
   * Transform OYO hotel details response to standardized format
   */
  private transformHotelDetailsResponse(data: any) {
    try {
      const hotel = data.hotel || {};
      
      return {
        id: hotel.id,
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
        thumbnailImage: hotel.images?.[0],
        images: hotel.images || [],
        amenities: hotel.amenities || [],
        rooms: hotel.rooms?.map(room => ({
          id: room.id,
          name: room.name,
          description: room.description,
          price: room.price,
          currency: room.currency,
          capacity: room.capacity,
          amenities: room.amenities || [],
        })) || [],
        reviews: hotel.reviews?.map(review => ({
          id: review.id,
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
        sourceType: 'OYO',
      };
    } catch (error) {
      this.logger.error(`Error transforming OYO hotel details response: ${error.message}`, error.stack);
      throw new Error('Failed to transform OYO hotel details response');
    }
  }

  /**
   * Transform OYO availability response to standardized format
   */
  private transformAvailabilityResponse(data: any) {
    try {
      const rooms = data.rooms || [];
      
      return {
        available: data.available,
        rooms: rooms.map(room => ({
          id: room.id,
          name: room.name,
          description: room.description,
          price: room.price,
          currency: room.currency,
          available: room.available,
          capacity: room.capacity,
          amenities: room.amenities || [],
        })),
        totalPrice: data.total_price,
        currency: data.currency,
        nights: data.nights,
      };
    } catch (error) {
      this.logger.error(`Error transforming OYO availability response: ${error.message}`, error.stack);
      throw new Error('Failed to transform OYO availability response');
    }
  }

  /**
   * Transform OYO booking response to standardized format
   */
  private transformBookingResponse(data: any) {
    try {
      const booking = data.booking || {};
      
      return {
        id: booking.id,
        hotelId: booking.hotel_id,
        roomId: booking.room_id,
        checkInDate: booking.check_in,
        checkOutDate: booking.check_out,
        guestName: booking.guest_name,
        guestEmail: booking.guest_email,
        guestPhone: booking.guest_phone,
        status: booking.status,
        totalPrice: booking.total_price,
        currency: booking.currency,
        createdAt: booking.created_at,
        updatedAt: booking.updated_at,
        sourceType: 'OYO',
      };
    } catch (error) {
      this.logger.error(`Error transforming OYO booking response: ${error.message}`, error.stack);
      throw new Error('Failed to transform OYO booking response');
    }
  }

  /**
   * Transform Hotelbeds hotels response to standardized format
   */
  private transformHotelbedsHotelsResponse(data: any) {
    try {
      const hotels = data.hotels?.hotels || [];
      
      return {
        hotels: hotels.map(hotel => ({
          id: hotel.code,
          name: hotel.name,
          description: hotel.description,
          address: hotel.address,
          city: hotel.city,
          country: hotel.country,
          zipCode: hotel.postalCode,
          latitude: hotel.coordinates?.latitude,
          longitude: hotel.coordinates?.longitude,
          rating: hotel.categoryCode / 2, // Convert 5-star scale to 2.5-star scale
          reviewCount: hotel.reviews?.count || 0,
          price: hotel.minRate,
          currency: hotel.currency,
          thumbnailImage: hotel.images?.[0]?.url,
          images: hotel.images?.map(image => image.url) || [],
          amenities: hotel.facilities?.map(facility => facility.description) || [],
          sourceType: 'OYO',
          cancellationPolicy: hotel.cancellationPolicies?.[0]?.description,
        })),
        totalCount: data.hotels?.total || 0,
        pagination: {
          currentPage: data.hotels?.from || 1,
          totalPages: Math.ceil((data.hotels?.total || 0) / (data.hotels?.to || 10)),
        },
      };
    } catch (error) {
      this.logger.error(`Error transforming Hotelbeds hotels response: ${error.message}`, error.stack);
      throw new Error('Failed to transform Hotelbeds hotels response');
    }
  }

  /**
   * Transform Hotelbeds hotel details response to standardized format
   */
  private transformHotelbedsHotelDetailsResponse(data: any) {
    try {
      const hotel = data.hotel || {};
      
      return {
        id: hotel.code,
        name: hotel.name,
        description: hotel.description,
        address: hotel.address,
        city: hotel.city,
        country: hotel.country,
        zipCode: hotel.postalCode,
        latitude: hotel.coordinates?.latitude,
        longitude: hotel.coordinates?.longitude,
        rating: hotel.categoryCode / 2, // Convert 5-star scale to 2.5-star scale
        reviewCount: hotel.reviews?.count || 0,
        price: hotel.minRate,
        currency: hotel.currency,
        thumbnailImage: hotel.images?.[0]?.url,
        images: hotel.images?.map(image => image.url) || [],
        amenities: hotel.facilities?.map(facility => facility.description) || [],
        rooms: hotel.rooms?.map(room => ({
          id: room.code,
          name: room.name,
          description: room.description,
          price: room.rates?.[0]?.net,
          currency: room.rates?.[0]?.currency,
          capacity: room.capacity,
          amenities: room.facilities?.map(facility => facility.description) || [],
        })) || [],
        reviews: hotel.reviews?.reviews?.map(review => ({
          id: review.reviewId,
          title: review.title,
          comment: review.comments,
          rating: review.rate,
          date: review.date,
          author: review.user,
        })) || [],
        policies: {
          checkIn: hotel.checkIn,
          checkOut: hotel.checkOut,
          cancellation: hotel.cancellationPolicies?.[0]?.description,
          children: hotel.childrenPolicy,
          pets: hotel.petPolicy,
        },
        sourceType: 'OYO',
      };
    } catch (error) {
      this.logger.error(`Error transforming Hotelbeds hotel details response: ${error.message}`, error.stack);
      throw new Error('Failed to transform Hotelbeds hotel details response');
    }
  }

  /**
   * Transform Hotelbeds availability response to standardized format
   */
  private transformHotelbedsAvailabilityResponse(data: any) {
    try {
      const hotel = data.hotels?.hotels?.[0] || {};
      const rooms = hotel.rooms || [];
      
      return {
        available: rooms.length > 0,
        rooms: rooms.map(room => ({
          id: room.code,
          name: room.name,
          description: room.description,
          price: room.rates?.[0]?.net,
          currency: room.rates?.[0]?.currency,
          available: true,
          capacity: room.capacity,
          amenities: room.facilities?.map(facility => facility.description) || [],
        })),
        totalPrice: hotel.totalNet,
        currency: hotel.currency,
        nights: this.calculateNights(data.hotels?.checkIn, data.hotels?.checkOut),
      };
    } catch (error) {
      this.logger.error(`Error transforming Hotelbeds availability response: ${error.message}`, error.stack);
      throw new Error('Failed to transform Hotelbeds availability response');
    }
  }

  /**
   * Transform Hotelbeds booking response to standardized format
   */
  private transformHotelbedsBookingResponse(data: any) {
    try {
      const booking = data.booking || {};
      
      return {
        id: booking.reference,
        hotelId: booking.hotel?.code,
        roomId: booking.rooms?.[0]?.code,
        checkInDate: booking.hotel?.checkIn,
        checkOutDate: booking.hotel?.checkOut,
        guestName: `${booking.holder?.name} ${booking.holder?.surname}`,
        guestEmail: booking.holder?.email,
        guestPhone: booking.holder?.phone,
        status: booking.status,
        totalPrice: booking.totalNet,
        currency: booking.currency,
        createdAt: booking.creationDate,
        updatedAt: booking.modificationDate,
        sourceType: 'OYO',
      };
    } catch (error) {
      this.logger.error(`Error transforming Hotelbeds booking response: ${error.message}`, error.stack);
      throw new Error('Failed to transform Hotelbeds booking response');
    }
  }

  /**
   * Get headers for OYO API requests
   */
  private getOyoHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-KEY': this.apiKey,
      'X-PARTNER-ID': this.partnerId,
    };
  }

  /**
   * Get headers for Hotelbeds API requests
   */
  private getHotelbedsHeaders() {
    // Generate signature based on API key and secret
    const timestamp = Date.now().toString();
    const signature = this.generateHotelbedsSignature(timestamp);
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Api-Key': this.hotelbedsApiKey,
      'X-Signature': signature,
    };
  }

  /**
   * Generate signature for Hotelbeds API authentication
   */
  private generateHotelbedsSignature(timestamp: string): string {
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

  /**
   * Calculate number of nights between two dates
   */
  private calculateNights(checkIn: string, checkOut: string): number {
    if (!checkIn || !checkOut) return 0;
    
    const checkInDate = new Date(checkIn);
    const checkOutDate = new Date(checkOut);
    
    const diffTime = Math.abs(checkOutDate.getTime() - checkInDate.getTime());
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    
    return diffDays;
  }
}
