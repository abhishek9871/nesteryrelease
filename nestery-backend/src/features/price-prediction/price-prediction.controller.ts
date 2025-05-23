import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { PricePredictionService } from './price-prediction.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

/**
 * Controller handling price prediction endpoints
 */
@ApiTags('price-prediction')
@Controller('price-prediction')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PricePredictionController {
  constructor(private readonly pricePredictionService: PricePredictionService) {}

  /**
   * Predict price trends for a specific property and date range
   */
  @Get('trends/:propertyId')
  @ApiOperation({ summary: 'Predict price trends for a specific property and date range' })
  @ApiQuery({ name: 'checkInDate', required: true, type: String, description: 'Check-in date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'checkOutDate', required: true, type: String, description: 'Check-out date (YYYY-MM-DD)' })
  @ApiResponse({ status: 200, description: 'Price trends predicted successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  async predictPriceTrend(
    @Param('propertyId') propertyId: string,
    @Query('checkInDate') checkInDate: string,
    @Query('checkOutDate') checkOutDate: string,
  ) {
    return this.pricePredictionService.predictPriceTrend(
      propertyId,
      new Date(checkInDate),
      new Date(checkOutDate),
    );
  }

  /**
   * Recommend optimal booking time for best price
   */
  @Get('recommend-booking-time/:propertyId')
  @ApiOperation({ summary: 'Recommend optimal booking time for best price' })
  @ApiQuery({ name: 'checkInDate', required: true, type: String, description: 'Check-in date (YYYY-MM-DD)' })
  @ApiQuery({ name: 'checkOutDate', required: true, type: String, description: 'Check-out date (YYYY-MM-DD)' })
  @ApiResponse({ status: 200, description: 'Booking time recommendation generated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  async recommendBookingTime(
    @Param('propertyId') propertyId: string,
    @Query('checkInDate') checkInDate: string,
    @Query('checkOutDate') checkOutDate: string,
  ) {
    return this.pricePredictionService.recommendBookingTime(
      propertyId,
      new Date(checkInDate),
      new Date(checkOutDate),
    );
  }
}
