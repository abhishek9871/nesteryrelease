import { ApiProperty } from '@nestjs/swagger';

export class RevenueMetricsDto {
  @ApiProperty({ description: 'Total revenue for the period' })
  totalRevenue: number;

  @ApiProperty({ description: 'Total commissions paid' })
  totalCommissions: number;

  @ApiProperty({ description: 'Number of conversions' })
  totalConversions: number;

  @ApiProperty({ description: 'Average commission per conversion' })
  averageCommission: number;

  @ApiProperty({ description: 'Revenue growth percentage' })
  growthPercentage: number;
}

export class PartnerPerformanceDto {
  @ApiProperty({ description: 'Partner ID' })
  partnerId: string;

  @ApiProperty({ description: 'Partner name' })
  partnerName: string;

  @ApiProperty({ description: 'Total earnings' })
  totalEarnings: number;

  @ApiProperty({ description: 'Number of conversions' })
  conversions: number;

  @ApiProperty({ description: 'Conversion rate percentage' })
  conversionRate: number;

  @ApiProperty({ description: 'Partner category' })
  category: string;
}

export class RevenueTrendDto {
  @ApiProperty({ description: 'Date of the data point' })
  date: string;

  @ApiProperty({ description: 'Revenue for the date' })
  revenue: number;

  @ApiProperty({ description: 'Commissions for the date' })
  commissions: number;

  @ApiProperty({ description: 'Number of conversions' })
  conversions: number;
}

export class CommissionBatchDto {
  @ApiProperty({ description: 'Batch ID' })
  id: string;

  @ApiProperty({ description: 'Batch processing date' })
  batchDate: string;

  @ApiProperty({ description: 'Total commissions processed' })
  totalCommissions: number;

  @ApiProperty({ description: 'Number of earnings processed' })
  processedEarnings: number;

  @ApiProperty({ description: 'Batch processing status' })
  status: string;

  @ApiProperty({ description: 'Error message if failed', required: false })
  errorMessage?: string | null;

  @ApiProperty({ description: 'Batch creation timestamp' })
  createdAt: Date;
}
