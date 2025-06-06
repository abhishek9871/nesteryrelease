import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  Req,
  ForbiddenException,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Request } from 'express';
import { BookingsService } from './bookings.service';

interface AuthenticatedRequest extends Request {
  user: {
    id: string;
    email: string;
    name: string;
    role: string;
  };
}
import { CreateBookingDto } from './dto/create-booking.dto';
import { UpdateBookingDto } from './dto/update-booking.dto';
import { SearchBookingsDto } from './dto/search-bookings.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { Booking } from './entities/booking.entity';

/**
 * Controller handling booking-related endpoints
 */
@ApiTags('bookings')
@Controller('bookings')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class BookingsController {
  constructor(private readonly bookingsService: BookingsService) {}

  /**
   * Create a new booking
   */
  @Post()
  @ApiOperation({ summary: 'Create a new booking' })
  @ApiResponse({ status: 201, description: 'Booking created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  async create(
    @Req() req: AuthenticatedRequest,
    @Body() createBookingDto: CreateBookingDto,
  ): Promise<Booking | { redirectUrl: string; sourceType: string }> {
    return this.bookingsService.create(req.user.id, createBookingDto);
  }

  /**
   * Get all bookings (admin only)
   */
  @Get()
  @Roles('admin')
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Get all bookings (admin only)' })
  @ApiQuery({ name: 'page', required: false, type: Number, description: 'Page number' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Items per page' })
  @ApiResponse({ status: 200, description: 'Bookings retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async findAll(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.bookingsService.findAll(page, limit);
  }

  /**
   * Search bookings (admin only)
   */
  @Get('search')
  @Roles('admin')
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Search bookings (admin only)' })
  @ApiResponse({ status: 200, description: 'Bookings retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async search(@Query() searchDto: SearchBookingsDto) {
    return this.bookingsService.search(searchDto);
  }

  /**
   * Get current user's bookings
   */
  @Get('my-bookings')
  @ApiOperation({ summary: "Get current user's bookings" })
  @ApiQuery({ name: 'page', required: false, type: Number, description: 'Page number' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Items per page' })
  @ApiResponse({ status: 200, description: 'Bookings retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async findMyBookings(
    @Req() req: AuthenticatedRequest,
    @Query('page') page?: number,
    @Query('limit') limit?: number,
  ) {
    return this.bookingsService.findByUserId(req.user.id, page, limit);
  }

  /**
   * Get booking by ID
   */
  @Get(':id')
  @ApiOperation({ summary: 'Get booking by ID' })
  @ApiResponse({ status: 200, description: 'Booking retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  async findOne(@Param('id') id: string, @Req() req: AuthenticatedRequest) {
    const booking = await this.bookingsService.findById(id);

    // Check if booking belongs to the user or user is admin
    if (booking.userId !== req.user.id && req.user.role !== 'admin') {
      throw new ForbiddenException('You do not have permission to access this booking');
    }

    return booking;
  }

  /**
   * Update booking by ID
   */
  @Patch(':id')
  @ApiOperation({ summary: 'Update booking by ID' })
  @ApiResponse({ status: 200, description: 'Booking updated successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  async update(
    @Param('id') id: string,
    @Body() updateBookingDto: UpdateBookingDto,
    @Req() req: AuthenticatedRequest,
  ) {
    // Admin can update any booking, users can only update their own
    if (req.user.role === 'admin') {
      return this.bookingsService.update(id, updateBookingDto);
    } else {
      return this.bookingsService.update(id, updateBookingDto, req.user.id);
    }
  }

  /**
   * Delete booking by ID (admin only)
   */
  @Delete(':id')
  @Roles('admin')
  @UseGuards(RolesGuard)
  @ApiOperation({ summary: 'Delete booking by ID (admin only)' })
  @ApiResponse({ status: 200, description: 'Booking deleted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  @ApiResponse({ status: 404, description: 'Booking not found' })
  async remove(@Param('id') id: string) {
    await this.bookingsService.remove(id);
    return { message: 'Booking deleted successfully' };
  }
}
