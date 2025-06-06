import { ApiProperty } from '@nestjs/swagger';
import { EarningStatusEnum } from '../enums/earning-status.enum';
import { PartnerCategoryEnum } from '../enums/partner-category.enum';

class PartnerSummaryDto {
  @ApiProperty({ description: 'Partner ID' })
  id: string;

  @ApiProperty({ description: 'Partner name' })
  name: string;

  @ApiProperty({ description: 'Partner category', enum: PartnerCategoryEnum })
  category: PartnerCategoryEnum;

  @ApiProperty({ description: 'Whether the partner is active' })
  isActive: boolean;

  @ApiProperty({ description: 'Partner creation date' })
  createdAt: Date;
}

class PartnerAnalyticsDto {
  @ApiProperty({ description: 'Total number of offers created' })
  totalOffers: number;

  @ApiProperty({ description: 'Number of currently active offers' })
  activeOffers: number;

  @ApiProperty({ description: 'Total number of earnings records' })
  totalEarnings: number;

  @ApiProperty({ description: 'Total confirmed earnings amount' })
  totalConfirmedEarnings: number;

  @ApiProperty({ description: 'Total pending earnings amount' })
  totalPendingEarnings: number;

  @ApiProperty({ description: 'Total paid earnings amount' })
  totalPaidEarnings: number;

  @ApiProperty({ description: 'Number of earnings in the last 30 days' })
  recentEarningsCount: number;

  @ApiProperty({ description: 'Total earnings amount in the last 30 days' })
  recentEarningsTotal: number;
}

class TopOfferDto {
  @ApiProperty({ description: 'Offer ID' })
  offerId: string;

  @ApiProperty({ description: 'Offer title' })
  offerTitle: string;

  @ApiProperty({ description: 'Number of conversions for this offer' })
  conversionCount: number;

  @ApiProperty({ description: 'Total earnings from this offer' })
  totalEarnings: number;
}

export class PartnerDashboardDto {
  @ApiProperty({ description: 'Partner summary information', type: PartnerSummaryDto })
  partner: PartnerSummaryDto;

  @ApiProperty({ description: 'Partner analytics data', type: PartnerAnalyticsDto })
  analytics: PartnerAnalyticsDto;

  @ApiProperty({ description: 'Top performing offers', type: [TopOfferDto] })
  topOffers: TopOfferDto[];
}

// --- SUB-DTOs ---
export class ChartDataPointDto {
  @ApiProperty() date: Date;
  @ApiProperty() value: number;
}

export class RevenueCardDataDto {
  @ApiProperty() netEarnings: number;
  @ApiProperty() grossRevenueForCalc: number;
  @ApiProperty() partnerCommissionRate: number;
  @ApiProperty() previousPeriodNetEarnings: number;
}

export class MonthlySalesCardDataDto {
  @ApiProperty() monthlyGrossSales: number;
  @ApiProperty() nesteryCommissionRateForDisplay: number;
  @ApiProperty() previousPeriodGrossSales: number;
}

export class TrafficQualityCardDataDto {
  @ApiProperty() conversionRateValue: number;
  @ApiProperty() previousPeriodConversionRate: number;
  @ApiProperty() qualityLabel: string;
  @ApiProperty() totalClicks: number;
  @ApiProperty() totalConversions: number;
}

export class ConversionRateCardDataDto {
  @ApiProperty() conversionRateValue: number;
  @ApiProperty() previousPeriodConversionRate: number;
}

export class DashboardChartDataDto {
  @ApiProperty({ type: [ChartDataPointDto] })
  netEarningsData: ChartDataPointDto[];
  @ApiProperty({ type: [ChartDataPointDto] })
  conversionRateData: ChartDataPointDto[];
}

export class EarningsSummaryDto {
  @ApiProperty() totalEarnings: number;
  @ApiProperty() pendingPayout: number;
  @ApiProperty() thisMonthEarnings: number;
  @ApiProperty() lastPayoutAmount: number;
  @ApiProperty({ required: false }) lastPayoutDate?: Date;
  @ApiProperty({ default: 'USD' }) currency: string;
}

export class OfferListItemDto {
  @ApiProperty() id: string;
  @ApiProperty() title: string;
  @ApiProperty({ enum: ['ACTIVE', 'INACTIVE', 'PENDING', 'EXPIRED'] }) status: string;
  @ApiProperty() partnerCategory: string;
  @ApiProperty() validFrom: Date;
  @ApiProperty() validTo: Date;
  @ApiProperty({ required: false }) thumbnailUrl?: string;
}

export class EarningTransactionDto {
  @ApiProperty() id: string;
  @ApiProperty() transactionDate: Date;
  @ApiProperty() offerTitle: string;
  @ApiProperty() offerId: string;
  @ApiProperty() amountEarned: number;
  @ApiProperty() currency: string;
  @ApiProperty({ enum: EarningStatusEnum }) status: EarningStatusEnum;
}

// --- Combined DTOs ---
export class DashboardMetricsDto {
  @ApiProperty() revenue: RevenueCardDataDto;
  @ApiProperty() monthlySales: MonthlySalesCardDataDto;
  @ApiProperty() trafficQuality: TrafficQualityCardDataDto;
  @ApiProperty() conversionRate: ConversionRateCardDataDto;
  @ApiProperty() chartData: DashboardChartDataDto;
}

export class EarningsReportDataDto {
  @ApiProperty() summary: EarningsSummaryDto;
  @ApiProperty({ type: [EarningTransactionDto] }) transactions: EarningTransactionDto[];
}

// --- MAIN RESPONSE DTO ---
export class PartnerDashboardDataDto {
  @ApiProperty() dashboardMetrics: DashboardMetricsDto;
  @ApiProperty() earningsReport: EarningsReportDataDto;
  @ApiProperty({ type: [OfferListItemDto] }) partnerOffers: OfferListItemDto[];
}
