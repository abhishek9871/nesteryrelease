import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { TrackableLinkService } from './trackable-link.service';
import { AffiliateLinkEntity } from '../entities/affiliate-link.entity';
import { AffiliateOfferEntity } from '../entities/affiliate-offer.entity';
import { UserEntity } from '../../users/entities/user.entity';
import { AuditService } from './audit.service';

// Mock nanoid
jest.mock('nanoid', () => ({
  nanoid: jest.fn(() => 'abc123def456'),
}));

// Mock QRCode
jest.mock('qrcode', () => ({
  toDataURL: jest.fn(() => Promise.resolve('data:image/png;base64,test')),
}));

describe('TrackableLinkService', () => {
  let service: TrackableLinkService;

  const mockLinkRepository = {
    findOne: jest.fn(),
    find: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    increment: jest.fn(),
  };

  const mockOfferRepository = {
    findOne: jest.fn(),
    findOneBy: jest.fn(),
    find: jest.fn(),
  };

  const mockUserRepository = {
    findOneBy: jest.fn(),
  };

  const mockCacheManager = {
    get: jest.fn(),
    set: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn(),
  };

  const mockAuditService = {
    logAction: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        TrackableLinkService,
        {
          provide: getRepositoryToken(AffiliateLinkEntity),
          useValue: mockLinkRepository,
        },
        {
          provide: getRepositoryToken(AffiliateOfferEntity),
          useValue: mockOfferRepository,
        },
        {
          provide: getRepositoryToken(UserEntity),
          useValue: mockUserRepository,
        },
        {
          provide: CACHE_MANAGER,
          useValue: mockCacheManager,
        },
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
        {
          provide: AuditService,
          useValue: mockAuditService,
        },
      ],
    }).compile();

    service = module.get<TrackableLinkService>(TrackableLinkService);

    // Set up default config mocks to prevent configuration errors
    mockConfigService.get.mockImplementation((key: string, defaultValue?: any) => {
      switch (key) {
        case 'APP_BASE_URL':
          return 'https://api.nestery.com';
        case 'FRAUD_DETECTION_THRESHOLD':
          return 70;
        case 'MAX_CLICKS_PER_HOUR':
          return 100;
        default:
          return defaultValue;
      }
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('generateAffiliateLink', () => {
    const mockOffer = {
      id: 'offer-1',
      isActive: true,
      validFrom: new Date('2025-01-01'),
      validTo: new Date('2025-12-31'),
      partner: { id: 'partner-1' },
    };

    const mockUser = {
      id: 'user-1',
      email: 'test@example.com',
    };

    beforeEach(() => {
      mockOfferRepository.findOneBy.mockResolvedValue(mockOffer);
      mockUserRepository.findOneBy.mockResolvedValue(mockUser);
      mockLinkRepository.findOne.mockResolvedValue(null); // No collision
      mockLinkRepository.create.mockReturnValue({
        id: 'link-1',
        uniqueCode: 'abc123def456',
        qrCodeDataUrl: 'data:image/png;base64,test',
      });
      mockLinkRepository.save.mockResolvedValue({
        id: 'link-1',
        uniqueCode: 'abc123def456',
        qrCodeDataUrl: 'data:image/png;base64,test',
      });
      mockConfigService.get.mockImplementation(key => {
        if (key === 'APP_BASE_URL') return 'https://api.nestery.com';
        return undefined;
      });
      mockAuditService.logAction.mockResolvedValue({});
    });

    it('should generate affiliate link successfully', async () => {
      const result = await service.generateAffiliateLink('offer-1', 'user-1');

      expect(result.linkEntity.id).toBe('link-1');
      expect(result.fullTrackableUrl).toContain('https://api.nestery.com/v1/affiliates/redirect/');
      expect(result.qrCodeDataUrl).toContain('data:image/png;base64,');
      expect(mockLinkRepository.save).toHaveBeenCalled();
    });

    it('should throw error for inactive offer', async () => {
      const inactiveOffer = { ...mockOffer, isActive: false };
      mockOfferRepository.findOneBy.mockResolvedValue(inactiveOffer);

      await expect(service.generateAffiliateLink('offer-1', 'user-1')).rejects.toThrow(
        'Active offer with ID offer-1 not found',
      );
    });

    it('should throw error for expired offer', async () => {
      const expiredOffer = {
        ...mockOffer,
        validTo: new Date('2024-12-31'),
      };
      // Reset all mocks and set up specific mock for this test
      jest.clearAllMocks();
      mockOfferRepository.findOneBy.mockResolvedValue(expiredOffer);
      mockUserRepository.findOneBy.mockResolvedValue(mockUser);
      mockConfigService.get.mockImplementation(key => {
        if (key === 'APP_BASE_URL') return 'https://api.nestery.com';
        return undefined;
      });

      await expect(service.generateAffiliateLink('offer-1', 'user-1')).rejects.toThrow(
        'Offer is not valid for current date',
      );
    });

    it('should work without user association', async () => {
      const result = await service.generateAffiliateLink('offer-1');

      expect(result.linkEntity.id).toBe('link-1');
      expect(mockLinkRepository.save).toHaveBeenCalled();
    });

    it('should handle missing APP_BASE_URL configuration', async () => {
      mockConfigService.get.mockReturnValue(undefined);

      await expect(service.generateAffiliateLink('offer-1')).rejects.toThrow(
        'Application base URL is not configured',
      );
    });
  });

  describe('handleLinkRedirectAndTrackClick', () => {
    const mockLink = {
      id: 'link-1',
      uniqueCode: 'abc123def456',
      clicks: 5,
      offer: {
        id: 'offer-1',
        isActive: true,
        validFrom: new Date('2025-01-01'),
        validTo: new Date('2025-12-31'),
        originalUrl: 'https://partner.com/booking',
      },
    };

    beforeEach(() => {
      mockLinkRepository.findOne.mockResolvedValue(mockLink);
      mockLinkRepository.increment.mockResolvedValue({});
      mockConfigService.get.mockImplementation((key, defaultValue) => {
        if (key === 'FRAUD_DETECTION_THRESHOLD') return 70;
        if (key === 'MAX_CLICKS_PER_HOUR') return 100;
        return defaultValue;
      });
      mockCacheManager.get.mockResolvedValue(0); // No cached fraud data
      mockCacheManager.set.mockResolvedValue(undefined);
      mockAuditService.logAction.mockResolvedValue({});
    });

    it('should handle redirect and track click successfully', async () => {
      const result = await service.handleLinkRedirectAndTrackClick(
        'abc123def456',
        '192.168.1.1',
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
      );

      expect(result).toBe('https://partner.com/booking');
      expect(mockLinkRepository.increment).toHaveBeenCalledWith({ id: 'link-1' }, 'clicks', 1);
    });

    it('should return null for non-existent link', async () => {
      mockLinkRepository.findOne.mockResolvedValue(null);

      const result = await service.handleLinkRedirectAndTrackClick('invalid-code');

      expect(result).toBeNull();
    });

    it('should return null for inactive offer', async () => {
      const linkWithInactiveOffer = {
        ...mockLink,
        offer: { ...mockLink.offer, isActive: false },
      };
      mockLinkRepository.findOne.mockResolvedValue(linkWithInactiveOffer);

      const result = await service.handleLinkRedirectAndTrackClick('abc123def456');

      expect(result).toBeNull();
    });

    it('should return null for expired offer', async () => {
      const linkWithExpiredOffer = {
        ...mockLink,
        offer: {
          ...mockLink.offer,
          validTo: new Date('2024-12-31'),
        },
      };
      mockLinkRepository.findOne.mockResolvedValue(linkWithExpiredOffer);

      const result = await service.handleLinkRedirectAndTrackClick('abc123def456');

      expect(result).toBeNull();
    });

    it('should block suspicious clicks', async () => {
      // Mock high fraud score conditions
      mockCacheManager.get.mockImplementation(key => {
        if (key.includes('ip_clicks')) return Promise.resolve(15); // Very high click frequency (>10 triggers +30)
        if (key.includes('ip_diversity')) return Promise.resolve(25); // High diversity (>20 triggers +25)
        if (key.includes('velocity'))
          return Promise.resolve([
            Date.now() - 30000,
            Date.now() - 20000,
            Date.now() - 10000,
            Date.now() - 5000,
          ]); // 4 clicks in 5 minutes (>3 triggers +50)
        if (key.includes('ua_pattern')) return Promise.resolve(40); // Bot pattern detected
        if (key.includes('ip_pattern')) return Promise.resolve(55); // High IP pattern score
        return Promise.resolve(0);
      });

      // Mock config to return low threshold for testing
      mockConfigService.get.mockImplementation((key, defaultValue) => {
        if (key === 'FRAUD_DETECTION_THRESHOLD') return 50; // Lower threshold
        if (key === 'APP_BASE_URL') return 'https://api.nestery.com';
        return defaultValue;
      });

      const result = await service.handleLinkRedirectAndTrackClick(
        'abc123def456',
        '192.168.1.1',
        'curl/7.68.0', // Bot user agent
      );

      expect(result).toBeNull();
      expect(mockAuditService.logAction).toHaveBeenCalledWith(
        expect.objectContaining({
          actionType: 'CLICK_BLOCKED',
        }),
      );
    });
  });

  describe('recordConversion', () => {
    const mockLink = {
      id: 'link-1',
      uniqueCode: 'abc123def456',
      conversions: 2,
      offer: {
        id: 'offer-1',
        title: 'Test Offer',
      },
    };

    beforeEach(() => {
      mockLinkRepository.findOne.mockResolvedValue(mockLink);
      mockLinkRepository.increment.mockResolvedValue({});
      mockCacheManager.get.mockResolvedValue([]);
      mockCacheManager.set.mockResolvedValue(undefined);
      mockAuditService.logAction.mockResolvedValue({});
    });

    it('should record conversion successfully', async () => {
      const conversionData = {
        bookingId: 'booking-123',
        conversionValue: 1000,
        currency: 'USD',
        userId: 'user-1',
      };

      await service.recordConversion('abc123def456', conversionData);

      expect(mockLinkRepository.increment).toHaveBeenCalledWith({ id: 'link-1' }, 'conversions', 1);
      expect(mockCacheManager.set).toHaveBeenCalled();
      expect(mockAuditService.logAction).toHaveBeenCalledWith(
        expect.objectContaining({
          actionType: 'CONVERSION_RECORDED',
          details: expect.objectContaining({
            uniqueCode: 'abc123def456',
            bookingId: 'booking-123',
          }),
        }),
      );
    });

    it('should throw error for non-existent link', async () => {
      mockLinkRepository.findOne.mockResolvedValue(null);

      await expect(
        service.recordConversion('invalid-code', { bookingId: 'booking-123' }),
      ).rejects.toThrow('Link not found');
    });
  });

  describe('fraud detection', () => {
    beforeEach(() => {
      mockConfigService.get.mockImplementation((key, defaultValue) => {
        if (key === 'FRAUD_DETECTION_THRESHOLD') return 70;
        return defaultValue;
      });
    });

    it('should calculate fraud score for bot user agent', async () => {
      const calculateFraudScore = (service as any).calculateFraudScore.bind(service);
      mockCacheManager.get.mockResolvedValue(0);
      mockCacheManager.set.mockResolvedValue(undefined);

      const score = await calculateFraudScore(
        'link-1',
        '192.168.1.1',
        'Googlebot/2.1 (+http://www.google.com/bot.html)',
      );

      expect(score).toBeGreaterThanOrEqual(15); // Should detect bot pattern
    });

    it('should calculate fraud score for high velocity clicks', async () => {
      const analyzeClickVelocity = (service as any).analyzeClickVelocity.bind(service);
      const now = Date.now();
      const recentTimestamps = [now - 30000, now - 20000, now - 10000]; // 3 clicks in last minute
      mockCacheManager.get.mockResolvedValue(recentTimestamps);
      mockCacheManager.set.mockResolvedValue(undefined);

      const score = await analyzeClickVelocity('link-1', '192.168.1.1');

      expect(score).toBeGreaterThan(0); // Should detect high velocity
    });

    it('should detect proxy/VPN IP addresses', async () => {
      const isProxyOrVPN = (service as any).isProxyOrVPN.bind(service);

      const isProxy1 = await isProxyOrVPN('10.0.0.1');
      const isProxy2 = await isProxyOrVPN('192.168.1.1');
      const isNotProxy = await isProxyOrVPN('8.8.8.8');

      expect(isProxy1).toBe(true);
      expect(isProxy2).toBe(true);
      expect(isNotProxy).toBe(false);
    });
  });

  describe('analytics', () => {
    const mockLinks = [
      {
        id: 'link-1',
        uniqueCode: 'abc123',
        clicks: 100,
        conversions: 10,
        offerId: 'offer-1',
        offer: { title: 'Test Offer 1' },
        createdAt: new Date(),
      },
      {
        id: 'link-2',
        uniqueCode: 'def456',
        clicks: 50,
        conversions: 5,
        offerId: 'offer-2',
        offer: { title: 'Test Offer 2' },
        createdAt: new Date(),
      },
    ];

    beforeEach(() => {
      mockLinkRepository.find.mockResolvedValue(mockLinks);
      mockOfferRepository.find.mockResolvedValue([{ id: 'offer-1' }, { id: 'offer-2' }]);
      mockCacheManager.get.mockResolvedValue([]);
    });

    it('should get link analytics', async () => {
      const result = await service.getLinkAnalytics('partner-1');

      expect(result.totalClicks).toBe(150);
      expect(result.totalConversions).toBe(15);
      expect(result.conversionRate).toBe(10);
      expect(result.topPerformingLinks).toHaveLength(2);
      expect(result.topPerformingLinks[0].clicks).toBe(100);
    });

    it('should get link performance for specific link', async () => {
      mockLinkRepository.findOne.mockResolvedValue(mockLinks[0]);
      mockCacheManager.get.mockResolvedValue([
        {
          timestamp: new Date(),
          ipAddress: '192.168.1.1',
          userAgent: 'Mozilla/5.0',
          fraudScore: 10,
        },
      ]);

      const result = await service.getLinkPerformance('link-1');

      expect(result.linkId).toBe('link-1');
      expect(result.clicks).toBe(100);
      expect(result.conversions).toBe(10);
      expect(result.conversionRate).toBe(10);
      expect(result.recentActivity).toHaveLength(1);
    });
  });
});
