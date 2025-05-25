import { Controller, Get, Post, Body, Param, Query, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { SocialSharingService } from './social-sharing.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { Public } from '../../auth/decorators/public.decorator';

@ApiTags('social-sharing')
@Controller('social-sharing')
export class SocialSharingController {
  constructor(private readonly socialSharingService: SocialSharingService) {}

  @Get('content/:propertyId')
  @Public()
  @ApiOperation({ summary: 'Generate shareable content for a property' })
  @ApiResponse({ status: 200, description: 'Returns shareable content for the specified platform' })
  async generateShareableContent(
    @Param('propertyId') propertyId: string,
    @Query('platform') platform: string,
  ) {
    return this.socialSharingService.generateShareableContent(propertyId, platform);
  }

  @Post('track')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Track social share event' })
  @ApiResponse({ status: 200, description: 'Returns tracking confirmation' })
  async trackSocialShare(
    @Body() params: {
      userId: string;
      propertyId: string;
      platform: string;
      shareUrl: string;
    },
  ) {
    return this.socialSharingService.trackSocialShare(params);
  }

  @Get('referral/:userId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get referral link for a user' })
  @ApiResponse({ status: 200, description: 'Returns referral link and rewards information' })
  async getReferralLink(
    @Param('userId') userId: string,
  ) {
    return this.socialSharingService.getReferralLink(userId);
  }

  @Post('referral/process')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Process referral signup' })
  @ApiResponse({ status: 200, description: 'Returns referral processing result' })
  async processReferralSignup(
    @Body() params: {
      referralCode: string;
      newUserId: string;
    },
  ) {
    return this.socialSharingService.processReferralSignup(params.referralCode, params.newUserId);
  }

  @Get('stats/:propertyId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get sharing statistics for a property' })
  @ApiResponse({ status: 200, description: 'Returns sharing statistics' })
  async getPropertySharingStats(
    @Param('propertyId') propertyId: string,
  ) {
    return this.socialSharingService.getPropertySharingStats(propertyId);
  }
}
