import { Test, TestingModule } from '@nestjs/testing';
import { RevenueAnalyticsController } from './revenue-analytics.controller';
import { RevenueAnalyticsService } from '../services/revenue-analytics.service';
import { EnhancedCommissionService } from '../services/enhanced-commission.service';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../../auth/guards/roles.guard';

describe('RevenueAnalyticsController', () => {
  let controller: RevenueAnalyticsController;
  let revenueAnalyticsService: RevenueAnalyticsService;
  let enhancedCommissionService: EnhancedCommissionService;

  const mockRevenueAnalyticsService = {
    getRevenueMetrics: jest.fn(),
    getPartnerPerformance: jest.fn(),
    getRevenueTrends: jest.fn(),
    getCommissionBatches: jest.fn(),
    clearAnalyticsCache: jest.fn(),
  };

  const mockEnhancedCommissionService = {
    manualProcessCommissions: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [RevenueAnalyticsController],
      providers: [
        {
          provide: RevenueAnalyticsService,
          useValue: mockRevenueAnalyticsService,
        },
        {
          provide: EnhancedCommissionService,
          useValue: mockEnhancedCommissionService,
        },
      ],
    })
      .overrideGuard(JwtAuthGuard)
      .useValue({ canActivate: jest.fn(() => true) })
      .overrideGuard(RolesGuard)
      .useValue({ canActivate: jest.fn(() => true) })
      .compile();

    controller = module.get<RevenueAnalyticsController>(RevenueAnalyticsController);
    revenueAnalyticsService = module.get<RevenueAnalyticsService>(RevenueAnalyticsService);
    enhancedCommissionService = module.get<EnhancedCommissionService>(EnhancedCommissionService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getRevenueSummary', () => {
    it('should return revenue summary for all partners', async () => {
      const mockMetrics = {
        totalRevenue: 10000,
        totalCommissions: 1500,
        totalConversions: 100,
        averageCommission: 15,
        growthPercentage: 25,
      };

      mockRevenueAnalyticsService.getRevenueMetrics.mockResolvedValue(mockMetrics);

      const result = await controller.getRevenueSummary(30);

      expect(revenueAnalyticsService.getRevenueMetrics).toHaveBeenCalledWith(undefined, 30);
      expect(result).toEqual(mockMetrics);
    });

    it('should use default days parameter when not provided', async () => {
      const mockMetrics = {
        totalRevenue: 10000,
        totalCommissions: 1500,
        totalConversions: 100,
        averageCommission: 15,
        growthPercentage: 25,
      };

      mockRevenueAnalyticsService.getRevenueMetrics.mockResolvedValue(mockMetrics);

      const result = await controller.getRevenueSummary();

      expect(revenueAnalyticsService.getRevenueMetrics).toHaveBeenCalledWith(undefined, 30);
      expect(result).toEqual(mockMetrics);
    });
  });

  describe('getPartnerRevenue', () => {
    it('should return revenue metrics for specific partner', async () => {
      const partnerId = 'partner-123';
      const mockMetrics = {
        totalRevenue: 5000,
        totalCommissions: 750,
        totalConversions: 50,
        averageCommission: 15,
        growthPercentage: 15,
      };

      mockRevenueAnalyticsService.getRevenueMetrics.mockResolvedValue(mockMetrics);

      const result = await controller.getPartnerRevenue(partnerId, 7);

      expect(revenueAnalyticsService.getRevenueMetrics).toHaveBeenCalledWith(partnerId, 7);
      expect(result).toEqual(mockMetrics);
    });
  });

  describe('getPartnerPerformance', () => {
    it('should return top partner performance metrics', async () => {
      const mockPerformance = [
        {
          partnerId: 'partner-1',
          partnerName: 'Top Partner',
          totalEarnings: 5000,
          conversions: 50,
          conversionRate: 10,
          category: 'premium',
        },
        {
          partnerId: 'partner-2',
          partnerName: 'Second Partner',
          totalEarnings: 3000,
          conversions: 30,
          conversionRate: 8,
          category: 'standard',
        },
      ];

      mockRevenueAnalyticsService.getPartnerPerformance.mockResolvedValue(mockPerformance);

      const result = await controller.getPartnerPerformance(10);

      expect(revenueAnalyticsService.getPartnerPerformance).toHaveBeenCalledWith(10);
      expect(result).toEqual(mockPerformance);
    });

    it('should use default limit when not provided', async () => {
      const mockPerformance: any[] = [];
      mockRevenueAnalyticsService.getPartnerPerformance.mockResolvedValue(mockPerformance);

      await controller.getPartnerPerformance();

      expect(revenueAnalyticsService.getPartnerPerformance).toHaveBeenCalledWith(10);
    });
  });

  describe('getRevenueTrends', () => {
    it('should return revenue trends for all partners', async () => {
      const mockTrends = [
        {
          date: '2024-01-01',
          revenue: 1000,
          commissions: 150,
          conversions: 10,
        },
        {
          date: '2024-01-02',
          revenue: 1200,
          commissions: 180,
          conversions: 12,
        },
      ];

      mockRevenueAnalyticsService.getRevenueTrends.mockResolvedValue(mockTrends);

      const result = await controller.getRevenueTrends(7);

      expect(revenueAnalyticsService.getRevenueTrends).toHaveBeenCalledWith(undefined, 7);
      expect(result).toEqual(mockTrends);
    });
  });

  describe('getPartnerTrends', () => {
    it('should return revenue trends for specific partner', async () => {
      const partnerId = 'partner-123';
      const mockTrends = [
        {
          date: '2024-01-01',
          revenue: 500,
          commissions: 75,
          conversions: 5,
        },
      ];

      mockRevenueAnalyticsService.getRevenueTrends.mockResolvedValue(mockTrends);

      const result = await controller.getPartnerTrends(partnerId, 14);

      expect(revenueAnalyticsService.getRevenueTrends).toHaveBeenCalledWith(partnerId, 14);
      expect(result).toEqual(mockTrends);
    });
  });

  describe('getCommissionBatches', () => {
    it('should return commission processing batches', async () => {
      const mockBatches = [
        {
          id: 'batch-1',
          batchDate: '2024-01-01',
          totalCommissions: 1000,
          processedEarnings: 10,
          status: 'completed',
          errorMessage: null,
          createdAt: new Date(),
        },
        {
          id: 'batch-2',
          batchDate: '2024-01-02',
          totalCommissions: 1200,
          processedEarnings: 12,
          status: 'completed',
          errorMessage: null,
          createdAt: new Date(),
        },
      ];

      mockRevenueAnalyticsService.getCommissionBatches.mockResolvedValue(mockBatches);

      const result = await controller.getCommissionBatches(20);

      expect(revenueAnalyticsService.getCommissionBatches).toHaveBeenCalledWith(20);
      expect(result).toEqual(mockBatches);
    });

    it('should use default limit when not provided', async () => {
      const mockBatches: any[] = [];
      mockRevenueAnalyticsService.getCommissionBatches.mockResolvedValue(mockBatches);

      await controller.getCommissionBatches();

      expect(revenueAnalyticsService.getCommissionBatches).toHaveBeenCalledWith(20);
    });
  });

  describe('processCommissions', () => {
    it('should trigger manual commission processing', async () => {
      const mockResult = {
        batchId: 'batch-123',
        processedCount: 15,
        totalCommissions: 2250,
      };

      mockEnhancedCommissionService.manualProcessCommissions.mockResolvedValue(mockResult);

      const result = await controller.processCommissions();

      expect(enhancedCommissionService.manualProcessCommissions).toHaveBeenCalled();
      expect(result).toEqual(mockResult);
    });
  });

  describe('clearAnalyticsCache', () => {
    it('should clear analytics cache and return success message', async () => {
      mockRevenueAnalyticsService.clearAnalyticsCache.mockResolvedValue(undefined);

      const result = await controller.clearAnalyticsCache();

      expect(revenueAnalyticsService.clearAnalyticsCache).toHaveBeenCalled();
      expect(result).toEqual({ message: 'Analytics cache cleared successfully' });
    });
  });
});
