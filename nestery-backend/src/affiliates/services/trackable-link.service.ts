import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { nanoid } from 'nanoid';
import * as QRCode from 'qrcode';

import { AffiliateLinkEntity } from '../entities/affiliate-link.entity';
import { AffiliateOfferEntity } from '../entities/affiliate-offer.entity';
import { UserEntity } from '../../users/entities/user.entity';

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
    private readonly configService: ConfigService,
  ) {}

  async generateAffiliateLink(
    offerId: string,
    userId?: string,
  ): Promise<{ linkEntity: AffiliateLinkEntity; fullTrackableUrl: string; qrCodeDataUrl: string }> {
    const offer = await this.offerRepository.findOneBy({ id: offerId });
    if (!offer || !offer.isActive) {
      throw new NotFoundException(`Active offer with ID ${offerId} not found.`);
    }

    let user: UserEntity | undefined = undefined;
    if (userId) {
      user = await this.userRepository.findOneBy({ id: userId }) || undefined;
      if (!user) {
        this.logger.warn(`User with ID ${userId} not found for affiliate link generation, proceeding without user association.`);
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

  async handleLinkRedirectAndTrackClick(uniqueCode: string): Promise<string | null> {
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

    // Atomically increment clicks
    await this.linkRepository.increment({ id: link.id }, 'clicks', 1);
    this.logger.log(`Click tracked for link ${uniqueCode}. New click count: ${link.clicks + 1}`);

    return offer.originalUrl || this.configService.get<string>('FRONTEND_URL') || '/'; // Fallback to frontend URL
  }
}
