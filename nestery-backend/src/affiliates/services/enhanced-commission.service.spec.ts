import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { EnhancedCommissionService } from './enhanced-commission.service';
import { CommissionBatchEntity, BatchStatus } from '../entities/commission-batch.entity';
import { AffiliateEarningEntity, EarningStatusEnum } from '../entities/affiliate-earning.entity';
import { CommissionCalculationService } from './commission-calculation.service';

describe('EnhancedCommissionService', () => {
  let service: EnhancedCommissionService;

  const mockCommissionBatchRepository = {
    create: jest.fn(),
    save: jest.fn(),
    update: jest.fn(),
    find: jest.fn(),
  };

  const mockAffiliateEarningRepository = {
    find: jest.fn(),
    save: jest.fn(),
  };

  const mockCommissionCalculationService = {
    calculateCommission: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        EnhancedCommissionService,
        {
          provide: getRepositoryToken(CommissionBatchEntity),
          useValue: mockCommissionBatchRepository,
        },
        {
          provide: getRepositoryToken(AffiliateEarningEntity),
          useValue: mockAffiliateEarningRepository,
        },
        {
          provide: CommissionCalculationService,
          useValue: mockCommissionCalculationService,
        },
      ],
    }).compile();

    service = module.get<EnhancedCommissionService>(EnhancedCommissionService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('createCommissionBatch', () => {
    it('should create a new commission batch', async () => {
      const batchDate = new Date();
      const mockBatch = {
        id: 'batch-123',
        batchDate,
        status: BatchStatus.PROCESSING,
      } as CommissionBatchEntity;

      mockCommissionBatchRepository.create.mockReturnValue(mockBatch);
      mockCommissionBatchRepository.save.mockResolvedValue(mockBatch);

      const result = await service.createCommissionBatch(batchDate);

      expect(mockCommissionBatchRepository.create).toHaveBeenCalledWith({
        batchDate,
        status: BatchStatus.PROCESSING,
      });
      expect(mockCommissionBatchRepository.save).toHaveBeenCalledWith(mockBatch);
      expect(result).toEqual(mockBatch);
    });
  });

  describe('completeCommissionBatch', () => {
    it('should update batch status to completed', async () => {
      const batchId = 'batch-123';
      const totalCommissions = 1000;
      const processedEarnings = 5;

      await service.completeCommissionBatch(batchId, totalCommissions, processedEarnings);

      expect(mockCommissionBatchRepository.update).toHaveBeenCalledWith(batchId, {
        status: BatchStatus.COMPLETED,
        totalCommissions,
        processedEarnings,
      });
    });
  });

  describe('failCommissionBatch', () => {
    it('should update batch status to failed with error message', async () => {
      const batchId = 'batch-123';
      const errorMessage = 'Processing failed';

      await service.failCommissionBatch(batchId, errorMessage);

      expect(mockCommissionBatchRepository.update).toHaveBeenCalledWith(batchId, {
        status: BatchStatus.FAILED,
        errorMessage,
      });
    });
  });

  describe('getCommissionBatches', () => {
    it('should return commission batches ordered by creation date', async () => {
      const mockBatches = [
        { id: 'batch-1', createdAt: new Date() },
        { id: 'batch-2', createdAt: new Date() },
      ] as CommissionBatchEntity[];

      mockCommissionBatchRepository.find.mockResolvedValue(mockBatches);

      const result = await service.getCommissionBatches();

      expect(mockCommissionBatchRepository.find).toHaveBeenCalledWith({
        order: { createdAt: 'DESC' },
        take: 50,
      });
      expect(result).toEqual(mockBatches);
    });
  });

  describe('manualProcessCommissions', () => {
    it('should process pending earnings and return summary', async () => {
      const mockBatch = {
        id: 'batch-123',
        batchDate: new Date(),
        status: BatchStatus.PROCESSING,
      } as CommissionBatchEntity;

      const mockEarnings = [
        {
          id: 'earning-1',
          partnerId: 'partner-1',
          offerId: 'offer-1',
          amountEarned: 100,
          currency: 'USD',
          status: EarningStatusEnum.PENDING,
        },
        {
          id: 'earning-2',
          partnerId: 'partner-2',
          offerId: 'offer-2',
          amountEarned: 200,
          currency: 'USD',
          status: EarningStatusEnum.PENDING,
        },
      ] as AffiliateEarningEntity[];

      const mockCalculationResult = {
        amountEarned: 150,
        calculationDetails: { rate: 0.15 },
      };

      mockCommissionBatchRepository.create.mockReturnValue(mockBatch);
      mockCommissionBatchRepository.save.mockResolvedValue(mockBatch);
      mockAffiliateEarningRepository.find.mockResolvedValue(mockEarnings);
      mockCommissionCalculationService.calculateCommission.mockResolvedValue(mockCalculationResult);
      mockAffiliateEarningRepository.save.mockResolvedValue({});
      mockCommissionBatchRepository.update.mockResolvedValue({});

      const result = await service.manualProcessCommissions();

      expect(result).toEqual({
        batchId: 'batch-123',
        processedCount: 2,
        totalCommissions: 300, // 150 * 2
      });

      expect(mockAffiliateEarningRepository.find).toHaveBeenCalledWith({
        where: { status: EarningStatusEnum.PENDING },
        relations: ['partner', 'offer'],
      });

      expect(mockCommissionCalculationService.calculateCommission).toHaveBeenCalledTimes(2);
      expect(mockAffiliateEarningRepository.save).toHaveBeenCalledTimes(2);
    });

    it('should handle errors during processing', async () => {
      const mockBatch = {
        id: 'batch-123',
        batchDate: new Date(),
        status: BatchStatus.PROCESSING,
      } as CommissionBatchEntity;

      mockCommissionBatchRepository.create.mockReturnValue(mockBatch);
      mockCommissionBatchRepository.save.mockResolvedValue(mockBatch);
      mockAffiliateEarningRepository.find.mockRejectedValue(new Error('Database error'));
      mockCommissionBatchRepository.update.mockResolvedValue({});

      await expect(service.manualProcessCommissions()).rejects.toThrow('Database error');

      expect(mockCommissionBatchRepository.update).toHaveBeenCalledWith('batch-123', {
        status: BatchStatus.FAILED,
        errorMessage: 'Database error',
      });
    });
  });
});
