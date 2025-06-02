import { Injectable, Logger, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AffiliateEarningEntity } from '../entities/affiliate-earning.entity';
import { AffiliateLinkEntity } from '../entities/affiliate-link.entity';
import { AffiliateOfferEntity } from '../entities/affiliate-offer.entity';
import { PartnerEntity } from '../entities/partner.entity';
import { EarningStatusEnum } from '../enums/earning-status.enum';
import { CommissionCalculationService } from './commission-calculation.service';
import { AuditService } from './audit.service';

export interface RecordConversionDetails {
  bookingId?: string;
  conversionReferenceId?: string;
  amount?: number; // Sale amount, if applicable, to calculate commission
  currency?: string;
  // Potentially other details like customer ID, product ID, etc.
}

export interface ConversionReportFilters {
  partnerId?: string;
  status?: EarningStatusEnum;
  dateFrom?: Date;
  dateTo?: Date;
  currency?: string;
  minAmount?: number;
  maxAmount?: number;
}

export interface ConversionReportDto {
  earnings: AffiliateEarningEntity[];
  total: number;
  summary: {
    totalEarnings: number;
    totalPending: number;
    totalConfirmed: number;
    totalPaid: number;
    currency: string;
  };
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
    private readonly commissionCalculationService: CommissionCalculationService,
    private readonly auditService: AuditService,
  ) {}

  /**
   * Records a conversion and creates an earning record using production-ready commission calculation.
   * Integrates with CommissionCalculationService for precise financial calculations.
   */
  async recordConversion(
    linkId: string,
    details: RecordConversionDetails,
  ): Promise<AffiliateEarningEntity> {
    this.logger.log(
      `Recording conversion for linkId: ${linkId}, details: ${JSON.stringify(details)}`,
    );

    // Validate required details
    if (!details.amount || details.amount <= 0) {
      throw new BadRequestException('Valid booking amount is required for commission calculation');
    }

    const link = await this.linkRepository.findOne({
      where: { id: linkId },
      relations: ['offer', 'offer.partner'],
    });

    if (!link) {
      throw new NotFoundException(`Affiliate link with ID ${linkId} not found.`);
    }

    if (!link.offer.isActive) {
      throw new BadRequestException(`Offer ${link.offer.title} is not active`);
    }

    if (!link.offer.partner.isActive) {
      throw new BadRequestException(`Partner ${link.offer.partner.name} is not active`);
    }

    // Use CommissionCalculationService for precise calculation
    const commissionInput = {
      partnerId: link.offer.partnerId,
      offerId: link.offerId,
      bookingValue: details.amount,
      currency: details.currency || 'USD',
      conversionReferenceId: details.conversionReferenceId,
      linkId: linkId,
      userId: link.userId || undefined,
      bookingId: details.bookingId,
    };

    try {
      const commissionResult =
        await this.commissionCalculationService.calculateCommission(commissionInput);

      const earning = this.earningRepository.create({
        partnerId: link.offer.partnerId,
        offerId: link.offerId,
        linkId: link.id,
        userId: link.userId,
        bookingId: details.bookingId,
        conversionReferenceId: details.conversionReferenceId,
        amountEarned: commissionResult.amountEarned.toNumber(),
        currency: commissionResult.currency,
        transactionDate: new Date(),
        status: EarningStatusEnum.PENDING,
        notes: `Commission calculated: ${commissionResult.calculationDetails}`,
      });

      const savedEarning = await this.earningRepository.save(earning);

      // Audit the conversion
      await this.auditService.logAction({
        userId: link.userId || 'system',
        partnerId: link.offer.partnerId,
        entityId: savedEarning.id,
        entityType: 'AffiliateEarning',
        actionType: 'CONVERSION_RECORDED',
        details: {
          linkId,
          bookingValue: details.amount,
          commissionAmount: commissionResult.amountEarned.toNumber(),
          currency: commissionResult.currency,
        },
      });

      this.logger.log(
        `Successfully recorded conversion for link ${linkId}, earning ID: ${savedEarning.id}`,
      );
      return savedEarning;
    } catch (error) {
      this.logger.error(
        `Failed to calculate commission for conversion: ${error.message}`,
        error.stack,
      );
      throw new BadRequestException(`Commission calculation failed: ${error.message}`);
    }
  }

  /**
   * Get conversion report with filtering and analytics
   */
  async getConversionReport(
    partnerId: string,
    filters: ConversionReportFilters,
  ): Promise<ConversionReportDto> {
    this.logger.log(
      `Generating conversion report for partner ${partnerId} with filters: ${JSON.stringify(filters)}`,
    );

    // Verify partner exists
    const partner = await this.partnerRepository.findOneBy({ id: partnerId });
    if (!partner) {
      throw new NotFoundException(`Partner with ID ${partnerId} not found.`);
    }

    const queryBuilder = this.earningRepository.createQueryBuilder('earning');

    // Load relations
    queryBuilder
      .leftJoinAndSelect('earning.offer', 'offer')
      .leftJoinAndSelect('earning.partner', 'partner')
      .leftJoinAndSelect('earning.link', 'link')
      .where('earning.partnerId = :partnerId', { partnerId });

    // Apply filters
    if (filters.status) {
      queryBuilder.andWhere('earning.status = :status', { status: filters.status });
    }
    if (filters.dateFrom) {
      queryBuilder.andWhere('earning.transactionDate >= :dateFrom', { dateFrom: filters.dateFrom });
    }
    if (filters.dateTo) {
      queryBuilder.andWhere('earning.transactionDate <= :dateTo', { dateTo: filters.dateTo });
    }
    if (filters.currency) {
      queryBuilder.andWhere('earning.currency = :currency', { currency: filters.currency });
    }
    if (filters.minAmount) {
      queryBuilder.andWhere('earning.amountEarned >= :minAmount', { minAmount: filters.minAmount });
    }
    if (filters.maxAmount) {
      queryBuilder.andWhere('earning.amountEarned <= :maxAmount', { maxAmount: filters.maxAmount });
    }

    // Order by transaction date descending
    queryBuilder.orderBy('earning.transactionDate', 'DESC');

    const [earnings, total] = await queryBuilder.getManyAndCount();

    // Calculate summary
    const summaryQuery = this.earningRepository
      .createQueryBuilder('earning')
      .where('earning.partnerId = :partnerId', { partnerId })
      .select([
        'COALESCE(SUM(earning.amountEarned), 0) as totalEarnings',
        'COALESCE(SUM(CASE WHEN earning.status = :pendingStatus THEN earning.amountEarned END), 0) as totalPending',
        'COALESCE(SUM(CASE WHEN earning.status = :confirmedStatus THEN earning.amountEarned END), 0) as totalConfirmed',
        'COALESCE(SUM(CASE WHEN earning.status = :paidStatus THEN earning.amountEarned END), 0) as totalPaid',
      ])
      .setParameters({
        pendingStatus: EarningStatusEnum.PENDING,
        confirmedStatus: EarningStatusEnum.CONFIRMED,
        paidStatus: EarningStatusEnum.PAID,
      });

    // Apply same filters to summary
    if (filters.dateFrom) {
      summaryQuery.andWhere('earning.transactionDate >= :dateFrom', { dateFrom: filters.dateFrom });
    }
    if (filters.dateTo) {
      summaryQuery.andWhere('earning.transactionDate <= :dateTo', { dateTo: filters.dateTo });
    }
    if (filters.currency) {
      summaryQuery.andWhere('earning.currency = :currency', { currency: filters.currency });
    }

    const summary = await summaryQuery.getRawOne();

    const report: ConversionReportDto = {
      earnings,
      total,
      summary: {
        totalEarnings: parseFloat(summary.totalEarnings) || 0,
        totalPending: parseFloat(summary.totalPending) || 0,
        totalConfirmed: parseFloat(summary.totalConfirmed) || 0,
        totalPaid: parseFloat(summary.totalPaid) || 0,
        currency: filters.currency || 'USD',
      },
    };

    this.logger.log(
      `Generated conversion report for partner ${partnerId}: ${total} earnings found`,
    );
    return report;
  }

  /**
   * Update earning status with state machine validation and audit logging
   */
  async updateEarningStatus(
    earningId: string,
    newStatus: EarningStatusEnum,
    reason?: string,
    userId?: string,
  ): Promise<AffiliateEarningEntity> {
    this.logger.log(`Updating earning ${earningId} status to ${newStatus}, reason: ${reason}`);

    const earning = await this.earningRepository.findOne({
      where: { id: earningId },
      relations: ['partner', 'offer'],
    });

    if (!earning) {
      throw new NotFoundException(`Earning with ID ${earningId} not found`);
    }

    // Validate state transitions (state machine pattern)
    const validTransitions = this.getValidStatusTransitions(earning.status);
    if (!validTransitions.includes(newStatus)) {
      throw new BadRequestException(
        `Invalid status transition from ${earning.status} to ${newStatus}. Valid transitions: ${validTransitions.join(', ')}`,
      );
    }

    const oldStatus = earning.status;
    earning.status = newStatus;
    earning.updatedAt = new Date();

    // Add status change note
    const statusNote = `[${new Date().toISOString()}] Status changed from ${oldStatus} to ${newStatus}${reason ? ` - ${reason}` : ''}`;
    earning.notes = earning.notes ? `${earning.notes}\n${statusNote}` : statusNote;

    const updatedEarning = await this.earningRepository.save(earning);

    // Audit the status change
    await this.auditService.logAction({
      userId: userId || 'system',
      partnerId: earning.partnerId,
      entityId: earningId,
      entityType: 'AffiliateEarning',
      actionType: 'STATUS_UPDATED',
      details: {
        oldStatus,
        newStatus,
        reason,
        amountEarned: earning.amountEarned,
        currency: earning.currency,
      },
    });

    this.logger.log(
      `Successfully updated earning ${earningId} status from ${oldStatus} to ${newStatus}`,
    );
    return updatedEarning;
  }

  /**
   * Get valid status transitions based on current status (state machine)
   */
  private getValidStatusTransitions(currentStatus: EarningStatusEnum): EarningStatusEnum[] {
    const transitions: Record<EarningStatusEnum, EarningStatusEnum[]> = {
      [EarningStatusEnum.PENDING]: [EarningStatusEnum.CONFIRMED, EarningStatusEnum.CANCELLED],
      [EarningStatusEnum.CONFIRMED]: [EarningStatusEnum.PAID, EarningStatusEnum.CANCELLED],
      [EarningStatusEnum.PAID]: [], // Terminal state
      [EarningStatusEnum.CANCELLED]: [EarningStatusEnum.PENDING], // Allow reactivation
    };

    return transitions[currentStatus] || [];
  }
}
