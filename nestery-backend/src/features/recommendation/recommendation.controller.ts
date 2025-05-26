import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { RecommendationService } from './recommendation.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { Public } from '../../auth/decorators/public.decorator';

@ApiTags('recommendations')
@Controller('recommendations')
export class RecommendationController {
  constructor(private readonly recommendationService: RecommendationService) {}

  @Get('user/:userId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get personalized recommendations for a user' })
  @ApiResponse({ status: 200, description: 'Returns recommended properties for the user' })
  async getRecommendationsForUser(@Param('userId') userId: string, @Query('limit') limit?: number) {
    return this.recommendationService.getRecommendationsForUser(userId, limit);
  }

  @Get('similar/:propertyId')
  @Public()
  @ApiOperation({ summary: 'Get similar properties to a specific property' })
  @ApiResponse({ status: 200, description: 'Returns similar properties' })
  async getSimilarProperties(
    @Param('propertyId') propertyId: string,
    @Query('limit') limit?: number,
  ) {
    return this.recommendationService.getSimilarProperties(propertyId, limit);
  }

  @Get('trending')
  @Public()
  @ApiOperation({ summary: 'Get trending properties' })
  @ApiResponse({ status: 200, description: 'Returns trending properties' })
  async getTrendingProperties(@Query('limit') limit?: number) {
    return this.recommendationService.getTrendingProperties(limit);
  }

  @Get('destination')
  @Public()
  @ApiOperation({ summary: 'Get popular properties for a destination' })
  @ApiResponse({ status: 200, description: 'Returns popular properties for the destination' })
  async getPopularPropertiesForDestination(
    @Query('destination') destination: string,
    @Query('limit') limit?: number,
  ) {
    return this.recommendationService.getPopularPropertiesForDestination(destination, limit);
  }
}
