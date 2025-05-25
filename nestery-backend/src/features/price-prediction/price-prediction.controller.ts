import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { PricePredictionService } from './price-prediction.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { Public } from '../../auth/decorators/public.decorator';

@ApiTags('price-prediction')
@Controller('price-prediction')
export class PricePredictionController {
  constructor(private readonly pricePredictionService: PricePredictionService) {}

  @Post('predict')
  @Public()
  @ApiOperation({ summary: 'Predict price for a property' })
  @ApiResponse({ status: 200, description: 'Returns predicted price and factors' })
  async predictPrice(
    @Body() params: {
      propertyId?: string;
      city: string;
      country: string;
      checkInDate: Date;
      checkOutDate: Date;
      guestCount: number;
      amenities?: string[];
      propertyType?: string;
      rating?: number;
    },
  ) {
    return this.pricePredictionService.predictPrice(params);
  }

  @Get('trends')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get price trends for a location' })
  @ApiResponse({ status: 200, description: 'Returns price trends data' })
  async getPriceTrends(
    @Query('city') city: string,
    @Query('country') country: string,
    @Query('propertyType') propertyType?: string,
  ) {
    // This would call a method to get price trends, which would be implemented in the service
    // For now, we'll return a mock response
    return {
      city,
      country,
      propertyType,
      trends: [
        { month: 'Jan', avgPrice: 120 },
        { month: 'Feb', avgPrice: 125 },
        { month: 'Mar', avgPrice: 130 },
        { month: 'Apr', avgPrice: 140 },
        { month: 'May', avgPrice: 150 },
        { month: 'Jun', avgPrice: 170 },
        { month: 'Jul', avgPrice: 190 },
        { month: 'Aug', avgPrice: 195 },
        { month: 'Sep', avgPrice: 180 },
        { month: 'Oct', avgPrice: 160 },
        { month: 'Nov', avgPrice: 140 },
        { month: 'Dec', avgPrice: 150 },
      ],
      peakSeason: ['Jun', 'Jul', 'Aug'],
      lowSeason: ['Jan', 'Feb', 'Nov'],
    };
  }

  @Get('comparison')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Compare prices across different locations' })
  @ApiResponse({ status: 200, description: 'Returns price comparison data' })
  async comparePrices(
    @Query('cities') cities: string,
    @Query('country') country: string,
    @Query('propertyType') propertyType?: string,
  ) {
    // This would call a method to compare prices, which would be implemented in the service
    // For now, we'll return a mock response
    const citiesArray = cities.split(',');
    
    return {
      country,
      propertyType,
      comparison: citiesArray.map(city => ({
        city: city.trim(),
        avgPrice: Math.floor(Math.random() * 100) + 100,
        minPrice: Math.floor(Math.random() * 50) + 50,
        maxPrice: Math.floor(Math.random() * 150) + 150,
      })),
    };
  }
}
