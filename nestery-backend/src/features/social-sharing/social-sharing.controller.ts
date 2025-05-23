import { Controller, Get, Post, Body, Param, UseGuards, Req } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { SocialSharingService } from './social-sharing.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';

/**
 * Controller handling social sharing endpoints
 */
@ApiTags('social-sharing')
@Controller('social-sharing')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SocialSharingController {
  constructor(private readonly socialSharingService: SocialSharingService) {}

  /**
   * Generate shareable content for a property
   */
  @Get('content/:propertyId/:platform')
  @ApiOperation({ summary: 'Generate shareable content for a property' })
  @ApiResponse({ status: 200, description: 'Content generated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  async generateShareableContent(
    @Param('propertyId') propertyId: string,
    @Param('platform') platform: string,
  ) {
    return this.socialSharingService.generateShareableContent(propertyId, platform);
  }

  /**
   * Share property to social media
   */
  @Post('share')
  @ApiOperation({ summary: 'Share property to social media' })
  @ApiResponse({ status: 200, description: 'Shared successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  async shareToSocialMedia(
    @Req() req: any,
    @Body() shareDto: { propertyId: string; platform: string },
  ) {
    return this.socialSharingService.shareToSocialMedia(
      shareDto.propertyId,
      shareDto.platform,
      req.user.id,
    );
  }

  /**
   * Generate referral link for current user
   */
  @Get('referral-link')
  @ApiOperation({ summary: 'Generate referral link for current user' })
  @ApiResponse({ status: 200, description: 'Referral link generated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async generateReferralLink(@Req() req: any) {
    return this.socialSharingService.generateReferralLink(req.user.id);
  }

  /**
   * Track referral conversion
   */
  @Post('track-referral')
  @ApiOperation({ summary: 'Track referral conversion' })
  @ApiResponse({ status: 200, description: 'Referral tracked successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  async trackReferralConversion(
    @Body() referralDto: { referralCode: string; newUserId: string },
  ) {
    return this.socialSharingService.trackReferralConversion(
      referralDto.referralCode,
      referralDto.newUserId,
    );
  }
}
