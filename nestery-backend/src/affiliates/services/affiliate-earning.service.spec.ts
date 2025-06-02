import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import { AffiliateEarningService, RecordConversionDetails } from './affiliate-earning.service';
import { AffiliateEarningEntity } from '../entities/affiliate-earning.entity';
import { AffiliateLinkEntity } from '../entities/affiliate-link.entity';
import { AffiliateOfferEntity } from '../entities/affiliate-offer.entity';
import { PartnerEntity } from '../entities/partner.entity';
import { EarningStatusEnum } from '../enums/earning-status.enum';
import { CommissionCalculationService } from './commission-calculation.service';
import { AuditService } from './audit.service';

describe('AffiliateEarningService', () => {
  let service: AffiliateEarningService;

  const mockEarningRepository = {
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockLinkRepository = {
    findOne: jest.fn(),
  };

  const mockPartnerRepository = {
    findOneBy: jest.fn(),
  };

  const mockCommissionCalculationService = {
    calculateCommission: jest.fn(),
  };

  const mockAuditService = {
    logAction: jest.fn(),
  };

  const mockQueryBuilder = {
    leftJoinAndSelect: jest.fn().mockReturnThis(),
    where: jest.fn().mockReturnThis(),
    andWhere: jest.fn().mockReturnThis(),
    orderBy: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    take: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    setParameters: jest.fn().mockReturnThis(),
    getManyAndCount: jest.fn(),
    getRawOne: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AffiliateEarningService,
        {
          provide: getRepositoryToken(AffiliateEarningEntity),
          useValue: mockEarningRepository,
        },
        {
          provide: getRepositoryToken(AffiliateLinkEntity),
          useValue: mockLinkRepository,
        },
        {
          provide: getRepositoryToken(AffiliateOfferEntity),
          useValue: {},
        },
        {
          provide: getRepositoryToken(PartnerEntity),
          useValue: mockPartnerRepository,
        },
        {
          provide: CommissionCalculationService,
          useValue: mockCommissionCalculationService,
        },
        {
          provide: AuditService,
          useValue: mockAuditService,
        },
      ],
    }).compile();

    service = module.get<AffiliateEarningService>(AffiliateEarningService);

    // Reset mocks
    jest.clearAllMocks();
    mockEarningRepository.createQueryBuilder.mockReturnValue(mockQueryBuilder);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('recordConversion', () => {
    const linkId = 'link-1';
    const conversionDetails: RecordConversionDetails = {
      amount: 100,
      currency: 'USD',
      bookingId: 'booking-1',
      conversionReferenceId: 'conv-1',
    };

    const mockLink = {
      id: linkId,
      userId: 'user-1',
      offerId: 'offer-1',
      offer: {
        id: 'offer-1',
        title: 'Test Offer',
        partnerId: 'partner-1',
        isActive: true,
        partner: {
          id: 'partner-1',
          name: 'Test Partner',
          isActive: true,
        },
      },
    };

    const mockCommissionResult = {
      amountEarned: { toNumber: () => 15.0 },
      currency: 'USD',
      calculationDetails: 'Calculated using 15% rate',
    };

    it('should record conversion successfully', async () => {
      const mockEarning = {
        id: 'earning-1',
        partnerId: 'partner-1',
        offerId: 'offer-1',
        linkId: linkId,
        userId: 'user-1',
        amountEarned: 15.0,
        currency: 'USD',
        status: EarningStatusEnum.PENDING,
      };

      mockLinkRepository.findOne.mockResolvedValue(mockLink);
      mockCommissionCalculationService.calculateCommission.mockResolvedValue(mockCommissionResult);
      mockEarningRepository.create.mockReturnValue(mockEarning);
      mockEarningRepository.save.mockResolvedValue(mockEarning);
      mockAuditService.logAction.mockResolvedValue(undefined);

      const result = await service.recordConversion(linkId, conversionDetails);

      expect(mockLinkRepository.findOne).toHaveBeenCalledWith({
        where: { id: linkId },
        relations: ['offer', 'offer.partner'],
      });
      expect(mockCommissionCalculationService.calculateCommission).toHaveBeenCalledWith({
        partnerId: 'partner-1',
        offerId: 'offer-1',
        bookingValue: 100,
        currency: 'USD',
        conversionReferenceId: 'conv-1',
        linkId: linkId,
        userId: 'user-1',
        bookingId: 'booking-1',
      });
      expect(mockEarningRepository.create).toHaveBeenCalledWith({
        partnerId: 'partner-1',
        offerId: 'offer-1',
        linkId: linkId,
        userId: 'user-1',
        bookingId: 'booking-1',
        conversionReferenceId: 'conv-1',
        amountEarned: 15.0,
        currency: 'USD',
        transactionDate: expect.any(Date),
        status: EarningStatusEnum.PENDING,
        notes: 'Commission calculated: Calculated using 15% rate',
      });
      expect(mockAuditService.logAction).toHaveBeenCalled();
      expect(result).toEqual(mockEarning);
    });

    it('should throw BadRequestException for invalid amount', async () => {
      const invalidDetails = { ...conversionDetails, amount: 0 };

      await expect(service.recordConversion(linkId, invalidDetails)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should throw NotFoundException if link not found', async () => {
      mockLinkRepository.findOne.mockResolvedValue(null);

      await expect(service.recordConversion(linkId, conversionDetails)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw BadRequestException if offer is not active', async () => {
      const inactiveOfferLink = {
        ...mockLink,
        offer: { ...mockLink.offer, isActive: false },
      };
      mockLinkRepository.findOne.mockResolvedValue(inactiveOfferLink);

      await expect(service.recordConversion(linkId, conversionDetails)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should throw BadRequestException if partner is not active', async () => {
      const inactivePartnerLink = {
        ...mockLink,
        offer: {
          ...mockLink.offer,
          partner: { ...mockLink.offer.partner, isActive: false },
        },
      };
      mockLinkRepository.findOne.mockResolvedValue(inactivePartnerLink);

      await expect(service.recordConversion(linkId, conversionDetails)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should handle commission calculation errors', async () => {
      mockLinkRepository.findOne.mockResolvedValue(mockLink);
      mockCommissionCalculationService.calculateCommission.mockRejectedValue(
        new Error('Commission calculation failed'),
      );

      await expect(service.recordConversion(linkId, conversionDetails)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('getConversionReport', () => {
    const partnerId = 'partner-1';
    const filters = {
      status: EarningStatusEnum.CONFIRMED,
      dateFrom: new Date('2024-01-01'),
      dateTo: new Date('2024-12-31'),
    };

    it('should generate conversion report successfully', async () => {
      const mockPartner = { id: partnerId, name: 'Test Partner' };
      const mockEarnings = [
        { id: 'earning-1', amountEarned: 15.0, status: EarningStatusEnum.CONFIRMED },
        { id: 'earning-2', amountEarned: 25.0, status: EarningStatusEnum.CONFIRMED },
      ];
      const mockSummary = {
        totalEarnings: '40.0',
        totalPending: '0.0',
        totalConfirmed: '40.0',
        totalPaid: '0.0',
      };

      mockPartnerRepository.findOneBy.mockResolvedValue(mockPartner);
      mockQueryBuilder.getManyAndCount.mockResolvedValue([mockEarnings, 2]);
      mockQueryBuilder.getRawOne.mockResolvedValue(mockSummary);

      const result = await service.getConversionReport(partnerId, filters);

      expect(mockPartnerRepository.findOneBy).toHaveBeenCalledWith({ id: partnerId });
      expect(mockQueryBuilder.where).toHaveBeenCalledWith('earning.partnerId = :partnerId', {
        partnerId,
      });
      expect(mockQueryBuilder.andWhere).toHaveBeenCalledWith('earning.status = :status', {
        status: EarningStatusEnum.CONFIRMED,
      });
      expect(result).toEqual({
        earnings: mockEarnings,
        total: 2,
        summary: {
          totalEarnings: 40.0,
          totalPending: 0.0,
          totalConfirmed: 40.0,
          totalPaid: 0.0,
          currency: 'USD',
        },
      });
    });

    it('should throw NotFoundException if partner not found', async () => {
      mockPartnerRepository.findOneBy.mockResolvedValue(null);

      await expect(service.getConversionReport(partnerId, filters)).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe('updateEarningStatus', () => {
    const earningId = 'earning-1';
    const newStatus = EarningStatusEnum.CONFIRMED;
    const reason = 'Manual confirmation';

    it('should update earning status successfully', async () => {
      const mockEarning = {
        id: earningId,
        status: EarningStatusEnum.PENDING,
        partnerId: 'partner-1',
        amountEarned: 15.0,
        currency: 'USD',
        notes: 'Initial note',
      };
      const updatedEarning = { ...mockEarning, status: newStatus };

      mockEarningRepository.findOne.mockResolvedValue(mockEarning);
      mockEarningRepository.save.mockResolvedValue(updatedEarning);
      mockAuditService.logAction.mockResolvedValue(undefined);

      const result = await service.updateEarningStatus(earningId, newStatus, reason, 'user-1');

      expect(mockEarningRepository.findOne).toHaveBeenCalledWith({
        where: { id: earningId },
        relations: ['partner', 'offer'],
      });
      expect(mockEarningRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({ status: newStatus }),
      );
      expect(mockAuditService.logAction).toHaveBeenCalledWith({
        userId: 'user-1',
        partnerId: 'partner-1',
        entityId: earningId,
        entityType: 'AffiliateEarning',
        actionType: 'STATUS_UPDATED',
        details: {
          oldStatus: EarningStatusEnum.PENDING,
          newStatus: newStatus,
          reason: reason,
          amountEarned: 15.0,
          currency: 'USD',
        },
      });
      expect(result).toEqual(updatedEarning);
    });

    it('should throw NotFoundException if earning not found', async () => {
      mockEarningRepository.findOne.mockResolvedValue(null);

      await expect(service.updateEarningStatus(earningId, newStatus)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw BadRequestException for invalid status transition', async () => {
      const mockEarning = {
        id: earningId,
        status: EarningStatusEnum.PAID, // Terminal state
      };
      mockEarningRepository.findOne.mockResolvedValue(mockEarning);

      await expect(
        service.updateEarningStatus(earningId, EarningStatusEnum.PENDING),
      ).rejects.toThrow(BadRequestException);
    });
  });
});
