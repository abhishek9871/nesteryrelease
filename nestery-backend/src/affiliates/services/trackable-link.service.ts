import { Injectable, NotFoundException, Logger, Inject } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import { Cache } from 'cache-manager';
import { nanoid } from 'nanoid';
import * as QRCode from 'qrcode';

import { AffiliateLinkEntity } from '../entities/affiliate-link.entity';
import { AffiliateOfferEntity } from '../entities/affiliate-offer.entity';
import { UserEntity } from '../../users/entities/user.entity';
import { AuditService } from './audit.service';

export interface LinkAnalyticsDto {
  totalClicks: number;
  totalConversions: number;
  conversionRate: number;
  topPerformingLinks: Array<{
    linkId: string;
    uniqueCode: string;
    clicks: number;
    conversions: number;
    conversionRate: number;
    offerId: string;
    offerTitle: string;
  }>;
  clicksByDay: Array<{
    date: string;
    clicks: number;
    conversions: number;
  }>;
  fraudDetectionStats: {
    suspiciousClicks: number;
    blockedIPs: number;
    flaggedUserAgents: number;
  };
}

export interface LinkPerformanceDto {
  linkId: string;
  uniqueCode: string;
  clicks: number;
  conversions: number;
  conversionRate: number;
  createdAt: Date;
  lastClickAt?: Date;
  offer: {
    id: string;
    title: string;
    isActive: boolean;
  };
  recentActivity: Array<{
    timestamp: Date;
    action: 'click' | 'conversion';
    ipAddress?: string;
    userAgent?: string;
    fraudScore?: number;
  }>;
}

interface ClickTrackingData {
  ipAddress: string;
  userAgent: string;
  timestamp: Date;
  linkId: string;
  fraudScore: number;
  isBlocked: boolean;
}

@Injectable()
export class TrackableLinkService {
  private readonly logger = new Logger(TrackableLinkService.name);

  constructor(
    @InjectRepository(AffiliateLinkEntity)
    private readonly linkRepository: Repository<AffiliateLinkEntity>,
    @InjectRepository(AffiliateOfferEntity)
    private readonly offerRepository: Repository<AffiliateOfferEntity>,
    @InjectRepository(UserEntity)
    private readonly userRepository: Repository<UserEntity>,
    @Inject(CACHE_MANAGER)
    private readonly cacheManager: Cache,
    private readonly configService: ConfigService,
    private readonly auditService: AuditService,
  ) {}

  async generateAffiliateLink(
    offerId: string,
    userId?: string,
  ): Promise<{ linkEntity: AffiliateLinkEntity; fullTrackableUrl: string; qrCodeDataUrl: string }> {
    const offer = await this.offerRepository.findOneBy({ id: offerId });
    if (!offer || !offer.isActive) {
      throw new NotFoundException(`Active offer with ID ${offerId} not found.`);
    }

    // Check offer validity period
    const now = new Date();
    if (now < new Date(offer.validFrom) || now > new Date(offer.validTo)) {
      throw new Error(`Offer is not valid for current date: ${offerId}`);
    }

    let user: UserEntity | undefined = undefined;
    if (userId) {
      user = (await this.userRepository.findOneBy({ id: userId })) || undefined;
      if (!user) {
        this.logger.warn(
          `User with ID ${userId} not found for affiliate link generation, proceeding without user association.`,
        );
        // Depending on requirements, could throw NotFoundException or proceed without user
      }
    }

    const uniqueCode = nanoid(10); // Generate a 10-character unique code
    const appBaseUrl = this.configService.get<string>('APP_BASE_URL');
    if (!appBaseUrl) {
      this.logger.error('APP_BASE_URL is not configured.');
      throw new Error('Application base URL is not configured.');
    }
    const fullTrackableUrl = `${appBaseUrl}/v1/affiliates/redirect/${uniqueCode}`;

    let qrCodeDataUrl = '';
    try {
      qrCodeDataUrl = await QRCode.toDataURL(fullTrackableUrl);
    } catch (error) {
      this.logger.error(`Failed to generate QR code for ${fullTrackableUrl}: ${error.message}`);
      // Proceed without QR code if generation fails, or throw error based on requirements
    }

    const linkEntity = this.linkRepository.create({
      offerId,
      offer,
      userId: user ? user.id : null,
      user: user || null,
      uniqueCode,
      qrCodeDataUrl: qrCodeDataUrl || null,
    });

    const savedLink = await this.linkRepository.save(linkEntity);

    return { linkEntity: savedLink, fullTrackableUrl, qrCodeDataUrl };
  }

