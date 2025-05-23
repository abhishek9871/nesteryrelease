import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards, Req } from '@nestjs/common';
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
  @ApiQuery({ name: 'sourceType', required: true, type: String, description: 'Source type (booking_com, oyo, etc.)' })
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
  async createBooking(
    @Body() bookingData: any,
    @Query('sourceType') sourceType: string,
  ) {
    return this.integrationsService.createBooking(bookingData, sourceType);
  }

  /**
   * Geocode an address to get coordinates
   */
  @Get('geocode')
  @ApiOperation({ summary: 'Geocode an address to get coordinates' })
  @ApiQuery({ name: 'address', required: true, type: String, description: 'Address to geocode' })
  @ApiResponse({ status: 200, description: 'Address geocoded successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  async geocodeAddress(@Query('address') address: string) {
    return this.integrationsService.geocodeAddress(address);
  }

  /**
   * Get nearby places of interest
   */
  @Get('nearby-places')
  @ApiOperation({ summary: 'Get nearby places of interest' })
  @ApiQuery({ name: 'latitude', required: true, type: Number, description: 'Latitude' })
  @ApiQuery({ name: 'longitude', required: true, type: Number, description: 'Longitude' })
  @ApiQuery({ name: 'radius', required: false, type: Number, description: 'Radius in meters' })
  @ApiQuery({ name: 'type', required: false, type: String, description: 'Place type' })
  @ApiResponse({ status: 200, description: 'Nearby places retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  async getNearbyPlaces(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @Query('radius') radius?: number,
    @Query('type') type?: string,
  ) {
    return this.integrationsService.getNearbyPlaces(latitude, longitude, radius, type);
  }
}
