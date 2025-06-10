import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Repository } from 'typeorm';
import { Cache } from 'cache-manager';
import { RevenueAnalyticsService } from './revenue-analytics.service';
import { AffiliateEarningEntity } from '../entities/affiliate-earning.entity';
import { PartnerEntity } from '../entities/partner.entity';
import { CommissionBatchEntity } from '../entities/commission-batch.entity';

describe('RevenueAnalyticsService', () => {
  let service: RevenueAnalyticsService;

  const mockAffiliateEarningRepository = {
    createQueryBuilder: jest.fn(),
    find: jest.fn(),
  };

  const mockPartnerRepository = {
    find: jest.fn(),
  };

  const mockCommissionBatchRepository = {
    find: jest.fn(),
  };

  const mockCacheManager = {
    get: jest.fn(),
    set: jest.fn(),
    del: jest.fn(),
  };

  const mockQueryBuilder = {
    where: jest.fn().mockReturnThis(),
    andWhere: jest.fn().mockReturnThis(),
    leftJoin: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    groupBy: jest.fn().mockReturnThis(),
    orderBy: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    getMany: jest.fn(),
    getRawMany: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RevenueAnalyticsService,
        {
          provide: getRepositoryToken(AffiliateEarningEntity),
          useValue: mockAffiliateEarningRepository,
        },
        {
          provide: getRepositoryToken(PartnerEntity),
          useValue: mockPartnerRepository,
        },
        {
          provide: getRepositoryToken(CommissionBatchEntity),
          useValue: mockCommissionBatchRepository,
        },
        {
          provide: CACHE_MANAGER,
          useValue: mockCacheManager,
        },
      ],
    }).compile();

    service = module.get<RevenueAnalyticsService>(RevenueAnalyticsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getRevenueMetrics', () => {
    it('should return cached metrics if available', async () => {
      const cachedMetrics = {
        totalRevenue: 1000,
        totalCommissions: 150,
        totalConversions: 10,
        averageCommission: 15,
        growthPercentage: 20,
      };

      mockCacheManager.get.mockResolvedValue(cachedMetrics);

      const result = await service.getRevenueMetrics();

      expect(mockCacheManager.get).toHaveBeenCalledWith('revenue_metrics_all_30');
      expect(result).toEqual(cachedMetrics);
    });

    it('should calculate and cache metrics when not cached', async () => {
      const mockEarnings = [
        { amountEarned: 100 },
        { amountEarned: 200 },
        { amountEarned: 150 },
      ] as AffiliateEarningEntity[];

      const mockPreviousEarnings = [
        { amountEarned: 300 },
        { amountEarned: 100 },
      ] as AffiliateEarningEntity[];

      mockCacheManager.get.mockResolvedValue(null);
      mockAffiliateEarningRepository.createQueryBuilder.mockReturnValue(mockQueryBuilder);
      mockQueryBuilder.getMany
        .mockResolvedValueOnce(mockEarnings)
        .mockResolvedValueOnce(mockPreviousEarnings);

      const result = await service.getRevenueMetrics();

      expect(result).toEqual({
        totalRevenue: 450,
        totalCommissions: 450,
        totalConversions: 3,
        averageCommission: 150,
        growthPercentage: 12.5, // (450 - 400) / 400 * 100
      });

      expect(mockCacheManager.set).toHaveBeenCalledWith(
        'revenue_metrics_all_30',
        expect.any(Object),
        3600,
      );
    });

    it('should filter by partner ID when provided', async () => {
      const partnerId = 'partner-123';
      mockCacheManager.get.mockResolvedValue(null);
      mockAffiliateEarningRepository.createQueryBuilder.mockReturnValue(mockQueryBuilder);
      mockQueryBuilder.getMany.mockResolvedValue([]);

      await service.getRevenueMetrics(partnerId);

      expect(mockQueryBuilder.andWhere).toHaveBeenCalledWith('earning.partnerId = :partnerId', {
        partnerId,
      });
    });
  });

  describe('getPartnerPerformance', () => {
    it('should return cached partner performance if available', async () => {
      const cachedPerformance = [
        {
          partnerId: 'partner-1',
          partnerName: 'Partner 1',
          totalEarnings: 1000,
          conversions: 10,
          conversionRate: 0,
          category: 'premium',
        },
      ];

      mockCacheManager.get.mockResolvedValue(cachedPerformance);

      const result = await service.getPartnerPerformance();

      expect(mockCacheManager.get).toHaveBeenCalledWith('partner_performance_10');
      expect(result).toEqual(cachedPerformance);
    });

    it('should calculate and cache partner performance when not cached', async () => {
      const mockRawData = [
        {
          partnerId: 'partner-1',
          partnerName: 'Partner 1',
          category: 'premium',
          totalEarnings: '1000.50',
          conversions: '10',
        },
        {
          partnerId: 'partner-2',
          partnerName: 'Partner 2',
          category: 'standard',
          totalEarnings: '500.25',
          conversions: '5',
        },
      ];

      mockCacheManager.get.mockResolvedValue(null);
      mockAffiliateEarningRepository.createQueryBuilder.mockReturnValue(mockQueryBuilder);
      mockQueryBuilder.getRawMany.mockResolvedValue(mockRawData);

      const result = await service.getPartnerPerformance();

      expect(result).toEqual([
        {
          partnerId: 'partner-1',
          partnerName: 'Partner 1',
          totalEarnings: 1000.5,
          conversions: 10,
          conversionRate: 0,
          category: 'premium',
        },
        {
          partnerId: 'partner-2',
          partnerName: 'Partner 2',
          totalEarnings: 500.25,
          conversions: 5,
          conversionRate: 0,
          category: 'standard',
        },
      ]);

      expect(mockCacheManager.set).toHaveBeenCalledWith(
        'partner_performance_10',
        expect.any(Array),
        3600,
      );
    });
  });

  describe('getRevenueTrends', () => {
    it('should return cached trends if available', async () => {
      const cachedTrends = [
        {
          date: '2024-01-01',
          revenue: 1000,
          commissions: 150,
          conversions: 10,
        },
      ];

      mockCacheManager.get.mockResolvedValue(cachedTrends);

      const result = await service.getRevenueTrends();

      expect(mockCacheManager.get).toHaveBeenCalledWith('revenue_trends_all_30');
      expect(result).toEqual(cachedTrends);
    });

    it('should calculate and cache trends when not cached', async () => {
      const mockRawData = [
        {
          date: '2024-01-01',
          revenue: '1000.50',
          commissions: '150.75',
          conversions: '10',
        },
        {
          date: '2024-01-02',
          revenue: '800.25',
          commissions: '120.50',
          conversions: '8',
        },
      ];

      mockCacheManager.get.mockResolvedValue(null);
      mockAffiliateEarningRepository.createQueryBuilder.mockReturnValue(mockQueryBuilder);
      mockQueryBuilder.getRawMany.mockResolvedValue(mockRawData);

      const result = await service.getRevenueTrends();

      expect(result).toEqual([
        {
          date: '2024-01-01',
          revenue: 1000.5,
          commissions: 150.75,
          conversions: 10,
        },
        {
          date: '2024-01-02',
          revenue: 800.25,
          commissions: 120.5,
          conversions: 8,
        },
      ]);

      expect(mockCacheManager.set).toHaveBeenCalledWith(
        'revenue_trends_all_30',
        expect.any(Array),
        3600,
      );
    });
  });

  describe('getCommissionBatches', () => {
    it('should return cached batches if available', async () => {
      const cachedBatches = [
        {
          id: 'batch-1',
          batchDate: '2024-01-01',
          totalCommissions: 1000,
          processedEarnings: 10,
          status: 'completed',
          errorMessage: null,
          createdAt: new Date(),
        },
      ];

      mockCacheManager.get.mockResolvedValue(cachedBatches);

      const result = await service.getCommissionBatches();

      expect(mockCacheManager.get).toHaveBeenCalledWith('commission_batches_20');
      expect(result).toEqual(cachedBatches);
    });

    it('should fetch and cache batches when not cached', async () => {
      const mockBatches = [
        {
          id: 'batch-1',
          batchDate: new Date('2024-01-01'),
          totalCommissions: 1000,
          processedEarnings: 10,
          status: 'completed',
          errorMessage: null,
          createdAt: new Date(),
          updatedAt: new Date(),
        },
      ] as CommissionBatchEntity[];

      mockCacheManager.get.mockResolvedValue(null);
      mockCommissionBatchRepository.find.mockResolvedValue(mockBatches);

      const result = await service.getCommissionBatches();

      expect(result[0]).toEqual({
        id: 'batch-1',
        batchDate: '2024-01-01',
        totalCommissions: 1000,
        processedEarnings: 10,
        status: 'completed',
        errorMessage: null,
        createdAt: expect.any(Date),
      });

      expect(mockCacheManager.set).toHaveBeenCalledWith(
        'commission_batches_20',
        expect.any(Array),
        1800,
      );
    });
  });

  describe('clearAnalyticsCache', () => {
    it('should clear all analytics cache keys', async () => {
      await service.clearAnalyticsCache();

      const expectedKeys = [
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

      expectedKeys.forEach(key => {
        expect(mockCacheManager.del).toHaveBeenCalledWith(key);
      });
    });
  });
});
