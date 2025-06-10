import { Injectable, Inject } from '@nestjs/common';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Cache } from 'cache-manager';
import { AffiliateEarningEntity, EarningStatusEnum } from '../entities/affiliate-earning.entity';
import { PartnerEntity } from '../entities/partner.entity';
import { CommissionBatchEntity } from '../entities/commission-batch.entity';
import {
  RevenueMetricsDto,
  PartnerPerformanceDto,
  RevenueTrendDto,
  CommissionBatchDto,
} from '../dto/revenue-analytics.dto';

@Injectable()
export class RevenueAnalyticsService {
  constructor(
    @InjectRepository(AffiliateEarningEntity)
    private affiliateEarningRepository: Repository<AffiliateEarningEntity>,
    @InjectRepository(PartnerEntity)
    private partnerRepository: Repository<PartnerEntity>,
    @InjectRepository(CommissionBatchEntity)
    private commissionBatchRepository: Repository<CommissionBatchEntity>,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
  ) {}

  async getRevenueMetrics(partnerId?: string, days: number = 30): Promise<RevenueMetricsDto> {
    const cacheKey = `revenue_metrics_${partnerId || 'all'}_${days}`;
    const cached = await this.cacheManager.get<RevenueMetricsDto>(cacheKey);

    if (cached) {
      return cached;
    }

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const queryBuilder = this.affiliateEarningRepository
      .createQueryBuilder('earning')
      .where('earning.createdAt >= :startDate', { startDate })
      .andWhere('earning.status = :status', { status: EarningStatusEnum.CONFIRMED });

    if (partnerId) {
      queryBuilder.andWhere('earning.partnerId = :partnerId', { partnerId });
    }

    const earnings = await queryBuilder.getMany();

    const totalRevenue = earnings.reduce((sum, earning) => sum + Number(earning.amountEarned), 0);
    const totalCommissions = earnings.reduce(
      (sum, earning) => sum + Number(earning.amountEarned),
      0,
    );
    const totalConversions = earnings.length;
    const averageCommission = totalConversions > 0 ? totalCommissions / totalConversions : 0;

    // Calculate growth percentage (compare with previous period)
    const previousStartDate = new Date(startDate);
    previousStartDate.setDate(previousStartDate.getDate() - days);

    const previousQueryBuilder = this.affiliateEarningRepository
      .createQueryBuilder('earning')
      .where('earning.createdAt >= :previousStartDate', { previousStartDate })
      .andWhere('earning.createdAt < :startDate', { startDate })
      .andWhere('earning.status = :status', { status: EarningStatusEnum.CONFIRMED });

    if (partnerId) {
      previousQueryBuilder.andWhere('earning.partnerId = :partnerId', { partnerId });
    }

    const previousEarnings = await previousQueryBuilder.getMany();
    const previousRevenue = previousEarnings.reduce(
      (sum, earning) => sum + Number(earning.amountEarned),
      0,
    );
    const growthPercentage =
      previousRevenue > 0 ? ((totalRevenue - previousRevenue) / previousRevenue) * 100 : 0;

    const metrics: RevenueMetricsDto = {
      totalRevenue,
      totalCommissions,
      totalConversions,
      averageCommission,
      growthPercentage,
    };

    // Cache for 1 hour
    await this.cacheManager.set(cacheKey, metrics, 3600);
    return metrics;
  }

  async getPartnerPerformance(limit: number = 10): Promise<PartnerPerformanceDto[]> {
    const cacheKey = `partner_performance_${limit}`;
    const cached = await this.cacheManager.get<PartnerPerformanceDto[]>(cacheKey);

    if (cached) {
      return cached;
    }

    const performance = await this.affiliateEarningRepository
      .createQueryBuilder('earning')
      .leftJoin('earning.partner', 'partner')
      .select([
        'partner.id as "partnerId"',
        'partner.name as "partnerName"',
        'partner.category as "category"',
        'SUM(earning.amountEarned) as "totalEarnings"',
        'COUNT(earning.id) as "conversions"',
      ])
      .where('earning.status = :status', { status: EarningStatusEnum.CONFIRMED })
      .groupBy('partner.id, partner.name, partner.category')
      .orderBy('"totalEarnings"', 'DESC')
      .limit(limit)
      .getRawMany();

    const result: PartnerPerformanceDto[] = performance.map(p => ({
      partnerId: p.partnerId,
      partnerName: p.partnerName,
      totalEarnings: parseFloat(p.totalEarnings) || 0,
      conversions: parseInt(p.conversions) || 0,
      conversionRate: 0, // Calculate based on clicks if available
      category: p.category,
    }));

    // Cache for 1 hour
    await this.cacheManager.set(cacheKey, result, 3600);
    return result;
  }

  async getRevenueTrends(partnerId?: string, days: number = 30): Promise<RevenueTrendDto[]> {
    const cacheKey = `revenue_trends_${partnerId || 'all'}_${days}`;
    const cached = await this.cacheManager.get<RevenueTrendDto[]>(cacheKey);

    if (cached) {
      return cached;
    }

    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const queryBuilder = this.affiliateEarningRepository
      .createQueryBuilder('earning')
      .select([
        'DATE(earning.createdAt) as "date"',
        'SUM(earning.amountEarned) as "revenue"',
        'SUM(earning.amountEarned) as "commissions"',
        'COUNT(earning.id) as "conversions"',
      ])
      .where('earning.createdAt >= :startDate', { startDate })
      .andWhere('earning.status = :status', { status: EarningStatusEnum.CONFIRMED })
      .groupBy('DATE(earning.createdAt)')
      .orderBy('"date"', 'ASC');

    if (partnerId) {
      queryBuilder.andWhere('earning.partnerId = :partnerId', { partnerId });
    }

    const trends = await queryBuilder.getRawMany();

    const result: RevenueTrendDto[] = trends.map(t => ({
      date: t.date,
      revenue: parseFloat(t.revenue) || 0,
      commissions: parseFloat(t.commissions) || 0,
      conversions: parseInt(t.conversions) || 0,
    }));

    // Cache for 1 hour
    await this.cacheManager.set(cacheKey, result, 3600);
    return result;
  }

  async getCommissionBatches(limit: number = 20): Promise<CommissionBatchDto[]> {
    const cacheKey = `commission_batches_${limit}`;
    const cached = await this.cacheManager.get<CommissionBatchDto[]>(cacheKey);

    if (cached) {
      return cached;
    }

    const batches = await this.commissionBatchRepository.find({
      order: { createdAt: 'DESC' },
      take: limit,
    });

    const result: CommissionBatchDto[] = batches.map(batch => ({
      id: batch.id,
      batchDate: batch.batchDate.toISOString().split('T')[0],
      totalCommissions: Number(batch.totalCommissions),
      processedEarnings: batch.processedEarnings,
      status: batch.status,
      errorMessage: batch.errorMessage,
      createdAt: batch.createdAt,
    }));

    // Cache for 30 minutes
    await this.cacheManager.set(cacheKey, result, 1800);
    return result;
  }

  async clearAnalyticsCache(): Promise<void> {
    // Simple cache clearing - delete specific keys we know about
    const keysToDelete = [
      'revenue_metrics_all_30',
      'revenue_metrics_all_7',
      'revenue_metrics_all_90',
      'partner_performance_10',
      'partner_performance_20',
      'revenue_trends_all_30',
      'revenue_trends_all_7',
      'revenue_trends_all_90',
      'commission_batches_20',
      'commission_batches_50',
    ];

    for (const key of keysToDelete) {
      await this.cacheManager.del(key);
    }
  }
}
