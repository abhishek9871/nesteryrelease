import { Injectable, NotFoundException, BadRequestException, ForbiddenException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between, LessThanOrEqual, MoreThanOrEqual } from 'typeorm';
import { Booking } from './entities/booking.entity';
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateBookingDto } from './dto/update-booking.dto';
import { SearchBookingsDto } from './dto/search-bookings.dto';
import { UsersService } from '../users/users.service';
import { PropertiesService } from '../properties/properties.service';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';
import { v4 as uuidv4 } from 'uuid';

/**
 * Service handling booking-related operations
 */
@Injectable()
export class BookingsService {
  constructor(
    @InjectRepository(Booking)
    private readonly bookingsRepository: Repository<Booking>,
    private readonly usersService: UsersService,
    private readonly propertiesService: PropertiesService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    this.logger.setContext('BookingsService');
  }

  /**
   * Create a new booking
   */
  async create(userId: string, createBookingDto: CreateBookingDto): Promise<Booking> {
    try {
      // Validate user
      const user = await this.usersService.findById(userId);
      if (!user) {
        throw new NotFoundException('User not found');
      }

      // Validate property
      const property = await this.propertiesService.findById(createBookingDto.propertyId);
      if (!property) {
        throw new NotFoundException('Property not found');
      }

      // Validate dates
      if (createBookingDto.checkInDate >= createBookingDto.checkOutDate) {
        throw new BadRequestException('Check-out date must be after check-in date');
      }

      // Check if property is available for the selected dates
      const existingBookings = await this.bookingsRepository.find({
        where: {
          propertyId: createBookingDto.propertyId,
          status: 'confirmed',
          checkInDate: LessThanOrEqual(createBookingDto.checkOutDate),
          checkOutDate: MoreThanOrEqual(createBookingDto.checkInDate),
        },
      });

      if (existingBookings.length > 0) {
        throw new BadRequestException('Property is not available for the selected dates');
      }

      // Calculate number of nights
      const checkInDate = new Date(createBookingDto.checkInDate);
      const checkOutDate = new Date(createBookingDto.checkOutDate);
      const nights = Math.ceil((checkOutDate.getTime() - checkInDate.getTime()) / (1000 * 60 * 60 * 24));

      // Calculate total price
      let totalPrice = property.basePrice * nights;

      // Apply premium discount if applicable
      if (user.isPremium && createBookingDto.isPremiumBooking) {
        totalPrice *= 0.9; // 10% discount for premium users
      }

      // Apply loyalty points redemption if applicable
      let loyaltyPointsRedeemed = 0;
      if (createBookingDto.loyaltyPointsToRedeem && createBookingDto.loyaltyPointsToRedeem > 0) {
        if (createBookingDto.loyaltyPointsToRedeem > user.loyaltyPoints) {
          throw new BadRequestException('Not enough loyalty points');
        }

        // Convert loyalty points to discount (1 point = $0.01)
        const loyaltyDiscount = createBookingDto.loyaltyPointsToRedeem * 0.01;
        
        // Ensure discount doesn't exceed total price
        const maxDiscount = totalPrice * 0.3; // Max 30% discount from loyalty points
        const appliedDiscount = Math.min(loyaltyDiscount, maxDiscount);
        
        totalPrice -= appliedDiscount;
        loyaltyPointsRedeemed = createBookingDto.loyaltyPointsToRedeem;
        
        // Deduct loyalty points from user
        await this.usersService.addLoyaltyPoints(userId, -loyaltyPointsRedeemed);
      }

      // Calculate loyalty points earned (1 point per $1 spent)
      const loyaltyPointsEarned = Math.floor(totalPrice);

      // Generate confirmation code
      const confirmationCode = this.generateConfirmationCode();

      // Create booking
      const booking = this.bookingsRepository.create({
        userId,
        propertyId: createBookingDto.propertyId,
        checkInDate: createBookingDto.checkInDate,
        checkOutDate: createBookingDto.checkOutDate,
        numberOfGuests: createBookingDto.numberOfGuests,
        totalPrice,
        currency: property.currency,
        status: 'pending',
        confirmationCode,
        specialRequests: createBookingDto.specialRequests,
        paymentMethod: createBookingDto.paymentMethod,
        isPremiumBooking: createBookingDto.isPremiumBooking || false,
        loyaltyPointsEarned,
        loyaltyPointsRedeemed,
        sourceType: createBookingDto.sourceType || 'direct',
      });

      const savedBooking = await this.bookingsRepository.save(booking);

      // Add loyalty points to user
      await this.usersService.addLoyaltyPoints(userId, loyaltyPointsEarned);

      this.logger.log(`Booking created: ${savedBooking.id} for user ${userId}`);
      return savedBooking;
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Find all bookings with optional pagination
   */
  async findAll(page: number = 1, limit: number = 10): Promise<{ bookings: Booking[]; total: number }> {
    try {
      const [bookings, total] = await this.bookingsRepository.findAndCount({
        skip: (page - 1) * limit,
        take: limit,
        order: {
          createdAt: 'DESC',
        },
        relations: ['user', 'property'],
      });

      return { bookings, total };
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Search bookings based on criteria
   */
  async search(searchDto: SearchBookingsDto): Promise<{ bookings: Booking[]; total: number }> {
    try {
      const { userId, propertyId, status, checkInDateStart, checkInDateEnd, page = 1, limit = 10 } = searchDto;

      // Build query conditions
      const whereConditions: any = {};

      if (userId) {
        whereConditions.userId = userId;
      }

      if (propertyId) {
        whereConditions.propertyId = propertyId;
      }

      if (status) {
        whereConditions.status = status;
      }

      // Date range conditions
      if (checkInDateStart && checkInDateEnd) {
        whereConditions.checkInDate = Between(checkInDateStart, checkInDateEnd);
      } else if (checkInDateStart) {
        whereConditions.checkInDate = MoreThanOrEqual(checkInDateStart);
      } else if (checkInDateEnd) {
        whereConditions.checkInDate = LessThanOrEqual(checkInDateEnd);
      }

      // Execute query with pagination
      const [bookings, total] = await this.bookingsRepository.findAndCount({
        where: whereConditions,
        skip: (page - 1) * limit,
        take: limit,
        order: {
          checkInDate: 'ASC',
        },
        relations: ['user', 'property'],
      });

      return { bookings, total };
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Find bookings by user ID
   */
  async findByUserId(userId: string, page: number = 1, limit: number = 10): Promise<{ bookings: Booking[]; total: number }> {
    try {
      const [bookings, total] = await this.bookingsRepository.findAndCount({
        where: { userId },
        skip: (page - 1) * limit,
        take: limit,
        order: {
          createdAt: 'DESC',
        },
        relations: ['property'],
      });

      return { bookings, total };
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Find a booking by ID
   */
  async findById(id: string): Promise<Booking> {
    try {
      const booking = await this.bookingsRepository.findOne({
        where: { id },
        relations: ['user', 'property'],
      });

      if (!booking) {
        throw new NotFoundException(`Booking with ID ${id} not found`);
      }

      return booking;
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Update a booking
   */
  async update(id: string, updateBookingDto: UpdateBookingDto, userId?: string): Promise<Booking> {
    try {
      const booking = await this.findById(id);

      // If userId is provided, ensure the booking belongs to the user
      if (userId && booking.userId !== userId) {
        throw new ForbiddenException('You do not have permission to update this booking');
      }

      // Handle status changes
      if (updateBookingDto.status && updateBookingDto.status !== booking.status) {
        if (updateBookingDto.status === 'cancelled') {
          if (!updateBookingDto.cancellationReason) {
            throw new BadRequestException('Cancellation reason is required');
          }

          // Handle cancellation logic (e.g., refund loyalty points)
          if (booking.loyaltyPointsRedeemed > 0) {
            await this.usersService.addLoyaltyPoints(booking.userId, booking.loyaltyPointsRedeemed);
          }

          // Deduct earned loyalty points
          if (booking.loyaltyPointsEarned > 0) {
            await this.usersService.addLoyaltyPoints(booking.userId, -booking.loyaltyPointsEarned);
          }
        }
      }

      // Update booking fields
      Object.assign(booking, updateBookingDto);

      return await this.bookingsRepository.save(booking);
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Remove a booking
   */
  async remove(id: string): Promise<void> {
    try {
      const result = await this.bookingsRepository.delete(id);
      if (result.affected === 0) {
        throw new NotFoundException(`Booking with ID ${id} not found`);
      }
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Generate a unique confirmation code
   */
  private generateConfirmationCode(): string {
    const prefix = 'NST';
    const timestamp = Date.now().toString().slice(-6);
    const random = Math.floor(Math.random() * 10000).toString().padStart(4, '0');
    return `${prefix}-${timestamp}-${random}`;
  }
}
