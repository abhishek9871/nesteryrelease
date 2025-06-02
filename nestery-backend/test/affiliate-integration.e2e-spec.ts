import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { AppModule } from '../src/app.module';
import { DataSource } from 'typeorm';
import { PartnerEntity, PartnerCategoryEnum } from '../src/affiliates/entities/partner.entity';
import { AffiliateOfferEntity } from '../src/affiliates/entities/affiliate-offer.entity';
import { UserEntity } from '../src/users/entities/user.entity';

describe('Affiliate System Integration (e2e)', () => {
  let app: INestApplication;
  let dataSource: DataSource;
  let partnerId: string;
  let offerId: string;
  let userId: string;
  let linkCode: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    dataSource = moduleFixture.get<DataSource>(DataSource);

    // Setup test data
    await setupTestData();
  });

  afterAll(async () => {
    // Cleanup test data
    await cleanupTestData();
    await app.close();
  });

  async function setupTestData() {
    // Create test user
    const userRepository = dataSource.getRepository(UserEntity);
    const user = userRepository.create({
      email: 'test-affiliate@example.com',
      password: 'hashedpassword',
      firstName: 'Test',
      lastName: 'User',
      role: 'USER',
    });
    const savedUser = await userRepository.save(user);
    userId = savedUser.id;

    // Create test partner
    const partnerRepository = dataSource.getRepository(PartnerEntity);
    const partner = partnerRepository.create({
      name: 'Test Partner',
      category: PartnerCategoryEnum.TOUR_OPERATOR,
      contactInfo: {
        email: 'partner@example.com',
        phone: '+1234567890',
      },
      isActive: true,
    });
    const savedPartner = await partnerRepository.save(partner);
    partnerId = savedPartner.id;

    // Create test offer
    const offerRepository = dataSource.getRepository(AffiliateOfferEntity);
    const offer = offerRepository.create({
      partnerId,
      title: 'Test Travel Package',
      description: 'Amazing travel experience',
      originalUrl: 'https://partner.com/booking',
      commissionStructure: {
        type: 'percentage',
        value: 10,
      },
      validFrom: new Date('2025-01-01'),
      validTo: new Date('2025-12-31'),
      isActive: true,
    });
    const savedOffer = await offerRepository.save(offer);
    offerId = savedOffer.id;
  }

  async function cleanupTestData() {
    if (dataSource) {
      await dataSource.query('DELETE FROM affiliate_earnings WHERE "partnerId" = $1', [partnerId]);
      await dataSource.query('DELETE FROM affiliate_links WHERE "offerId" = $1', [offerId]);
      await dataSource.query('DELETE FROM affiliate_offers WHERE id = $1', [offerId]);
      await dataSource.query('DELETE FROM affiliate_partners WHERE id = $1', [partnerId]);
      await dataSource.query('DELETE FROM users WHERE id = $1', [userId]);
    }
  }

  describe('Complete Affiliate Workflow', () => {
    it('should complete full affiliate journey', async () => {
      // Step 1: Generate affiliate link
      const linkResponse = await request(app.getHttpServer())
        .post('/v1/affiliates/links')
        .send({
          offerId,
          userId,
        })
        .expect(201);

      expect(linkResponse.body.linkEntity).toBeDefined();
      expect(linkResponse.body.fullTrackableUrl).toContain('/v1/affiliates/redirect/');
      expect(linkResponse.body.qrCodeDataUrl).toContain('data:image/png;base64,');

      linkCode = linkResponse.body.linkEntity.uniqueCode;

      // Step 2: Simulate click tracking
      const redirectResponse = await request(app.getHttpServer())
        .get(`/v1/affiliates/redirect/${linkCode}`)
        .set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
        .set('X-Forwarded-For', '192.168.1.100')
        .expect(302);

      expect(redirectResponse.headers.location).toBe('https://partner.com/booking');

      // Step 3: Record conversion
      await request(app.getHttpServer())
        .post(`/v1/affiliates/links/${linkCode}/conversion`)
        .send({
          bookingId: 'booking-123',
          conversionValue: 1000,
          currency: 'USD',
          userId,
        })
        .expect(201);

      // Step 4: Calculate commission
      const commissionResponse = await request(app.getHttpServer())
        .post('/v1/affiliates/commission/calculate')
        .send({
          partnerId,
          offerId,
          bookingValue: 1000,
          currency: 'USD',
          conversionReferenceId: 'booking-123',
          linkId: linkResponse.body.linkEntity.id,
          userId,
        })
        .expect(201);

      expect(commissionResponse.body.amountEarned).toBe('100'); // 10% of 1000
      expect(commissionResponse.body.currency).toBe('USD');
      expect(commissionResponse.body.calculationDetails.commissionType).toBe('percentage');

      // Step 5: Get analytics
      const analyticsResponse = await request(app.getHttpServer())
        .get('/v1/affiliates/analytics')
        .query({
          partnerId,
          startDate: '2025-01-01',
          endDate: '2025-12-31',
        })
        .expect(200);

      expect(analyticsResponse.body.totalClicks).toBeGreaterThan(0);
      expect(analyticsResponse.body.totalConversions).toBeGreaterThan(0);
      expect(analyticsResponse.body.topPerformingLinks).toHaveLength(1);

      // Step 6: Get link performance
      const performanceResponse = await request(app.getHttpServer())
        .get(`/v1/affiliates/links/${linkResponse.body.linkEntity.id}/performance`)
        .expect(200);

      expect(performanceResponse.body.clicks).toBeGreaterThan(0);
      expect(performanceResponse.body.conversions).toBeGreaterThan(0);
      expect(performanceResponse.body.conversionRate).toBeGreaterThan(0);
    });

    it('should handle fraud detection', async () => {
      // Generate a new link for fraud testing
      const linkResponse = await request(app.getHttpServer())
        .post('/v1/affiliates/links')
        .send({
          offerId,
          userId,
        })
        .expect(201);

      const fraudLinkCode = linkResponse.body.linkEntity.uniqueCode;

      // Simulate rapid clicking (should trigger fraud detection)
      const promises = [];
      for (let i = 0; i < 10; i++) {
        promises.push(
          request(app.getHttpServer())
            .get(`/v1/affiliates/redirect/${fraudLinkCode}`)
            .set('User-Agent', 'bot/1.0')
            .set('X-Forwarded-For', '192.168.1.100'),
        );
      }

      const responses = await Promise.all(promises);

      // Some requests should be blocked (404 or similar)
      const blockedRequests = responses.filter(res => res.status !== 302);
      expect(blockedRequests.length).toBeGreaterThan(0);
    });

    it('should handle payout workflow', async () => {
      // First, ensure there are earnings to payout
      await request(app.getHttpServer())
        .post('/v1/affiliates/commission/calculate')
        .send({
          partnerId,
          offerId,
          bookingValue: 500,
          currency: 'USD',
          conversionReferenceId: 'booking-456',
          userId,
        })
        .expect(201);

      // Request payout
      const payoutResponse = await request(app.getHttpServer())
        .post('/v1/affiliates/payouts')
        .send({
          amount: 50,
          currency: 'USD',
          paymentMethod: 'stripe',
        })
        .set('Authorization', `Bearer partner-${partnerId}`)
        .expect(201);

      expect(payoutResponse.body.id).toBeDefined();
      expect(payoutResponse.body.amount).toBe(50);
      expect(payoutResponse.body.status).toBe('PENDING');

      // Get payouts
      const payoutsResponse = await request(app.getHttpServer())
        .get('/v1/affiliates/payouts')
        .set('Authorization', `Bearer partner-${partnerId}`)
        .expect(200);

      expect(payoutsResponse.body).toHaveLength(1);
      expect(payoutsResponse.body[0].id).toBe(payoutResponse.body.id);
    });
  });

  describe('Error Handling', () => {
    it('should handle invalid offer ID', async () => {
      await request(app.getHttpServer())
        .post('/v1/affiliates/links')
        .send({
          offerId: 'invalid-offer-id',
          userId,
        })
        .expect(404);
    });

    it('should handle invalid link code', async () => {
      await request(app.getHttpServer()).get('/v1/affiliates/redirect/invalid-code').expect(404);
    });

    it('should handle insufficient earnings for payout', async () => {
      await request(app.getHttpServer())
        .post('/v1/affiliates/payouts')
        .send({
          amount: 10000, // More than available earnings
          currency: 'USD',
          paymentMethod: 'stripe',
        })
        .set('Authorization', `Bearer partner-${partnerId}`)
        .expect(400);
    });
  });

  describe('Performance Requirements', () => {
    it('should handle concurrent link generation', async () => {
      const startTime = Date.now();

      const promises = [];
      for (let i = 0; i < 50; i++) {
        promises.push(
          request(app.getHttpServer()).post('/v1/affiliates/links').send({
            offerId,
            userId,
          }),
        );
      }

      const responses = await Promise.all(promises);
      const endTime = Date.now();

      // All requests should succeed
      responses.forEach(response => {
        expect(response.status).toBe(201);
      });

      // Should complete within reasonable time (adjust based on requirements)
      expect(endTime - startTime).toBeLessThan(5000); // 5 seconds
    });

    it('should handle high-volume click tracking', async () => {
      // Generate link for testing
      const linkResponse = await request(app.getHttpServer())
        .post('/v1/affiliates/links')
        .send({
          offerId,
          userId,
        })
        .expect(201);

      const testLinkCode = linkResponse.body.linkEntity.uniqueCode;
      const startTime = Date.now();

      const promises = [];
      for (let i = 0; i < 100; i++) {
        promises.push(
          request(app.getHttpServer())
            .get(`/v1/affiliates/redirect/${testLinkCode}`)
            .set('User-Agent', `Mozilla/5.0 Test-${i}`)
            .set('X-Forwarded-For', `192.168.1.${i % 255}`),
        );
      }

      const responses = await Promise.all(promises);
      const endTime = Date.now();

      // Most requests should succeed (some may be blocked by fraud detection)
      const successfulRequests = responses.filter(res => res.status === 302);
      expect(successfulRequests.length).toBeGreaterThan(50);

      // Should complete within reasonable time
      expect(endTime - startTime).toBeLessThan(10000); // 10 seconds
    });
  });
});
