import { Controller, Get, Post, Body, Param, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { RecommendationService } from './recommendation.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

/**
 * Controller handling recommendation endpoints
 */
@ApiTags('recommendations')
@Controller('recommendations')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class RecommendationController {
  constructor(private readonly recommendationService: RecommendationService) {}

  /**
   * Get personalized property recommendations for the current user
   */
  @Get('personalized')
  @ApiOperation({ summary: 'Get personalized property recommendations for the current user' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Maximum number of recommendations' })
  @ApiResponse({ status: 200, description: 'Recommendations retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getPersonalizedRecommendations(
    @Req() req: any,
    @Query('limit') limit?: number,
  ) {
    return this.recommendationService.getPersonalizedRecommendations(req.user.id, limit);
  }

  /**
   * Get similar properties to a given property
   */
  @Get('similar/:propertyId')
  @ApiOperation({ summary: 'Get similar properties to a given property' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Maximum number of similar properties' })
  @ApiResponse({ status: 200, description: 'Similar properties retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  async getSimilarProperties(
    @Param('propertyId') propertyId: string,
    @Query('limit') limit?: number,
  ) {
    return this.recommendationService.getSimilarProperties(propertyId, limit);
  }

  /**
   * Get trending destinations based on user location and preferences
   */
  @Get('trending-destinations')
  @ApiOperation({ summary: 'Get trending destinations based on user location and preferences' })
  @ApiQuery({ name: 'limit', required: false, type: Number, description: 'Maximum number of destinations' })
  @ApiResponse({ status: 200, description: 'Trending destinations retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getTrendingDestinations(
    @Req() req: any,
    @Query('limit') limit?: number,
  ) {
    return this.recommendationService.getTrendingDestinations(req.user.id, limit);
  }
}
