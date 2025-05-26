import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { SocialSharingService } from './social-sharing.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

// Define interfaces for return types to avoid visibility issues
interface SharingLinks {
  url: string;
  text: string;
  subject: string;
  links: Record<string, string>;
}

interface ReferralInfo {
  referralCode: string;
  referralLink: string;
  qrCode: string;
  referralStats: {
    totalReferrals: number;
    successfulReferrals: number;
    pendingReferrals: number;
  };
  rewards: {
    referrerReward: string;
    refereeReward: string;
  };
  sharingLinks: SharingLinks;
}

interface BookingShareResult {
  success: boolean;
  platform: {
    name: string;
    icon: string;
    color: string;
    shareUrl: string;
  };
  sharingLink: string;
}

@ApiTags('social-sharing')
@Controller('social-sharing')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SocialSharingController {
  constructor(private readonly socialSharingService: SocialSharingService) {}

  @Get('property/:propertyId/share')
  @ApiOperation({ summary: 'Generate sharing links for a property' })
  @ApiResponse({ status: 200, description: 'Sharing links generated successfully' })
  async generatePropertySharingLinks(
    @Param('propertyId') propertyId: string,
    @Query('propertyName') propertyName: string,
  ): Promise<SharingLinks> {
    return this.socialSharingService.generatePropertySharingLinks(propertyId, propertyName);
  }

  @Post('track')
  @ApiOperation({ summary: 'Track a social share event' })
  @ApiResponse({ status: 201, description: 'Share event tracked successfully' })
  async trackShare(@Body() params: any): Promise<{ success: boolean; message: string; data: any }> {
    // This is a placeholder - we'll implement proper tracking in a future update
    return {
      success: true,
      message: 'Share event tracked successfully',
      data: params,
    };
  }

  @Get('user/:userId/referral')
  @ApiOperation({ summary: 'Get referral information for a user' })
  @ApiResponse({ status: 200, description: 'Referral information retrieved successfully' })
  async getReferralInfo(@Param('userId') userId: string): Promise<ReferralInfo> {
    return this.socialSharingService.getReferralInfo(userId);
  }

  @Post('user/:userId/referral/generate')
  @ApiOperation({ summary: 'Generate a referral code for a user' })
  @ApiResponse({ status: 201, description: 'Referral code generated successfully' })
  async generateReferralCode(@Param('userId') userId: string): Promise<string> {
    return this.socialSharingService.generateReferralCode(userId);
  }

  @Post('referral/:referralCode/process')
  @ApiOperation({ summary: 'Process a referral signup' })
  @ApiResponse({ status: 201, description: 'Referral processed successfully' })
  async processReferralSignup(
    @Param('referralCode') referralCode: string,
    @Body('userId') userId: string,
  ): Promise<boolean> {
    return this.socialSharingService.processReferralSignup(referralCode, userId);
  }

  @Get('property/:propertyId/stats')
  @ApiOperation({ summary: 'Get sharing statistics for a property' })
  @ApiResponse({ status: 200, description: 'Sharing statistics retrieved successfully' })
  async getPropertySharingStats(@Param('propertyId') propertyId: string): Promise<{
    totalShares: number;
    sharesByPlatform: Record<string, number>;
    clickThroughRate: number;
  }> {
    return this.socialSharingService.getPropertySharingStats(propertyId);
  }

  @Post('booking/:bookingId/share')
  @ApiOperation({ summary: 'Share a booking confirmation' })
  @ApiResponse({ status: 201, description: 'Booking shared successfully' })
  async shareBookingConfirmation(
    @Param('bookingId') bookingId: string,
    @Body('platform') platform: string,
  ): Promise<BookingShareResult> {
    return this.socialSharingService.shareBookingConfirmation(bookingId, platform);
  }
}
