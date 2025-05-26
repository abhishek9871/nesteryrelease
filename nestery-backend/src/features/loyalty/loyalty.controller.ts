import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { LoyaltyService } from './loyalty.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

@ApiTags('loyalty')
@Controller('loyalty')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class LoyaltyController {
  constructor(private readonly loyaltyService: LoyaltyService) {}

  @Get('status/:userId')
  @ApiOperation({ summary: 'Get loyalty status and points for a user' })
  @ApiResponse({ status: 200, description: 'Returns loyalty status, points, and benefits' })
  async getLoyaltyStatus(@Param('userId') userId: string) {
    return this.loyaltyService.getLoyaltyStatus(userId);
  }

  @Post('award-points')
  @ApiOperation({ summary: 'Award points for a booking' })
  @ApiResponse({ status: 200, description: 'Returns points awarded and new total' })
  async awardPointsForBooking(@Body('bookingId') bookingId: string) {
    return this.loyaltyService.awardPointsForBooking(bookingId);
  }

  @Post('redeem')
  @ApiOperation({ summary: 'Redeem points for a reward' })
  @ApiResponse({ status: 200, description: 'Returns redemption result and remaining points' })
  async redeemPoints(@Body() params: { userId: string; rewardId: string; pointsRequired: number }) {
    return this.loyaltyService.redeemPoints(params.userId, params.rewardId, params.pointsRequired);
  }

  @Get('rewards/:userId')
  @ApiOperation({ summary: 'Get available rewards for a user' })
  @ApiResponse({ status: 200, description: 'Returns available rewards and redemption status' })
  async getAvailableRewards(@Param('userId') userId: string) {
    return this.loyaltyService.getAvailableRewards(userId);
  }
}
