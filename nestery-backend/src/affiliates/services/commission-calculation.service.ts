import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Decimal } from 'decimal.js';
import { PartnerEntity } from '../entities/partner.entity';
import { AffiliateOfferEntity, CommissionStructure, Tier } from '../entities/affiliate-offer.entity';
import { AffiliateEarningEntity } from '../entities/affiliate-earning.entity';
import { AuditService } from './audit.service';

export interface CommissionCalculationInput {
  partnerId: string;
  offerId: string;
  bookingValue: number;
  currency: string;
  conversionReferenceId?: string;
  linkId?: string;
  userId?: string;
  bookingId?: string;
}

export interface CommissionCalculationResult {
  amountEarned: Decimal;
  currency: string;
  calculationDetails: {
    baseAmount: Decimal;
    commissionRate: Decimal;
    commissionType: string;
    tierApplied?: string;
    adjustments?: Array<{
      type: string;
      amount: Decimal;
      reason: string;
    }>;
  };
}

@Injectable()
export class CommissionCalculationService {
  private readonly logger = new Logger(CommissionCalculationService.name);

  constructor(
    @InjectRepository(PartnerEntity)
    private readonly partnerRepository: Repository<PartnerEntity>,
    @InjectRepository(AffiliateOfferEntity)
    private readonly offerRepository: Repository<AffiliateOfferEntity>,
    @InjectRepository(AffiliateEarningEntity)
    private readonly earningRepository: Repository<AffiliateEarningEntity>,
    private readonly auditService: AuditService,
  ) {
    // Configure Decimal.js for financial precision
    Decimal.set({
      precision: 28, // High precision for financial calculations
      rounding: Decimal.ROUND_HALF_UP, // Standard financial rounding
      toExpNeg: -7, // Use exponential notation for very small numbers
      toExpPos: 21, // Use exponential notation for very large numbers
      maxE: 9e15, // Maximum exponent
      minE: -9e15, // Minimum exponent
      modulo: Decimal.ROUND_DOWN, // Modulo operation rounding
    });
  }

  /**
   * Calculate commission for a booking with industry-leading precision
   */
  async calculateCommission(
    input: CommissionCalculationInput,
  ): Promise<CommissionCalculationResult> {
    this.logger.log(`Calculating commission for partner ${input.partnerId}, offer ${input.offerId}`);

    // Validate input
    if (!input.partnerId || !input.offerId || !input.bookingValue || !input.currency) {
      throw new Error('Missing required commission calculation parameters');
    }

    // Get partner and offer details
    const [partner, offer] = await Promise.all([
      this.partnerRepository.findOne({ where: { id: input.partnerId } }),
      this.offerRepository.findOne({ where: { id: input.offerId } }),
    ]);

    if (!partner) {
      throw new Error(`Partner not found: ${input.partnerId}`);
    }

    if (!offer) {
      throw new Error(`Offer not found: ${input.offerId}`);
    }

    if (!offer.isActive) {
      throw new Error(`Offer is not active: ${input.offerId}`);
    }

    // Check offer validity period
    const now = new Date();
    if (now < offer.validFrom || now > offer.validTo) {
      throw new Error(`Offer is not valid for current date: ${input.offerId}`);
    }

    // Use Decimal for all financial calculations
    const baseAmount = new Decimal(input.bookingValue);
    
    // Calculate commission based on structure
    const result = await this.calculateByStructure(
      baseAmount,
      offer.commissionStructure,
      partner.commissionRateOverride || undefined,
      input.currency,
    );

    // Apply any partner-specific adjustments
    if (partner.commissionRateOverride) {
      const overrideRate = new Decimal(partner.commissionRateOverride);
      const overrideAmount = baseAmount.mul(overrideRate);
      
      if (!result.calculationDetails.adjustments) {
        result.calculationDetails.adjustments = [];
      }
      
      result.calculationDetails.adjustments.push({
        type: 'partner_override',
        amount: overrideAmount.sub(result.amountEarned),
        reason: `Partner-specific commission rate override: ${overrideRate.mul(100)}%`,
      });
      
      result.amountEarned = overrideAmount;
    }

    // Audit the calculation
    await this.auditService.logAction({
      userId: input.userId,
      partnerId: input.partnerId,
      entityId: input.offerId,
      entityType: 'commission_calculation',
      actionType: 'COMMISSION_CALCULATED',
      details: {
        input,
        result: {
          amountEarned: result.amountEarned.toString(),
          calculationDetails: result.calculationDetails,
        },
      },
    });

    this.logger.log(`Commission calculated: ${result.amountEarned.toString()} ${result.currency}`);

    return result;
  }

