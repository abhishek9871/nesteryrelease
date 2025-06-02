import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { PayoutService } from './payout.service';
import { PartnerEntity } from '../entities/partner.entity';
import { PayoutEntity, PayoutStatus } from '../entities/payout.entity';
import { InvoiceEntity } from '../entities/invoice.entity';
import { AffiliateEarningEntity, EarningStatusEnum } from '../entities/affiliate-earning.entity';
import { AuditService } from './audit.service';

describe('PayoutService', () => {
  let service: PayoutService;
  let partnerRepository: Repository<PartnerEntity>;
  let payoutRepository: Repository<PayoutEntity>;
  let invoiceRepository: Repository<InvoiceEntity>;
  let earningRepository: Repository<AffiliateEarningEntity>;
  let auditService: AuditService;
  let configService: ConfigService;

  const mockPartnerRepository = {
    findOne: jest.fn(),
  };

  const mockPayoutRepository = {
    create: jest.fn(),
    save: jest.fn(),
    find: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockInvoiceRepository = {
    create: jest.fn(),
    save: jest.fn(),
    count: jest.fn(),
  };

  const mockEarningRepository = {
    find: jest.fn(),
    save: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockAuditService = {
    logPayoutAction: jest.fn(),
    logAction: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PayoutService,
        {
          provide: getRepositoryToken(PartnerEntity),
          useValue: mockPartnerRepository,
        },
        {
          provide: getRepositoryToken(PayoutEntity),
          useValue: mockPayoutRepository,
        },
        {
          provide: getRepositoryToken(InvoiceEntity),
          useValue: mockInvoiceRepository,
        },
        {
          provide: getRepositoryToken(AffiliateEarningEntity),
          useValue: mockEarningRepository,
        },
        {
          provide: AuditService,
          useValue: mockAuditService,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
      ],
    }).compile();

    service = module.get<PayoutService>(PayoutService);
    partnerRepository = module.get<Repository<PartnerEntity>>(getRepositoryToken(PartnerEntity));
    payoutRepository = module.get<Repository<PayoutEntity>>(getRepositoryToken(PayoutEntity));
    invoiceRepository = module.get<Repository<InvoiceEntity>>(getRepositoryToken(InvoiceEntity));
    earningRepository = module.get<Repository<AffiliateEarningEntity>>(getRepositoryToken(AffiliateEarningEntity));
    auditService = module.get<AuditService>(AuditService);
    configService = module.get<ConfigService>(ConfigService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('requestPayout', () => {
    const mockPartner = {
      id: 'partner-1',
      isActive: true,
      contactInfo: { stripeAccountId: 'acct_test123' },
    };

    const mockPayout = {
      id: 'payout-1',
      partnerId: 'partner-1',
      amount: 100,
      currency: 'USD',
      status: PayoutStatus.PENDING,
      paymentMethod: 'stripe',
      createdAt: new Date(),
      updatedAt: new Date(),
    };

    beforeEach(() => {
      mockPartnerRepository.findOne.mockResolvedValue(mockPartner);
      mockPayoutRepository.create.mockReturnValue(mockPayout);
      mockPayoutRepository.save.mockResolvedValue(mockPayout);
      mockConfigService.get.mockImplementation((key, defaultValue) => {
        if (key === 'MINIMUM_PAYOUT_AMOUNT') return 50;
        return defaultValue;
      });
      mockAuditService.logPayoutAction.mockResolvedValue({});

      // Mock available earnings calculation
      const mockQueryBuilder = {
        select: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        getRawOne: jest.fn().mockResolvedValue({ total: 200 }),
      };
      mockEarningRepository.createQueryBuilder.mockReturnValue(mockQueryBuilder);
    });

    it('should request payout successfully', async () => {
      const payoutRequest = {
        amount: 100,
        currency: 'USD',
        paymentMethod: 'stripe',
      };

      const result = await service.requestPayout('partner-1', payoutRequest);

      expect(result.id).toBe('payout-1');
      expect(result.amount).toBe(100);
      expect(result.status).toBe(PayoutStatus.PENDING);
      expect(mockPayoutRepository.create).toHaveBeenCalled();
      expect(mockPayoutRepository.save).toHaveBeenCalled();
      expect(mockAuditService.logPayoutAction).toHaveBeenCalled();
    });

    it('should throw error for inactive partner', async () => {
      // Mock findOne to return null for inactive partner query
      mockPartnerRepository.findOne.mockImplementation((query) => {
        if (query.where && query.where.isActive === true) {
          return Promise.resolve(null); // No active partner found
        }
        return Promise.resolve(mockPartner);
      });

      const payoutRequest = {
        amount: 100,
        currency: 'USD',
        paymentMethod: 'stripe',
      };

      await expect(service.requestPayout('partner-1', payoutRequest)).rejects.toThrow(
        'Active partner not found: partner-1',
      );
    });

    it('should throw error for insufficient earnings', async () => {
      const mockQueryBuilder = {
        select: jest.fn().mockReturnThis(),
        where: jest.fn().mockReturnThis(),
        andWhere: jest.fn().mockReturnThis(),
        getRawOne: jest.fn().mockResolvedValue({ total: 50 }),
      };
      mockEarningRepository.createQueryBuilder.mockReturnValue(mockQueryBuilder);

      const payoutRequest = {
        amount: 100,
        currency: 'USD',
        paymentMethod: 'stripe',
      };

      await expect(service.requestPayout('partner-1', payoutRequest)).rejects.toThrow(
        'Insufficient available earnings',
      );
    });

    it('should throw error for amount below minimum', async () => {
      const payoutRequest = {
        amount: 25,
        currency: 'USD',
        paymentMethod: 'stripe',
      };

      await expect(service.requestPayout('partner-1', payoutRequest)).rejects.toThrow(
        'Minimum payout amount is 50 USD',
      );
    });

    it('should generate invoice for bank transfer', async () => {
      const mockInvoice = {
        id: 'invoice-1',
        invoiceNumber: 'INV-202501-0001',
      };
      mockInvoiceRepository.save.mockResolvedValue(mockInvoice);
      mockInvoiceRepository.count.mockResolvedValue(0);
      mockEarningRepository.find.mockResolvedValue([
        {
          id: 'earning-1',
          amountEarned: 100,
          conversionReferenceId: 'booking-123',
          transactionDate: new Date(),
        },
      ]);

      const payoutRequest = {
        amount: 100,
        currency: 'USD',
        paymentMethod: 'bank_transfer',
      };

      const result = await service.requestPayout('partner-1', payoutRequest);

      expect(mockInvoiceRepository.save).toHaveBeenCalled();
      expect(result.invoiceId).toBe('invoice-1');
    });
  });

  describe('getPayouts', () => {
    it('should return all payouts for admin', async () => {
      const mockPayouts = [
        { id: 'payout-1', partnerId: 'partner-1', amount: 100 },
        { id: 'payout-2', partnerId: 'partner-2', amount: 200 },
      ];
      mockPayoutRepository.find.mockResolvedValue(mockPayouts);

      const result = await service.getPayouts('admin-1', 'admin');

      expect(result).toHaveLength(2);
      expect(mockPayoutRepository.find).toHaveBeenCalledWith({
        order: { createdAt: 'DESC' },
        take: 100,
      });
    });

    it('should return only partner payouts for partner role', async () => {
      const mockPayouts = [
        { id: 'payout-1', partnerId: 'partner-1', amount: 100 },
      ];
      mockPayoutRepository.find.mockResolvedValue(mockPayouts);

      const result = await service.getPayouts('partner-1', 'partner');

      expect(result).toHaveLength(1);
      expect(mockPayoutRepository.find).toHaveBeenCalledWith({
        where: { partnerId: 'partner-1' },
        order: { createdAt: 'DESC' },
      });
    });
  });

  describe('generateInvoice', () => {
    const mockPartner = {
      id: 'partner-1',
      name: 'Test Partner',
    };

    const mockPayout = {
      id: 'payout-1',
      amount: 100,
      currency: 'USD',
    };

    beforeEach(() => {
      mockPartnerRepository.findOne.mockResolvedValue(mockPartner);
      mockInvoiceRepository.count.mockResolvedValue(0);
      mockEarningRepository.find.mockResolvedValue([
        {
          id: 'earning-1',
          amountEarned: 100,
          conversionReferenceId: 'booking-123',
          transactionDate: new Date(),
        },
      ]);
      mockInvoiceRepository.create.mockReturnValue({
        id: 'invoice-1',
        invoiceNumber: 'INV-202501-0001',
      });
      mockInvoiceRepository.save.mockResolvedValue({
        id: 'invoice-1',
        invoiceNumber: 'INV-202501-0001',
      });
      mockAuditService.logAction.mockResolvedValue({});
    });

    it('should generate invoice with correct line items', async () => {
      // Access private method through service instance
      const generateInvoice = (service as any).generateInvoice.bind(service);
      
      const result = await generateInvoice('partner-1', mockPayout);

      expect(result.id).toBe('invoice-1');
      expect(mockInvoiceRepository.create).toHaveBeenCalledWith(
        expect.objectContaining({
          partnerId: 'partner-1',
          invoiceNumber: expect.stringContaining('INV-'),
          amountDue: 100,
          currency: 'USD',
          lineItems: expect.arrayContaining([
            expect.objectContaining({
              description: expect.stringContaining('Commission for booking'),
              totalPrice: 100,
            }),
          ]),
        }),
      );
    });

    it('should generate unique invoice number', async () => {
      const generateInvoiceNumber = (service as any).generateInvoiceNumber.bind(service);
      
      const invoiceNumber = await generateInvoiceNumber();

      expect(invoiceNumber).toMatch(/^INV-\d{6}-\d{4}$/);
    });
  });
});
