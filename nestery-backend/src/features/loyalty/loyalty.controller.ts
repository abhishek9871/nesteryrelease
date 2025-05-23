import { Controller, Get, Post, Body, Param, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { LoyaltyService } from './loyalty.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

/**
 * Controller handling loyalty program endpoints
 */
@ApiTags('loyalty')
@Controller('loyalty')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class LoyaltyController {
  constructor(private readonly loyaltyService: LoyaltyService) {}

  /**
   * Get loyalty program details for the current user
   */
  @Get()
  @ApiOperation({ summary: 'Get loyalty program details for the current user' })
  @ApiResponse({ status: 200, description: 'Loyalty details retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getLoyaltyDetails(@Req() req: any) {
    return this.loyaltyService.getLoyaltyDetails(req.user.id);
  }

  /**
   * Get available rewards for the current user
   */
  @Get('rewards')
  @ApiOperation({ summary: 'Get available rewards for the current user' })
  @ApiResponse({ status: 200, description: 'Rewards retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getAvailableRewards(@Req() req: any) {
    return this.loyaltyService.getAvailableRewards(req.user.id);
  }

  /**
   * Redeem loyalty points for a reward
   */
  @Post('redeem')
  @ApiOperation({ summary: 'Redeem loyalty points for a reward' })
  @ApiResponse({ status: 200, description: 'Points redeemed successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async redeemLoyaltyPoints(
    @Req() req: any,
    @Body() redeemDto: { points: number; rewardId: string },
  ) {
    return this.loyaltyService.redeemLoyaltyPoints(
      req.user.id,
      redeemDto.points,
      redeemDto.rewardId,
    );
  }

  /**
   * Add loyalty points (admin only endpoint, not exposed to users)
   */
  @Post('add-points/:userId')
  @ApiOperation({ summary: 'Add loyalty points to a user (admin only)' })
  @ApiResponse({ status: 200, description: 'Points added successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden' })
  async addLoyaltyPoints(
    @Param('userId') userId: string,
    @Body() addPointsDto: { points: number; reason: string },
  ) {
    return this.loyaltyService.addLoyaltyPoints(
      userId,
      addPointsDto.points,
      addPointsDto.reason,
    );
  }
}
