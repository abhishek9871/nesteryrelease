import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Decimal } from 'decimal.js';
import { CommissionCalculationService } from './commission-calculation.service';
import { PartnerEntity } from '../entities/partner.entity';
import { AffiliateOfferEntity } from '../entities/affiliate-offer.entity';
import { AffiliateEarningEntity } from '../entities/affiliate-earning.entity';
import { AuditService } from './audit.service';

describe('CommissionCalculationService', () => {
  let service: CommissionCalculationService;
  let partnerRepository: Repository<PartnerEntity>;
  let offerRepository: Repository<AffiliateOfferEntity>;
  let earningRepository: Repository<AffiliateEarningEntity>;
  let auditService: AuditService;

  const mockPartnerRepository = {
    findOne: jest.fn(),
  };

  const mockOfferRepository = {
    findOne: jest.fn(),
  };

  const mockEarningRepository = {
    findOne: jest.fn(),
    save: jest.fn(),
  };

  const mockAuditService = {
    logAction: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CommissionCalculationService,
        {
          provide: getRepositoryToken(PartnerEntity),
          useValue: mockPartnerRepository,
        },
        {
          provide: getRepositoryToken(AffiliateOfferEntity),
          useValue: mockOfferRepository,
        },
        {
          provide: getRepositoryToken(AffiliateEarningEntity),
          useValue: mockEarningRepository,
        },
        {
          provide: AuditService,
          useValue: mockAuditService,
        },
      ],
    }).compile();

    service = module.get<CommissionCalculationService>(CommissionCalculationService);
    partnerRepository = module.get<Repository<PartnerEntity>>(getRepositoryToken(PartnerEntity));
    offerRepository = module.get<Repository<AffiliateOfferEntity>>(getRepositoryToken(AffiliateOfferEntity));
    earningRepository = module.get<Repository<AffiliateEarningEntity>>(getRepositoryToken(AffiliateEarningEntity));
    auditService = module.get<AuditService>(AuditService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('calculateCommission', () => {
    const mockPartner = {
      id: 'partner-1',
      commissionRateOverride: null,
    };

    const mockOffer = {
      id: 'offer-1',
      isActive: true,
      validFrom: new Date('2025-01-01'),
      validTo: new Date('2025-12-31'),
      commissionStructure: {
        type: 'percentage',
        value: 10,
      },
    };

    beforeEach(() => {
      mockPartnerRepository.findOne.mockResolvedValue(mockPartner);
      mockOfferRepository.findOne.mockResolvedValue(mockOffer);
      mockAuditService.logAction.mockResolvedValue({});
    });

    it('should calculate percentage commission correctly', async () => {
      const input = {
        partnerId: 'partner-1',
        offerId: 'offer-1',
        bookingValue: 1000,
        currency: 'USD',
      };

      const result = await service.calculateCommission(input);

      expect(result.amountEarned.toString()).toBe('100');
      expect(result.currency).toBe('USD');
      expect(result.calculationDetails.commissionType).toBe('percentage');
      expect(result.calculationDetails.commissionRate.toString()).toBe('0.1');
    });

    it('should calculate fixed commission correctly', async () => {
      const fixedOffer = {
        ...mockOffer,
        commissionStructure: {
          type: 'fixed',
          value: 50,
        },
      };
      mockOfferRepository.findOne.mockResolvedValue(fixedOffer);

      const input = {
        partnerId: 'partner-1',
        offerId: 'offer-1',
        bookingValue: 1000,
        currency: 'USD',
      };

      const result = await service.calculateCommission(input);

      expect(result.amountEarned.toString()).toBe('50');
      expect(result.calculationDetails.commissionType).toBe('fixed');
    });

    it('should calculate tiered commission correctly', async () => {
      const tieredOffer = {
        ...mockOffer,
        commissionStructure: {
          type: 'tiered',
          tiers: [
            { threshold: 0, value: 5, valueType: 'percentage' },
            { threshold: 500, value: 8, valueType: 'percentage' },
            { threshold: 1000, value: 10, valueType: 'percentage' },
          ],
        },
      };
      mockOfferRepository.findOne.mockResolvedValue(tieredOffer);

      const input = {
        partnerId: 'partner-1',
        offerId: 'offer-1',
        bookingValue: 1200,
        currency: 'USD',
      };

      const result = await service.calculateCommission(input);

      expect(result.amountEarned.toString()).toBe('120');
      expect(result.calculationDetails.tierApplied).toContain('1000+');
    });

    it('should apply partner commission rate override', async () => {
      const partnerWithOverride = {
        ...mockPartner,
        commissionRateOverride: 0.15, // 15%
      };
      mockPartnerRepository.findOne.mockResolvedValue(partnerWithOverride);

      const input = {
        partnerId: 'partner-1',
        offerId: 'offer-1',
        bookingValue: 1000,
        currency: 'USD',
      };

      const result = await service.calculateCommission(input);

      expect(result.amountEarned.toString()).toBe('150');
      expect(result.calculationDetails.adjustments).toBeDefined();
      expect(result.calculationDetails.adjustments!).toHaveLength(1);
      expect(result.calculationDetails.adjustments![0].type).toBe('partner_override');
    });

    it('should throw error for missing partner', async () => {
      mockPartnerRepository.findOne.mockResolvedValue(null);

      const input = {
        partnerId: 'invalid-partner',
        offerId: 'offer-1',
        bookingValue: 1000,
        currency: 'USD',
      };

      await expect(service.calculateCommission(input)).rejects.toThrow('Partner not found');
    });

    it('should throw error for missing offer', async () => {
      mockOfferRepository.findOne.mockResolvedValue(null);

      const input = {
        partnerId: 'partner-1',
        offerId: 'invalid-offer',
        bookingValue: 1000,
        currency: 'USD',
      };

      await expect(service.calculateCommission(input)).rejects.toThrow('Offer not found');
    });

    it('should throw error for inactive offer', async () => {
      const inactiveOffer = {
        ...mockOffer,
        isActive: false,
      };
      mockOfferRepository.findOne.mockResolvedValue(inactiveOffer);

      const input = {
        partnerId: 'partner-1',
        offerId: 'offer-1',
        bookingValue: 1000,
        currency: 'USD',
      };

      await expect(service.calculateCommission(input)).rejects.toThrow('Offer is not active');
    });

    it('should throw error for expired offer', async () => {
      const expiredOffer = {
        ...mockOffer,
        validTo: new Date('2024-12-31'),
      };
      mockOfferRepository.findOne.mockResolvedValue(expiredOffer);

      const input = {
        partnerId: 'partner-1',
        offerId: 'offer-1',
        bookingValue: 1000,
        currency: 'USD',
      };

      await expect(service.calculateCommission(input)).rejects.toThrow('Offer is not valid for current date');
    });

    it('should audit commission calculation', async () => {
      const input = {
        partnerId: 'partner-1',
        offerId: 'offer-1',
        bookingValue: 1000,
        currency: 'USD',
        userId: 'user-1',
      };

      await service.calculateCommission(input);

      expect(mockAuditService.logAction).toHaveBeenCalledWith({
        userId: 'user-1',
        partnerId: 'partner-1',
        entityId: 'offer-1',
        entityType: 'commission_calculation',
        actionType: 'COMMISSION_CALCULATED',
        details: expect.objectContaining({
          input,
          result: expect.any(Object),
        }),
      });
    });
  });

  describe('processCommissionAdjustment', () => {
    const mockEarning = {
      id: 'earning-1',
      partnerId: 'partner-1',
      amountEarned: 100,
      notes: '',
      partner: { id: 'partner-1' },
      offer: { id: 'offer-1' },
    };

    beforeEach(() => {
      mockEarningRepository.findOne.mockResolvedValue(mockEarning);
      mockEarningRepository.save.mockResolvedValue(mockEarning);
      mockAuditService.logAction.mockResolvedValue({});
    });

    it('should process bonus adjustment correctly', async () => {
      const result = await service.processCommissionAdjustment(
        'earning-1',
        25,
        'BONUS',
        'Performance bonus',
        'user-1',
      );

      expect(result.amountEarned).toBe(125);
      expect(result.notes).toContain('BONUS: 25 - Performance bonus');
      expect(mockEarningRepository.save).toHaveBeenCalled();
    });

    it('should process clawback adjustment correctly', async () => {
      // Create a fresh mock earning for this test
      const clawbackEarning = {
        ...mockEarning,
        amountEarned: 100, // Ensure starting amount is 100
      };
      mockEarningRepository.findOne.mockResolvedValue(clawbackEarning);
      mockEarningRepository.save.mockImplementation((earning) => {
        return Promise.resolve(earning);
      });

      const result = await service.processCommissionAdjustment(
        'earning-1',
        -20,
        'CLAWBACK',
        'Refund processed',
        'user-1',
      );

      expect(result.amountEarned).toBe(80);
      expect(result.notes).toContain('CLAWBACK: -20 - Refund processed');
    });

    it('should prevent negative earning amounts', async () => {
      await expect(
        service.processCommissionAdjustment(
          'earning-1',
          -150,
          'CLAWBACK',
          'Large refund',
          'user-1',
        ),
      ).rejects.toThrow('Commission adjustment would result in negative earning amount');
    });

    it('should throw error for missing earning', async () => {
      mockEarningRepository.findOne.mockResolvedValue(null);

      await expect(
        service.processCommissionAdjustment(
          'invalid-earning',
          25,
          'BONUS',
          'Test bonus',
          'user-1',
        ),
      ).rejects.toThrow('Earning not found');
    });
  });
});
