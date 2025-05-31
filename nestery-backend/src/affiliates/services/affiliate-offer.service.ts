import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AffiliateOfferEntity, CommissionStructure } from '../entities/affiliate-offer.entity';
import { PartnerEntity } from '../entities/partner.entity';
import { CreateOfferDto } from '../dto/create-offer.dto';

@Injectable()
export class AffiliateOfferService {
  private readonly logger = new Logger(AffiliateOfferService.name);

  constructor(
    @InjectRepository(AffiliateOfferEntity)
    private readonly offerRepository: Repository<AffiliateOfferEntity>,
    @InjectRepository(PartnerEntity)
    private readonly partnerRepository: Repository<PartnerEntity>,
  ) {}

  async createOffer(
    partnerId: string,
    createOfferDto: CreateOfferDto,
  ): Promise<AffiliateOfferEntity> {
    const partner = await this.partnerRepository.findOneBy({ id: partnerId });
    if (!partner) {
      throw new NotFoundException(`Partner with ID ${partnerId} not found.`);
    }
    if (!partner.isActive) {
      throw new BadRequestException(`Partner ${partner.name} is not active.`);
    }

    if (new Date(createOfferDto.validFrom) >= new Date(createOfferDto.validTo)) {
      throw new BadRequestException('validFrom date must be before validTo date.');
    }

    this.validateCommissionStructure(createOfferDto.commissionStructure as CommissionStructure);

    const offer = this.offerRepository.create({
      ...createOfferDto,
      partnerId,
      partner,
    });

    return this.offerRepository.save(offer);
  }

  async getOfferById(offerId: string): Promise<AffiliateOfferEntity | null> {
    return this.offerRepository.findOne({
      where: { id: offerId },
      relations: ['partner'],
    });
  }

  private validateCommissionStructure(structure: CommissionStructure): void {
    if (!structure || !structure.type) {
      throw new BadRequestException('Commission structure type is required.');
    }

    switch (structure.type) {
      case 'percentage':
      case 'fixed':
        if (typeof structure.value !== 'number' || structure.value < 0) {
          throw new BadRequestException(`Invalid value for ${structure.type} commission.`);
        }
        if (structure.type === 'percentage' && structure.value > 100) {
          throw new BadRequestException('Percentage value cannot exceed 100.');
        }
        break;
      case 'tiered':
        if (!Array.isArray(structure.tiers) || structure.tiers.length === 0) {
          throw new BadRequestException('Tiers are required for tiered commission.');
        }
        for (const tier of structure.tiers) {
          if (typeof tier.threshold !== 'number' || tier.threshold < 0 ||
              typeof tier.value !== 'number' || tier.value < 0 ||
              !['percentage', 'fixed'].includes(tier.valueType)) {
            throw new BadRequestException('Invalid tier structure in tiered commission.');
          }
          if (tier.valueType === 'percentage' && tier.value > 100) {
            throw new BadRequestException('Tier percentage value cannot exceed 100.');
          }
        }
        break;
      default:
        throw new BadRequestException(`Unsupported commission structure type: ${structure.type}`);
    }
  }
}
