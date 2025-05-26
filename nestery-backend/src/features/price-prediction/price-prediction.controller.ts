import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { PricePredictionService } from './price-prediction.service';
import { ApiTags, ApiOperation, ApiResponse, ApiQuery, ApiBody } from '@nestjs/swagger';

interface PredictPriceDto {
  propertyId?: string;
  city: string;
  country: string;
  checkInDate: Date;
  checkOutDate: Date;
  guestCount: number;
  amenities?: string[];
  propertyType?: string;
  rating?: number;
  bedrooms: number;
  bathrooms: number;
  maxGuests: number;
}

@ApiTags('price-prediction')
@Controller('price-prediction')
export class PricePredictionController {
  constructor(private readonly pricePredictionService: PricePredictionService) {}

  @Post('predict')
  @ApiOperation({ summary: 'Predict price for a property' })
  @ApiBody({ description: 'Property details for price prediction' })
  @ApiResponse({ status: 200, description: 'Price prediction successful' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  async predictPrice(@Body() params: PredictPriceDto) {
    // Map the DTO to the service interface
    const predictionParams = {
      propertyType: params.propertyType || 'apartment',
      bedrooms: params.bedrooms,
      bathrooms: params.bathrooms,
      maxGuests: params.maxGuests,
      city: params.city,
      country: params.country,
      amenities: params.amenities || [],
      latitude: 0, // Default values if not provided
      longitude: 0,
    };

    return this.pricePredictionService.predictPrice(predictionParams);
  }

  @Get('factors')
  @ApiOperation({ summary: 'Get price factors for a location' })
  @ApiQuery({ name: 'city', required: true })
  @ApiQuery({ name: 'country', required: true })
  @ApiResponse({ status: 200, description: 'Price factors retrieved successfully' })
  async getPriceFactors(@Query('city') city: string, @Query('country') country: string) {
    // Mock implementation for price factors
    return {
      location: {
        factor: city === 'New York' ? 1.5 : 1.0,
        description: 'Location premium',
      },
      seasonality: {
        factor: 1.2,
        description: 'Current season demand',
      },
      demand: {
        factor: 1.1,
        description: 'Current market demand',
      },
    };
  }
}