  /**
   * Calculate commission based on commission structure
   */
  private async calculateByStructure(
    baseAmount: Decimal,
    structure: CommissionStructure,
    partnerOverride?: number,
    currency: string = 'USD',
  ): Promise<CommissionCalculationResult> {
    let amountEarned: Decimal;
    let commissionRate: Decimal;
    let tierApplied: string | undefined;

    switch (structure.type) {
      case 'percentage':
        commissionRate = new Decimal(structure.value || 0).div(100);
        amountEarned = baseAmount.mul(commissionRate);
        break;

      case 'fixed':
        amountEarned = new Decimal(structure.value || 0);
        commissionRate = amountEarned.div(baseAmount);
        break;

      case 'tiered':
        const tierResult = this.calculateTieredCommission(baseAmount, structure.tiers || []);
        amountEarned = tierResult.amount;
        commissionRate = tierResult.rate;
        tierApplied = tierResult.tierDescription;
        break;

      default:
        throw new Error(`Unsupported commission structure type: ${structure.type}`);
    }

    return {
      amountEarned,
      currency,
      calculationDetails: {
        baseAmount,
        commissionRate,
        commissionType: structure.type,
        tierApplied,
      },
    };
  }

  /**
   * Calculate tiered commission with sophisticated tier logic
   */
  private calculateTieredCommission(
    baseAmount: Decimal,
    tiers: Tier[],
  ): { amount: Decimal; rate: Decimal; tierDescription: string } {
    if (!tiers || tiers.length === 0) {
      throw new Error('No tiers defined for tiered commission structure');
    }

    // Sort tiers by threshold (ascending)
    const sortedTiers = [...tiers].sort((a, b) => a.threshold - b.threshold);

    // Find applicable tier
    let applicableTier: Tier | null = null;
    for (const tier of sortedTiers) {
      if (baseAmount.gte(tier.threshold)) {
        applicableTier = tier;
      } else {
        break;
      }
    }

    if (!applicableTier) {
      // Use the lowest tier if amount is below all thresholds
      applicableTier = sortedTiers[0];
    }

    let amount: Decimal;
    let rate: Decimal;

    if (applicableTier.valueType === 'percentage') {
      rate = new Decimal(applicableTier.value).div(100);
      amount = baseAmount.mul(rate);
    } else {
      amount = new Decimal(applicableTier.value);
      rate = amount.div(baseAmount);
    }

    return {
      amount,
      rate,
      tierDescription: `Tier ${applicableTier.threshold}+ (${applicableTier.valueType}: ${applicableTier.value})`,
    };
  }

  /**
   * Process commission adjustment (clawback, bonus, etc.)
   */
  async processCommissionAdjustment(
    earningId: string,
    adjustmentAmount: number,
    adjustmentType: 'CLAWBACK' | 'BONUS' | 'CORRECTION',
    reason: string,
    userId?: string,
  ): Promise<AffiliateEarningEntity> {
    const earning = await this.earningRepository.findOne({
      where: { id: earningId },
      relations: ['partner', 'offer'],
    });

    if (!earning) {
      throw new Error(`Earning not found: ${earningId}`);
    }

    const adjustmentDecimal = new Decimal(adjustmentAmount);
    const currentAmount = new Decimal(earning.amountEarned);
    const newAmount = currentAmount.plus(adjustmentDecimal);

    // Ensure amount doesn't go negative
    if (newAmount.lt(0)) {
      throw new Error('Commission adjustment would result in negative earning amount');
    }

    earning.amountEarned = newAmount.toNumber();
    earning.notes = `${earning.notes || ''}\n[${new Date().toISOString()}] ${adjustmentType}: ${adjustmentDecimal.toString()} - ${reason}`.trim();

    const updatedEarning = await this.earningRepository.save(earning);

    // Audit the adjustment
    await this.auditService.logAction({
      userId,
      partnerId: earning.partnerId,
      entityId: earningId,
      entityType: 'affiliate_earning',
      actionType: `COMMISSION_${adjustmentType}`,
      details: {
        originalAmount: currentAmount.toString(),
        adjustmentAmount: adjustmentDecimal.toString(),
        newAmount: newAmount.toString(),
        reason,
      },
    });

    this.logger.log(`Commission ${adjustmentType.toLowerCase()} processed for earning ${earningId}: ${adjustmentDecimal.toString()}`);

    return updatedEarning;
  }
}
