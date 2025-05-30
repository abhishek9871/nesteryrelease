import {
  Controller,
  Get,
  Post,
  UseGuards,
  Req,
  Query,
  ParseIntPipe,
  DefaultValuePipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { LoyaltyService } from './loyalty.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { AuthenticatedRequest } from '../../auth/interfaces/authenticated-request.interface';

@ApiTags('loyalty')
@Controller('loyalty')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class LoyaltyController {
  constructor(private readonly loyaltyService: LoyaltyService) {}

  @Get('status')
  @ApiOperation({ summary: "Get current user's loyalty status" })
  @ApiResponse({ status: 200, description: 'Returns loyalty status, points, and benefits' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getLoyaltyStatus(@Req() req: AuthenticatedRequest) {
    return this.loyaltyService.getLoyaltyStatus(req.user.id);
  }

  @Post('check-in')
  @ApiOperation({ summary: 'Perform daily check-in to earn miles' })
  @ApiResponse({ status: 201, description: 'Daily check-in successful' })
  @ApiResponse({ status: 400, description: 'Already checked in today or other error' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async dailyCheckIn(@Req() req: AuthenticatedRequest) {
    return this.loyaltyService.performDailyCheckIn(req.user.id);
  }

  @Get('transactions')
  @ApiOperation({ summary: "Get current user's miles transaction history" })
  @ApiResponse({ status: 200, description: 'Returns paginated transaction history' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  async getTransactionsHistory(
    @Req() req: AuthenticatedRequest,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(10), ParseIntPipe) limit: number,
  ) {
    return this.loyaltyService.getTransactionsHistory(req.user.id, page, limit);
  }

  // Example Redemption Endpoint (Stub)
  // @Post('redeem/premium-discount')
  // @ApiOperation({ summary: 'Redeem miles for a Nestery Premium discount' })
  // @ApiResponse({ status: 200, description: 'Miles redeemed successfully for discount' })
  // @ApiResponse({ status: 400, description: 'Insufficient miles or other error' })
  // async redeemForPremiumDiscount(
  //   @Req() req: AuthenticatedRequest,
  //   @Body('milesToRedeem', ParseIntPipe) milesToRedeem: number,
  // ) {
  //   // This would call loyaltyService.redeemMiles with appropriate parameters
  //   // For now, this is a conceptual endpoint.
  //   return {
  //     message: `Redemption for ${milesToRedeem} miles for premium discount (stub). User: ${req.user.id}`,
  //   };
  // }
}
