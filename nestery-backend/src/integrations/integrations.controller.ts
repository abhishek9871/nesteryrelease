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
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { IntegrationsService } from './integrations.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

/**
 * Controller handling integration endpoints
 */
@ApiTags('integrations')
@Controller('integrations')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class IntegrationsController {
  constructor(private readonly integrationsService: IntegrationsService) {}

  /**
   * Search properties across all integrated providers
   */
  @Get('properties/search')
  @ApiOperation({ summary: 'Search properties across all integrated providers' })
  @ApiResponse({ status: 200, description: 'Properties retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async searchProperties(@Query() searchParams: any) {
    return this.integrationsService.searchProperties(searchParams);
  }

  /**
   * Get property details from the appropriate provider
   */
  @Get('properties/:propertyId')
  @ApiOperation({ summary: 'Get property details from the appropriate provider' })
  @ApiQuery({
    name: 'sourceType',
    required: true,
    type: String,
    description: 'Source type (booking_com, oyo, etc.)',
  })
  @ApiResponse({ status: 200, description: 'Property details retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  async getPropertyDetails(
    @Param('propertyId') propertyId: string,
    @Query('sourceType') sourceType: string,
  ) {
    return this.integrationsService.getPropertyDetails(propertyId, sourceType);
  }

  /**
   * Create a booking with the appropriate provider
   */
  @Post('bookings')
  @ApiOperation({ summary: 'Create a booking with the appropriate provider' })
  @ApiResponse({ status: 201, description: 'Booking created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async createBooking(@Body() bookingData: any) {
    return this.integrationsService.createBooking(bookingData);
  }

  /**
   * Get nearby places using Google Maps API
   */
  @Get('places/nearby')
  @ApiOperation({ summary: 'Get nearby places using Google Maps API' })
  @ApiQuery({ name: 'latitude', required: true, type: Number, description: 'Latitude coordinate' })
  @ApiQuery({
    name: 'longitude',
    required: true,
    type: Number,
    description: 'Longitude coordinate',
  })
  @ApiQuery({
    name: 'radius',
    required: false,
    type: Number,
    description: 'Search radius in meters (default: 1000)',
  })
  @ApiQuery({
    name: 'type',
    required: false,
    type: String,
    description: 'Place type (e.g., restaurant, hotel, etc.)',
  })
  @ApiResponse({ status: 200, description: 'Nearby places retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getNearbyPlaces(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @Query('radius') radius: number = 1000,
    @Query('type') type: string = 'restaurant',
  ) {
    return this.integrationsService.getNearbyPlaces(latitude, longitude, radius, type);
  }
}