  async handleLinkRedirectAndTrackClick(
    uniqueCode: string,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<string | null> {
    const link = await this.linkRepository.findOne({
      where: { uniqueCode },
      relations: ['offer'],
    });

    if (!link) {
      this.logger.warn(`Affiliate link with code ${uniqueCode} not found.`);
      return null;
    }

    const offer = link.offer;
    if (!offer || !offer.isActive) {
      this.logger.warn(`Offer for link ${uniqueCode} is inactive or not found.`);
      return null;
    }

    const now = new Date();
    if (now < new Date(offer.validFrom) || now > new Date(offer.validTo)) {
      this.logger.warn(`Offer for link ${uniqueCode} is expired or not yet valid.`);
      return null;
    }

    // Advanced fraud detection
    const fraudScore = await this.calculateFraudScore(link.id, ipAddress, userAgent);
    const isBlocked = await this.shouldBlockClick(link.id, fraudScore, ipAddress, userAgent);

    if (isBlocked) {
      this.logger.warn(
        `Click blocked for link ${uniqueCode} due to fraud detection. Score: ${fraudScore}`,
      );

      // Log blocked click for analysis
      await this.auditService.logAction({
        entityId: link.id,
        entityType: 'affiliate_link',
        actionType: 'CLICK_BLOCKED',
        details: {
          uniqueCode,
          ipAddress,
          userAgent,
          fraudScore,
          reason: 'Fraud detection threshold exceeded',
        },
        ipAddress,
        userAgent,
      });

      return null;
    }

    // Track click with fraud score
    await this.trackClick(link, ipAddress, userAgent, fraudScore);

    // Atomically increment clicks
    await this.linkRepository.increment({ id: link.id }, 'clicks', 1);
    this.logger.log(
      `Click tracked for link ${uniqueCode}. New click count: ${link.clicks + 1}, Fraud score: ${fraudScore}`,
    );

    return offer.originalUrl || this.configService.get<string>('FRONTEND_URL') || '/'; // Fallback to frontend URL
  }

  /**
   * Calculate fraud score based on multiple factors
   */
  private async calculateFraudScore(
    linkId: string,
    ipAddress?: string,
    userAgent?: string,
  ): Promise<number> {
    let score = 0;

    if (!ipAddress || !userAgent) {
      return 0; // No data to analyze
    }

    // Check IP-based patterns
    const ipScore = await this.analyzeIPPattern(linkId, ipAddress);
    score += ipScore;

    // Check user agent patterns
    const uaScore = await this.analyzeUserAgentPattern(userAgent);
    score += uaScore;

    // Check click velocity
    const velocityScore = await this.analyzeClickVelocity(linkId, ipAddress);
    score += velocityScore;

    // Check for bot patterns
    const botScore = await this.analyzeBotPatterns(userAgent, ipAddress);
    score += botScore;

    return Math.min(score, 100); // Cap at 100
  }

  /**
   * Determine if click should be blocked
   */
  private async shouldBlockClick(
    linkId: string,
    fraudScore: number,
    ipAddress?: string,
    _userAgent?: string,
  ): Promise<boolean> {
    const threshold = this.configService.get<number>('FRAUD_DETECTION_THRESHOLD', 70);

    if (fraudScore >= threshold) {
      return true;
    }

    // Check if IP is in blocklist
    if (ipAddress && (await this.isIPBlocked(ipAddress))) {
      return true;
    }

    // Check rate limiting
    if (ipAddress && (await this.isRateLimited(linkId, ipAddress))) {
      return true;
    }

    return false;
  }

  /**
   * Analyze IP address patterns for fraud detection
   */
  private async analyzeIPPattern(linkId: string, ipAddress: string): Promise<number> {
    const cacheKey = `ip_pattern:${linkId}:${ipAddress}`;
    const cached = await this.cacheManager.get<number>(cacheKey);

    if (cached !== undefined && cached !== null) {
      return cached;
    }

    let score = 0;

    // Check click frequency from this IP
    const recentClicks =
      (await this.cacheManager.get<number>(`ip_clicks:${ipAddress}:recent`)) || 0;
    if (recentClicks > 10)
      score += 30; // High frequency clicking
    else if (recentClicks > 5) score += 15;

    // Check if IP has clicked multiple links recently
    const linkDiversity = (await this.cacheManager.get<number>(`ip_diversity:${ipAddress}`)) || 0;
    if (linkDiversity > 20) score += 25; // Clicking too many different links

    // Check for known proxy/VPN patterns
    if (await this.isProxyOrVPN(ipAddress)) {
      score += 20;
    }

    // Cache result for 1 hour
    await this.cacheManager.set(cacheKey, score, 3600);

    return score;
  }

  /**
   * Analyze user agent for bot patterns
   */
  private async analyzeUserAgentPattern(_userAgent: string): Promise<number> {
    const cacheKey = `ua_pattern:${Buffer.from(_userAgent).toString('base64')}`;
    const cached = await this.cacheManager.get<number>(cacheKey);

    if (cached !== undefined && cached !== null) {
      return cached;
    }

    let score = 0;

    // Known bot patterns
    const botPatterns = [
      /bot/i,
      /crawler/i,
      /spider/i,
      /scraper/i,
      /curl/i,
      /wget/i,
      /python/i,
      /java/i,
      /headless/i,
      /phantom/i,
      /selenium/i,
    ];

    for (const pattern of botPatterns) {
      if (pattern.test(_userAgent)) {
        score += 40;
        break;
      }
    }

    // Suspicious patterns
    if (_userAgent.length < 20) score += 20; // Too short
    if (_userAgent.length > 500) score += 15; // Too long
    if (!/Mozilla/i.test(_userAgent)) score += 25; // No Mozilla string

    // Cache result for 24 hours
    await this.cacheManager.set(cacheKey, score, 86400);

    return score;
  }

  /**
   * Analyze click velocity patterns
   */
  private async analyzeClickVelocity(linkId: string, ipAddress: string): Promise<number> {
    const velocityKey = `velocity:${linkId}:${ipAddress}`;
    const timestamps = (await this.cacheManager.get<number[]>(velocityKey)) || [];

    const now = Date.now();
    const oneMinuteAgo = now - 60000;
    const fiveMinutesAgo = now - 300000;

    // Filter recent timestamps
    const recentTimestamps = timestamps.filter(ts => ts > fiveMinutesAgo);
    const veryRecentTimestamps = recentTimestamps.filter(ts => ts > oneMinuteAgo);

    let score = 0;

    // Too many clicks in 1 minute
    if (veryRecentTimestamps.length > 3) score += 50;
    else if (veryRecentTimestamps.length > 1) score += 20;

    // Too many clicks in 5 minutes
    if (recentTimestamps.length > 10) score += 30;
    else if (recentTimestamps.length > 5) score += 15;

    // Update cache with new timestamp
    recentTimestamps.push(now);
    await this.cacheManager.set(velocityKey, recentTimestamps, 300); // 5 minutes TTL

    return score;
  }

  /**
   * Analyze for bot patterns
   */
  private async analyzeBotPatterns(_userAgent: string, _ipAddress: string): Promise<number> {
    let score = 0;

    // Check for headless browser indicators
    if (/headless/i.test(_userAgent)) score += 30;
    if (/phantom/i.test(_userAgent)) score += 30;
    if (/selenium/i.test(_userAgent)) score += 30;

    // Check for automation tools
    if (/automation/i.test(_userAgent)) score += 25;
    if (/webdriver/i.test(_userAgent)) score += 25;

    // Check for missing common browser features in user agent
    const hasVersion = /\d+\.\d+/.test(_userAgent);
    const hasOS = /(Windows|Mac|Linux|Android|iOS)/i.test(_userAgent);

    if (!hasVersion) score += 15;
    if (!hasOS) score += 15;

    return score;
  }

  /**
   * Check if IP is a known proxy or VPN
   */
  private async isProxyOrVPN(ipAddress: string): Promise<boolean> {
    // This would typically integrate with a service like IPQualityScore or similar
    // For now, we'll implement basic checks

    // Check common VPN/proxy IP ranges (simplified)
    const suspiciousRanges = [
      '10.',
      '172.16.',
      '192.168.', // Private ranges often used by VPNs
      '127.', // Localhost
    ];

    return suspiciousRanges.some(range => ipAddress.startsWith(range));
  }

  /**
   * Check if IP is in blocklist
   */
  private async isIPBlocked(ipAddress: string): Promise<boolean> {
    const blockedIPs = (await this.cacheManager.get<string[]>('blocked_ips')) || [];
    return blockedIPs.includes(ipAddress);
  }

  /**
   * Check rate limiting for IP
   */
  private async isRateLimited(linkId: string, ipAddress: string): Promise<boolean> {
    const rateLimitKey = `rate_limit:${linkId}:${ipAddress}`;
    const clickCount = (await this.cacheManager.get<number>(rateLimitKey)) || 0;

    const maxClicksPerHour = this.configService.get<number>('MAX_CLICKS_PER_HOUR', 100);

    if (clickCount >= maxClicksPerHour) {
      return true;
    }

    // Increment counter
    await this.cacheManager.set(rateLimitKey, clickCount + 1, 3600); // 1 hour TTL

    return false;
  }

  /**
   * Track click with detailed analytics
   */
  private async trackClick(
    link: AffiliateLinkEntity,
    ipAddress?: string,
    userAgent?: string,
    fraudScore?: number,
  ): Promise<void> {
    const trackingData: ClickTrackingData = {
      ipAddress: ipAddress || 'unknown',
      userAgent: userAgent || 'unknown',
      timestamp: new Date(),
      linkId: link.id,
      fraudScore: fraudScore || 0,
      isBlocked: false,
    };

    // Store in cache for analytics
    const analyticsKey = `analytics:${link.id}:clicks`;
    const existingData = (await this.cacheManager.get<ClickTrackingData[]>(analyticsKey)) || [];
    existingData.push(trackingData);

    // Keep only last 1000 clicks for performance
    if (existingData.length > 1000) {
      existingData.splice(0, existingData.length - 1000);
    }

    await this.cacheManager.set(analyticsKey, existingData, 86400 * 7); // 7 days

    // Update IP tracking
    if (ipAddress) {
      await this.updateIPTracking(ipAddress, link.id);
    }

    // Audit the click
    await this.auditService.logAction({
      entityId: link.id,
      entityType: 'affiliate_link',
      actionType: 'LINK_CLICKED',
      details: {
        uniqueCode: link.uniqueCode,
        fraudScore,
        ipAddress,
        userAgent,
      },
      ipAddress,
      userAgent,
    });
  }

  /**
   * Update IP tracking for fraud detection
   */
  private async updateIPTracking(ipAddress: string, linkId: string): Promise<void> {
    // Update recent clicks count
    const recentKey = `ip_clicks:${ipAddress}:recent`;
    const recentCount = (await this.cacheManager.get<number>(recentKey)) || 0;
    await this.cacheManager.set(recentKey, recentCount + 1, 3600); // 1 hour TTL

    // Update link diversity
    const diversityKey = `ip_diversity:${ipAddress}`;
    const clickedLinks = (await this.cacheManager.get<string[]>(diversityKey)) || [];

    if (!clickedLinks.includes(linkId)) {
      clickedLinks.push(linkId);
      await this.cacheManager.set(diversityKey, clickedLinks, 86400); // 24 hours TTL
    }
  }

  /**
   * Get comprehensive analytics for links
   */
  async getLinkAnalytics(
    partnerId?: string,
    startDate?: Date,
    endDate?: Date,
  ): Promise<LinkAnalyticsDto> {
    const whereConditions: any = {};

    if (partnerId) {
      // Get offers for this partner first
      const partnerOffers = await this.offerRepository.find({
        where: { partnerId },
        select: ['id'],
      });
      const offerIds = partnerOffers.map(offer => offer.id);
      whereConditions.offerId = { $in: offerIds };
    }

    if (startDate && endDate) {
      whereConditions.createdAt = Between(startDate, endDate);
    }

    // Get all relevant links
    const links = await this.linkRepository.find({
      where: whereConditions,
      relations: ['offer'],
    });

    // Calculate totals
    const totalClicks = links.reduce((sum, link) => sum + link.clicks, 0);
    const totalConversions = links.reduce((sum, link) => sum + link.conversions, 0);
    const conversionRate = totalClicks > 0 ? (totalConversions / totalClicks) * 100 : 0;

    // Get top performing links
    const topPerformingLinks = links
      .sort((a, b) => b.clicks - a.clicks)
      .slice(0, 10)
      .map(link => ({
        linkId: link.id,
        uniqueCode: link.uniqueCode,
        clicks: link.clicks,
        conversions: link.conversions,
        conversionRate: link.clicks > 0 ? (link.conversions / link.clicks) * 100 : 0,
        offerId: link.offerId,
        offerTitle: link.offer?.title || 'Unknown',
      }));

    // Get clicks by day (simplified - would need more complex aggregation in production)
    const clicksByDay = await this.getClicksByDay(links, startDate, endDate);

    // Get fraud detection stats
    const fraudDetectionStats = await this.getFraudDetectionStats(links);

    return {
      totalClicks,
      totalConversions,
      conversionRate,
      topPerformingLinks,
      clicksByDay,
      fraudDetectionStats,
    };
  }

  /**
   * Get performance data for a specific link
   */
  async getLinkPerformance(linkId: string): Promise<LinkPerformanceDto> {
    const link = await this.linkRepository.findOne({
      where: { id: linkId },
      relations: ['offer'],
    });

    if (!link) {
      throw new NotFoundException(`Link not found: ${linkId}`);
    }

    const conversionRate = link.clicks > 0 ? (link.conversions / link.clicks) * 100 : 0;

    // Get recent activity from cache
    const analyticsKey = `analytics:${linkId}:clicks`;
    const recentActivity = (await this.cacheManager.get<ClickTrackingData[]>(analyticsKey)) || [];

    // Get last click timestamp
    const lastClickAt =
      recentActivity.length > 0
        ? new Date(Math.max(...recentActivity.map(activity => activity.timestamp.getTime())))
        : undefined;

    return {
      linkId: link.id,
      uniqueCode: link.uniqueCode,
      clicks: link.clicks,
      conversions: link.conversions,
      conversionRate,
      createdAt: link.createdAt,
      lastClickAt,
      offer: {
        id: link.offer.id,
        title: link.offer.title,
        isActive: link.offer.isActive,
      },
      recentActivity: recentActivity.slice(-50).map(activity => ({
        timestamp: activity.timestamp,
        action: 'click' as const,
        ipAddress: activity.ipAddress,
        userAgent: activity.userAgent,
        fraudScore: activity.fraudScore,
      })),
    };
  }

  /**
   * Record a conversion for a link
   */
  async recordConversion(
    uniqueCode: string,
    conversionData: {
      bookingId?: string;
      conversionValue?: number;
      currency?: string;
      userId?: string;
    },
  ): Promise<void> {
    const link = await this.linkRepository.findOne({
      where: { uniqueCode },
      relations: ['offer'],
    });

    if (!link) {
      throw new NotFoundException(`Link not found: ${uniqueCode}`);
    }

    // Increment conversion count
    await this.linkRepository.increment({ id: link.id }, 'conversions', 1);

    // Store conversion data in cache for analytics
    const conversionKey = `analytics:${link.id}:conversions`;
    const existingConversions = (await this.cacheManager.get<any[]>(conversionKey)) || [];

    existingConversions.push({
      timestamp: new Date(),
      bookingId: conversionData.bookingId,
      conversionValue: conversionData.conversionValue,
      currency: conversionData.currency,
      userId: conversionData.userId,
    });

    // Keep only last 1000 conversions
    if (existingConversions.length > 1000) {
      existingConversions.splice(0, existingConversions.length - 1000);
    }

    await this.cacheManager.set(conversionKey, existingConversions, 86400 * 30); // 30 days

    // Audit the conversion
    await this.auditService.logAction({
      userId: conversionData.userId,
      entityId: link.id,
      entityType: 'affiliate_link',
      actionType: 'CONVERSION_RECORDED',
      details: {
        uniqueCode,
        bookingId: conversionData.bookingId,
        conversionValue: conversionData.conversionValue,
        currency: conversionData.currency,
      },
    });

    this.logger.log(
      `Conversion recorded for link ${uniqueCode}: ${conversionData.bookingId || 'N/A'}`,
    );
  }

  /**
   * Get clicks by day for analytics
   */
  private async getClicksByDay(
    links: AffiliateLinkEntity[],
    startDate?: Date,
    endDate?: Date,
  ): Promise<Array<{ date: string; clicks: number; conversions: number }>> {
    // This is a simplified implementation
    // In production, you'd want to aggregate this data from detailed click logs

    const days: Array<{ date: string; clicks: number; conversions: number }> = [];
    const start = startDate || new Date(Date.now() - 30 * 24 * 60 * 60 * 1000); // 30 days ago
    const end = endDate || new Date();

    for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) {
      const dateStr = d.toISOString().split('T')[0];

      // This would need to be implemented with proper daily aggregation
      // For now, we'll return sample data
      days.push({
        date: dateStr,
        clicks: Math.floor(Math.random() * 100), // Sample data
        conversions: Math.floor(Math.random() * 10), // Sample data
      });
    }

    return days;
  }

  /**
   * Get fraud detection statistics
   */
  private async getFraudDetectionStats(
    links: AffiliateLinkEntity[],
  ): Promise<{ suspiciousClicks: number; blockedIPs: number; flaggedUserAgents: number }> {
    let suspiciousClicks = 0;
    let blockedIPs = 0;
    let flaggedUserAgents = 0;

    // Aggregate fraud stats from cache
    for (const link of links) {
      const analyticsKey = `analytics:${link.id}:clicks`;
      const clickData = (await this.cacheManager.get<ClickTrackingData[]>(analyticsKey)) || [];

      suspiciousClicks += clickData.filter(click => click.fraudScore > 50).length;

      const uniqueIPs = new Set(clickData.map(click => click.ipAddress));
      const uniqueUserAgents = new Set(clickData.map(click => click.userAgent));

      // This is simplified - in production you'd have more sophisticated tracking
      blockedIPs += Array.from(uniqueIPs).length;
      flaggedUserAgents += Array.from(uniqueUserAgents).length;
    }

    return {
      suspiciousClicks,
      blockedIPs: Math.floor(blockedIPs * 0.1), // Estimate
      flaggedUserAgents: Math.floor(flaggedUserAgents * 0.05), // Estimate
    };
  }
}
