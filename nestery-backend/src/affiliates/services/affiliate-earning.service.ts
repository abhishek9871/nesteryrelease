import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AffiliateEarningEntity } from '../entities/affiliate-earning.entity';
import { AffiliateLinkEntity } from '../entities/affiliate-link.entity';
import { AffiliateOfferEntity } from '../entities/affiliate-offer.entity';
import { PartnerEntity } from '../entities/partner.entity';
import { EarningStatusEnum } from '../enums/earning-status.enum';

interface RecordConversionDetails {
  bookingId?: string;
  conversionReferenceId?: string;
  amount?: number; // Sale amount, if applicable, to calculate commission
  currency?: string;
  // Potentially other details like customer ID, product ID, etc.
}

@Injectable()
export class AffiliateEarningService {
  private readonly logger = new Logger(AffiliateEarningService.name);

  constructor(
    @InjectRepository(AffiliateEarningEntity)
    private readonly earningRepository: Repository<AffiliateEarningEntity>,
    @InjectRepository(AffiliateLinkEntity)
    private readonly linkRepository: Repository<AffiliateLinkEntity>,
    @InjectRepository(AffiliateOfferEntity)
    private readonly offerRepository: Repository<AffiliateOfferEntity>,
    @InjectRepository(PartnerEntity)
    private readonly partnerRepository: Repository<PartnerEntity>,
  ) {}

  /**
   * Records a conversion and creates an earning record.
   * This is a stub implementation for FRS 1.2.
   * Full implementation would involve commission calculation based on offer and partner settings.
   */
  async recordConversion(
    linkId: string,
    details: RecordConversionDetails,
  ): Promise<AffiliateEarningEntity> {
    this.logger.log(
      `Recording conversion for linkId: ${linkId}, details: ${JSON.stringify(details)}`,
    );

    const link = await this.linkRepository.findOne({ where: { id: linkId }, relations: ['offer', 'offer.partner'] });
    if (!link) {
      throw new NotFoundException(`Affiliate link with ID ${linkId} not found.`);
    }

    // Stub: For now, set a placeholder amount. Real calculation would be complex.
    const amountEarned = details.amount ? details.amount * 0.1 : 1.00; // Example: 10% of sale or $1
    const currency = details.currency || 'USD';

    const earning = this.earningRepository.create({
      partnerId: link.offer.partnerId,
      offerId: link.offerId,
      linkId: link.id,
      userId: link.userId, // User who owns the link
      bookingId: details.bookingId,
      conversionReferenceId: details.conversionReferenceId,
      amountEarned,
      currency,
      transactionDate: new Date(),
      status: EarningStatusEnum.PENDING,
      notes: 'Conversion recorded (stub implementation).',
    });

    return this.earningRepository.save(earning);
  }
}
