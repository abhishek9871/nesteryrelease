import { Injectable, NotFoundException, BadRequestException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AffiliateOfferEntity, CommissionStructure } from '../entities/affiliate-offer.entity';
import { PartnerEntity, PartnerCategoryEnum } from '../entities/partner.entity';
import { CreateOfferDto } from '../dto/create-offer.dto';
import { UpdateOfferDto } from '../dto/update-offer.dto';
import {
  validateCommissionRate,
  getValidCommissionRateRange,
} from '../validators/frs-commission.validator';

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

    // FRS Section 1.2 Commission Rate Validation
    this.validateFrsCommissionCompliance(
      createOfferDto.commissionStructure as CommissionStructure,
      partner.category,
    );

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

  /**
   * Find all offers with pagination, filtering, and sorting
   */
  async findAll(
    page: number = 1,
    limit: number = 10,
    filters?: Record<string, unknown>,
  ): Promise<{ offers: AffiliateOfferEntity[]; total: number }> {
    this.logger.log(
      `Finding all offers - page: ${page}, limit: ${limit}, filters: ${JSON.stringify(filters)}`,
    );

    const queryBuilder = this.offerRepository.createQueryBuilder('offer');

    // Load partner relation
    queryBuilder.leftJoinAndSelect('offer.partner', 'partner');

    // Apply filters
    if (filters) {
      if (filters.partnerId) {
        queryBuilder.andWhere('offer.partnerId = :partnerId', { partnerId: filters.partnerId });
      }
      if (filters.isActive !== undefined) {
        queryBuilder.andWhere('offer.isActive = :isActive', { isActive: filters.isActive });
      }
      if (filters.title) {
        queryBuilder.andWhere('offer.title ILIKE :title', { title: `%${filters.title}%` });
      }
      if (filters.category) {
        queryBuilder.andWhere('partner.category = :category', { category: filters.category });
      }
      if (filters.validFrom) {
        queryBuilder.andWhere('offer.validFrom >= :validFrom', { validFrom: filters.validFrom });
      }
      if (filters.validTo) {
        queryBuilder.andWhere('offer.validTo <= :validTo', { validTo: filters.validTo });
      }
      if (filters.currentlyValid) {
        const now = new Date();
        queryBuilder.andWhere('offer.validFrom <= :now AND offer.validTo >= :now', { now });
      }
    }

    // Apply sorting (default by createdAt DESC)
    const sortField = (filters?.sortField as string) || 'createdAt';
    const sortOrder = (filters?.sortOrder as 'ASC' | 'DESC') || 'DESC';
    queryBuilder.orderBy(`offer.${sortField}`, sortOrder);

    // Apply pagination
    queryBuilder.skip((page - 1) * limit).take(limit);

    const [offers, total] = await queryBuilder.getManyAndCount();

    this.logger.log(`Found ${offers.length} offers out of ${total} total`);
    return { offers, total };
  }

  /**
   * Find all active offers with pagination
   */
  async findAllActive(
    page: number = 1,
    limit: number = 10,
  ): Promise<{ offers: AffiliateOfferEntity[]; total: number }> {
    this.logger.log(`Finding all active offers - page: ${page}, limit: ${limit}`);

    const now = new Date();
    const queryBuilder = this.offerRepository.createQueryBuilder('offer');

    queryBuilder
      .leftJoinAndSelect('offer.partner', 'partner')
      .where('offer.isActive = :isActive', { isActive: true })
      .andWhere('partner.isActive = :partnerActive', { partnerActive: true })
      .andWhere('offer.validFrom <= :now AND offer.validTo >= :now', { now })
      .orderBy('offer.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [offers, total] = await queryBuilder.getManyAndCount();

    this.logger.log(`Found ${offers.length} active offers out of ${total} total`);
    return { offers, total };
  }

  /**
   * Find offers by partner ID with pagination
   */
  async findByPartnerId(
    partnerId: string,
    page: number = 1,
    limit: number = 10,
  ): Promise<{ offers: AffiliateOfferEntity[]; total: number }> {
    this.logger.log(`Finding offers for partner ${partnerId} - page: ${page}, limit: ${limit}`);

    // Verify partner exists
    const partner = await this.partnerRepository.findOneBy({ id: partnerId });
    if (!partner) {
      throw new NotFoundException(`Partner with ID ${partnerId} not found.`);
    }

    const queryBuilder = this.offerRepository.createQueryBuilder('offer');

    queryBuilder
      .leftJoinAndSelect('offer.partner', 'partner')
      .where('offer.partnerId = :partnerId', { partnerId })
      .orderBy('offer.createdAt', 'DESC')
      .skip((page - 1) * limit)
      .take(limit);

    const [offers, total] = await queryBuilder.getManyAndCount();

    this.logger.log(`Found ${offers.length} offers for partner ${partnerId} out of ${total} total`);
    return { offers, total };
  }

  /**
   * Update an existing offer
   */
  async update(id: string, updateDto: UpdateOfferDto): Promise<AffiliateOfferEntity> {
    this.logger.log(`Updating offer ${id} with data: ${JSON.stringify(updateDto)}`);

    const offer = await this.offerRepository.findOne({
      where: { id },
      relations: ['partner'],
    });

    if (!offer) {
      throw new NotFoundException(`Offer with ID ${id} not found`);
    }

    // Validate date range if dates are being updated
    const validFrom = updateDto.validFrom ? new Date(updateDto.validFrom) : offer.validFrom;
    const validTo = updateDto.validTo ? new Date(updateDto.validTo) : offer.validTo;

    if (validFrom >= validTo) {
      throw new BadRequestException('validFrom date must be before validTo date.');
    }

    // Validate commission structure if it's being updated
    if (updateDto.commissionStructure) {
      this.validateCommissionStructure(updateDto.commissionStructure as CommissionStructure);

      // FRS Section 1.2 Commission Rate Validation
      this.validateFrsCommissionCompliance(
        updateDto.commissionStructure as CommissionStructure,
        offer.partner.category,
      );
    }

    // Update offer
    Object.assign(offer, updateDto);
    offer.updatedAt = new Date();

    const updatedOffer = await this.offerRepository.save(offer);
    this.logger.log(`Successfully updated offer ${id}`);

    return updatedOffer;
  }

  /**
   * Soft delete an offer
   */
  async delete(id: string): Promise<void> {
    this.logger.log(`Soft deleting offer: ${id}`);

    const offer = await this.offerRepository.findOneBy({ id });
    if (!offer) {
      throw new NotFoundException(`Offer with ID ${id} not found`);
    }

    // Implement soft delete by setting isActive to false
    offer.isActive = false;
    offer.updatedAt = new Date();

    await this.offerRepository.save(offer);
    this.logger.log(`Successfully soft deleted offer ${id}`);
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
          if (
            typeof tier.threshold !== 'number' ||
            tier.threshold < 0 ||
            typeof tier.value !== 'number' ||
            tier.value < 0 ||
            !['percentage', 'fixed'].includes(tier.valueType)
          ) {
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

  /**
   * Validate FRS Section 1.2 commission rate compliance
   */
  private validateFrsCommissionCompliance(
    structure: CommissionStructure,
    partnerCategory: PartnerCategoryEnum,
  ): void {
    this.logger.log(
      `Validating FRS compliance for commission structure: ${JSON.stringify(structure)}, category: ${partnerCategory}`,
    );

    const validRange = getValidCommissionRateRange(partnerCategory);
    if (!validRange) {
      throw new BadRequestException(
        `Invalid partner category for FRS validation: ${partnerCategory}`,
      );
    }

    switch (structure.type) {
      case 'percentage':
        if (structure.value === undefined || structure.value === null) {
          throw new BadRequestException('Commission percentage value is required');
        }
        const rate = structure.value / 100; // Convert percentage to decimal
        if (!validateCommissionRate(rate, partnerCategory)) {
          throw new BadRequestException(
            `Commission rate ${structure.value}% violates FRS Section 1.2 for category ${partnerCategory}. ` +
              `Valid range: ${validRange.min * 100}%-${validRange.max * 100}%`,
          );
        }
        break;

      case 'fixed':
        // For fixed commissions, we can't validate without knowing the booking value
        // This would need to be validated at calculation time
        this.logger.warn(
          `FRS validation skipped for fixed commission structure - validation occurs at calculation time`,
        );
        break;

      case 'tiered':
        // Validate each tier's commission rate
        if (!structure.tiers || structure.tiers.length === 0) {
          throw new BadRequestException('Tiered commission structure requires at least one tier');
        }
        for (const tier of structure.tiers) {
          if (tier.valueType === 'percentage') {
            const tierRate = tier.value / 100;
            if (!validateCommissionRate(tierRate, partnerCategory)) {
              throw new BadRequestException(
                `Tier commission rate ${tier.value}% violates FRS Section 1.2 for category ${partnerCategory}. ` +
                  `Valid range: ${validRange.min * 100}%-${validRange.max * 100}%`,
              );
            }
          }
        }
        break;

      default:
        throw new BadRequestException(
          `Cannot validate FRS compliance for commission type: ${structure.type}`,
        );
    }

    this.logger.log(`FRS commission rate validation passed for category ${partnerCategory}`);
  }
}
