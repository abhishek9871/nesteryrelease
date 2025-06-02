import { ApiProperty } from '@nestjs/swagger';
import { PartnerCategoryEnum } from '../entities/partner.entity';

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
