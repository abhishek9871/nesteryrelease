import { Controller, Get, Post, Query, UseGuards, ParseIntPipe } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';
import { Roles } from '../../auth/decorators/roles.decorator';
import { GetPartnerId } from '../../auth/decorators/get-partner-id.decorator';
import { RevenueAnalyticsService } from '../services/revenue-analytics.service';
import { EnhancedCommissionService } from '../services/enhanced-commission.service';
import {
  RevenueMetricsDto,
  PartnerPerformanceDto,
  RevenueTrendDto,
  CommissionBatchDto,
} from '../dto/revenue-analytics.dto';

@ApiTags('Revenue Analytics')
@Controller('v1/revenue')
@UseGuards(JwtAuthGuard, RolesGuard)
@ApiBearerAuth()
export class RevenueAnalyticsController {
  constructor(
    private readonly revenueAnalyticsService: RevenueAnalyticsService,
    private readonly enhancedCommissionService: EnhancedCommissionService,
  ) {}

  @Get('analytics/summary')
  @Roles('admin')
  @ApiOperation({ summary: 'Get overall revenue analytics summary' })
  @ApiResponse({
    status: 200,
    description: 'Revenue metrics retrieved successfully',
    type: RevenueMetricsDto,
  })
  async getRevenueSummary(
    @Query('days', new ParseIntPipe({ optional: true })) days: number = 30,
  ): Promise<RevenueMetricsDto> {
    return await this.revenueAnalyticsService.getRevenueMetrics(undefined, days);
  }

  @Get('analytics/partner')
  @Roles('partner', 'admin')
  @ApiOperation({ summary: 'Get partner-specific revenue analytics' })
  @ApiResponse({
    status: 200,
    description: 'Partner revenue metrics retrieved successfully',
    type: RevenueMetricsDto,
  })
  async getPartnerRevenue(
    @GetPartnerId() partnerId: string,
    @Query('days', new ParseIntPipe({ optional: true })) days: number = 30,
  ): Promise<RevenueMetricsDto> {
    return await this.revenueAnalyticsService.getRevenueMetrics(partnerId, days);
  }

  @Get('partner/performance')
  @Roles('admin')
  @ApiOperation({ summary: 'Get top partner performance metrics' })
  @ApiResponse({
    status: 200,
    description: 'Partner performance retrieved successfully',
    type: [PartnerPerformanceDto],
  })
  async getPartnerPerformance(
    @Query('limit', new ParseIntPipe({ optional: true })) limit: number = 10,
  ): Promise<PartnerPerformanceDto[]> {
    return await this.revenueAnalyticsService.getPartnerPerformance(limit);
  }

  @Get('trends')
  @Roles('admin')
  @ApiOperation({ summary: 'Get revenue trends over time' })
  @ApiResponse({
    status: 200,
    description: 'Revenue trends retrieved successfully',
    type: [RevenueTrendDto],
  })
  async getRevenueTrends(
    @Query('days', new ParseIntPipe({ optional: true })) days: number = 30,
  ): Promise<RevenueTrendDto[]> {
    return await this.revenueAnalyticsService.getRevenueTrends(undefined, days);
  }

  @Get('trends/partner')
  @Roles('partner', 'admin')
  @ApiOperation({ summary: 'Get partner-specific revenue trends' })
  @ApiResponse({
    status: 200,
    description: 'Partner revenue trends retrieved successfully',
    type: [RevenueTrendDto],
  })
  async getPartnerTrends(
    @GetPartnerId() partnerId: string,
    @Query('days', new ParseIntPipe({ optional: true })) days: number = 30,
  ): Promise<RevenueTrendDto[]> {
    return await this.revenueAnalyticsService.getRevenueTrends(partnerId, days);
  }

  @Get('commission/batches')
  @Roles('admin')
  @ApiOperation({ summary: 'Get commission processing batches' })
  @ApiResponse({
    status: 200,
    description: 'Commission batches retrieved successfully',
    type: [CommissionBatchDto],
  })
  async getCommissionBatches(
    @Query('limit', new ParseIntPipe({ optional: true })) limit: number = 20,
  ): Promise<CommissionBatchDto[]> {
    return await this.revenueAnalyticsService.getCommissionBatches(limit);
  }

  @Post('commission/process')
  @Roles('admin')
  @ApiOperation({ summary: 'Manually trigger commission processing' })
  @ApiResponse({ status: 200, description: 'Commission processing triggered successfully' })
  async processCommissions(): Promise<{
    batchId: string;
    processedCount: number;
    totalCommissions: number;
  }> {
    return await this.enhancedCommissionService.manualProcessCommissions();
  }

  @Post('analytics/cache/clear')
  @Roles('admin')
  @ApiOperation({ summary: 'Clear analytics cache' })
  @ApiResponse({ status: 200, description: 'Analytics cache cleared successfully' })
  async clearAnalyticsCache(): Promise<{ message: string }> {
    await this.revenueAnalyticsService.clearAnalyticsCache();
    return { message: 'Analytics cache cleared successfully' };
  }
}
