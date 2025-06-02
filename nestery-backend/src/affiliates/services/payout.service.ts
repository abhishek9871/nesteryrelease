import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan, In } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Cron, CronExpression } from '@nestjs/schedule';
import Stripe from 'stripe';
import { Decimal } from 'decimal.js';
import { PartnerEntity } from '../entities/partner.entity';
import { PayoutEntity, PayoutStatus } from '../entities/payout.entity';
import { InvoiceEntity, InvoiceStatus, InvoiceLineItem } from '../entities/invoice.entity';
import { AffiliateEarningEntity, EarningStatusEnum } from '../entities/affiliate-earning.entity';
import { AuditService } from './audit.service';

export interface PayoutRequestDto {
  amount: number;
  currency: string;
  paymentMethod: string;
  notes?: string;
}

export interface PayoutResponseDto {
  id: string;
  partnerId: string;
  amount: number;
  currency: string;
  status: PayoutStatus;
  paymentMethod: string;
  transactionId?: string | null;
  invoiceId?: string | null;
  payoutDate?: Date | null;
  createdAt: Date;
  updatedAt: Date;
}

@Injectable()
export class PayoutService {
  private readonly logger = new Logger(PayoutService.name);
  private readonly stripe: Stripe;

  constructor(
    @InjectRepository(PartnerEntity)
    private readonly partnerRepository: Repository<PartnerEntity>,
    @InjectRepository(PayoutEntity)
    private readonly payoutRepository: Repository<PayoutEntity>,
    @InjectRepository(InvoiceEntity)
    private readonly invoiceRepository: Repository<InvoiceEntity>,
    @InjectRepository(AffiliateEarningEntity)
    private readonly earningRepository: Repository<AffiliateEarningEntity>,
    private readonly auditService: AuditService,
    private readonly configService: ConfigService,
  ) {
    // Initialize Stripe with secret key
    const stripeSecretKey = this.configService.get<string>('STRIPE_SECRET_KEY');
    if (!stripeSecretKey) {
      this.logger.warn('Stripe secret key not configured. Payout functionality will be limited.');
    } else {
      this.stripe = new Stripe(stripeSecretKey, {
        apiVersion: '2025-02-24.acacia',
        typescript: true,
      });
    }
  }

  /**
   * Request a payout for a partner
   */
  async requestPayout(
    partnerId: string,
    payoutRequest: PayoutRequestDto,
  ): Promise<PayoutResponseDto> {
    this.logger.log(`Processing payout request for partner ${partnerId}`);

    // Validate partner exists and is active
    const partner = await this.partnerRepository.findOne({
      where: { id: partnerId, isActive: true },
    });

    if (!partner) {
      throw new Error(`Active partner not found: ${partnerId}`);
    }

    // Validate available earnings
    const availableEarnings = await this.getAvailableEarnings(partnerId);
    const requestedAmount = new Decimal(payoutRequest.amount);

    if (requestedAmount.gt(availableEarnings)) {
      throw new Error(
        `Insufficient available earnings. Requested: ${requestedAmount}, Available: ${availableEarnings}`,
      );
    }

    // Validate minimum payout amount
    const minimumPayout = new Decimal(this.configService.get<number>('MINIMUM_PAYOUT_AMOUNT', 50));
    if (requestedAmount.lt(minimumPayout)) {
      throw new Error(`Minimum payout amount is ${minimumPayout} ${payoutRequest.currency}`);
    }

    // Create payout record
    const payout = this.payoutRepository.create({
      partnerId,
      amount: requestedAmount.toNumber(),
      currency: payoutRequest.currency,
      status: PayoutStatus.PENDING,
      paymentMethod: payoutRequest.paymentMethod,
    });

    const savedPayout = await this.payoutRepository.save(payout);

    // Generate invoice if required
    if (this.shouldGenerateInvoice(payoutRequest.paymentMethod)) {
      const invoice = await this.generateInvoice(partnerId, savedPayout);
      savedPayout.invoiceId = invoice.id;
      await this.payoutRepository.save(savedPayout);
    }

    // Audit the payout request
    await this.auditService.logPayoutAction(
      savedPayout.id,
      partnerId,
      'PAYOUT_REQUESTED',
      {
        amount: requestedAmount.toString(),
        currency: payoutRequest.currency,
        paymentMethod: payoutRequest.paymentMethod,
        availableEarnings: availableEarnings.toString(),
      },
    );

    this.logger.log(`Payout request created: ${savedPayout.id}`);

    return this.mapToResponseDto(savedPayout);
  }

  /**
   * Process pending payouts automatically
   */
  @Cron(CronExpression.EVERY_DAY_AT_2AM)
  async processAutomaticPayouts(): Promise<void> {
    this.logger.log('Starting automatic payout processing');

    try {
      const pendingPayouts = await this.payoutRepository.find({
        where: { status: PayoutStatus.PENDING },
        relations: ['partner'],
      });

      for (const payout of pendingPayouts) {
        try {
          await this.processPayout(payout);
        } catch (error) {
          this.logger.error(
            `Failed to process payout ${payout.id}: ${error.message}`,
            error.stack,
          );
          
          // Mark payout as failed
          payout.status = PayoutStatus.FAILED;
          await this.payoutRepository.save(payout);

          await this.auditService.logPayoutAction(
            payout.id,
            payout.partnerId,
            'PAYOUT_FAILED',
            { error: error.message },
          );
        }
      }

      this.logger.log(`Processed ${pendingPayouts.length} pending payouts`);
    } catch (error) {
      this.logger.error(`Automatic payout processing failed: ${error.message}`, error.stack);
    }
  }

  /**
   * Process a single payout using Stripe Connect
   */
  private async processPayout(payout: PayoutEntity): Promise<void> {
    if (!this.stripe) {
      throw new Error('Stripe not configured');
    }

    this.logger.log(`Processing payout ${payout.id} for partner ${payout.partnerId}`);

    // Update status to processing
    payout.status = PayoutStatus.PROCESSING;
    await this.payoutRepository.save(payout);

    try {
      // Get partner's Stripe Connect account
      const stripeAccountId = await this.getPartnerStripeAccount(payout.partnerId);

      // Create Stripe transfer
      const transfer = await this.stripe.transfers.create({
        amount: Math.round(payout.amount * 100), // Convert to cents
        currency: payout.currency.toLowerCase(),
        destination: stripeAccountId,
        description: `Affiliate payout for partner ${payout.partnerId}`,
        metadata: {
          payoutId: payout.id,
          partnerId: payout.partnerId,
        },
      });

      // Update payout with Stripe transaction details
      payout.status = PayoutStatus.PAID;
      payout.transactionId = transfer.id;
      payout.payoutDate = new Date();
      await this.payoutRepository.save(payout);

      // Mark associated earnings as paid
      await this.markEarningsAsPaid(payout.partnerId, payout.amount);

      // Audit successful payout
      await this.auditService.logPayoutAction(
        payout.id,
        payout.partnerId,
        'PAYOUT_COMPLETED',
        {
          stripeTransferId: transfer.id,
          amount: payout.amount,
          currency: payout.currency,
        },
      );

      this.logger.log(`Payout ${payout.id} completed successfully`);
    } catch (error) {
      // Handle Stripe errors
      payout.status = PayoutStatus.FAILED;
      await this.payoutRepository.save(payout);

      await this.auditService.logPayoutAction(
        payout.id,
        payout.partnerId,
        'PAYOUT_FAILED',
        {
          error: error.message,
          stripeError: error.type || 'unknown',
        },
      );

      throw error;
    }
  }

  /**
   * Generate invoice for payout
   */
  private async generateInvoice(
    partnerId: string,
    payout: PayoutEntity,
  ): Promise<InvoiceEntity> {
    const partner = await this.partnerRepository.findOne({ where: { id: partnerId } });
    if (!partner) {
      throw new Error(`Partner not found: ${partnerId}`);
    }

    // Get earnings for this period
    const earnings = await this.earningRepository.find({
      where: {
        partnerId,
        status: In([EarningStatusEnum.CONFIRMED, EarningStatusEnum.PENDING]),
      },
      order: { transactionDate: 'ASC' },
    });

    // Create line items from earnings
    const lineItems: InvoiceLineItem[] = earnings.map(earning => ({
      description: `Commission for booking ${earning.conversionReferenceId || earning.bookingId || 'N/A'}`,
      quantity: 1,
      unitPrice: earning.amountEarned,
      totalPrice: earning.amountEarned,
      period: {
        from: earning.transactionDate.toISOString().split('T')[0],
        to: earning.transactionDate.toISOString().split('T')[0],
      },
    }));

    // Generate unique invoice number
    const invoiceNumber = await this.generateInvoiceNumber();

    const invoice = this.invoiceRepository.create({
      partnerId,
      invoiceNumber,
      issueDate: new Date(),
      dueDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
      amountDue: payout.amount,
      currency: payout.currency,
      status: InvoiceStatus.SENT,
      lineItems,
      notes: `Affiliate commission payout for period ending ${new Date().toISOString().split('T')[0]}`,
    });

    const savedInvoice = await this.invoiceRepository.save(invoice);

    await this.auditService.logAction({
      partnerId,
      entityId: savedInvoice.id,
      entityType: 'affiliate_invoice',
      actionType: 'INVOICE_GENERATED',
      details: {
        invoiceNumber: savedInvoice.invoiceNumber,
        amount: savedInvoice.amountDue,
        currency: savedInvoice.currency,
        lineItemCount: lineItems.length,
      },
    });

    return savedInvoice;
  }

  /**
   * Get available earnings for a partner
   */
  private async getAvailableEarnings(partnerId: string): Promise<Decimal> {
    const result = await this.earningRepository
      .createQueryBuilder('earning')
      .select('SUM(earning.amountEarned)', 'total')
      .where('earning.partnerId = :partnerId', { partnerId })
      .andWhere('earning.status IN (:...statuses)', {
        statuses: [EarningStatusEnum.CONFIRMED, EarningStatusEnum.PENDING],
      })
      .getRawOne();

    return new Decimal(result?.total || 0);
  }

  /**
   * Mark earnings as paid
   */
  private async markEarningsAsPaid(partnerId: string, paidAmount: number): Promise<void> {
    const earnings = await this.earningRepository.find({
      where: {
        partnerId,
        status: In([EarningStatusEnum.CONFIRMED, EarningStatusEnum.PENDING]),
      },
      order: { transactionDate: 'ASC' },
    });

    let remainingAmount = new Decimal(paidAmount);

    for (const earning of earnings) {
      if (remainingAmount.lte(0)) break;

      const earningAmount = new Decimal(earning.amountEarned);
      
      if (remainingAmount.gte(earningAmount)) {
        earning.status = EarningStatusEnum.PAID;
        remainingAmount = remainingAmount.sub(earningAmount);
      } else {
        // Partial payment - split the earning
        const paidPortion = remainingAmount;
        const unpaidPortion = earningAmount.sub(remainingAmount);

        earning.amountEarned = paidPortion.toNumber();
        earning.status = EarningStatusEnum.PAID;

        // Create new earning for unpaid portion
        const unpaidEarning = this.earningRepository.create({
          ...earning,
          id: undefined, // Let TypeORM generate new ID
          amountEarned: unpaidPortion.toNumber(),
          status: EarningStatusEnum.CONFIRMED,
          notes: `Split from earning ${earning.id} - unpaid portion`,
        });

        await this.earningRepository.save(unpaidEarning);
        remainingAmount = new Decimal(0);
      }

      await this.earningRepository.save(earning);
    }
  }

  /**
   * Get partner's Stripe Connect account ID
   */
  private async getPartnerStripeAccount(partnerId: string): Promise<string> {
    // This would typically be stored in partner entity or separate table
    // For now, we'll assume it's stored in partner's metadata or a separate field
    const partner = await this.partnerRepository.findOne({ where: { id: partnerId } });
    
    if (!partner) {
      throw new Error(`Partner not found: ${partnerId}`);
    }

    // Assuming stripe account ID is stored in contactInfo or similar field
    const stripeAccountId = (partner.contactInfo as any)?.stripeAccountId;
    
    if (!stripeAccountId) {
      throw new Error(`Stripe Connect account not configured for partner: ${partnerId}`);
    }

    return stripeAccountId;
  }

  /**
   * Generate unique invoice number
   */
  private async generateInvoiceNumber(): Promise<string> {
    const year = new Date().getFullYear();
    const month = String(new Date().getMonth() + 1).padStart(2, '0');
    
    // Get count of invoices this month
    const startOfMonth = new Date(year, new Date().getMonth(), 1);
    const endOfMonth = new Date(year, new Date().getMonth() + 1, 0);
    
    const count = await this.invoiceRepository.count({
      where: {
        issueDate: MoreThan(startOfMonth),
      },
    });

    const sequence = String(count + 1).padStart(4, '0');
    return `INV-${year}${month}-${sequence}`;
  }

  /**
   * Check if invoice should be generated for payment method
   */
  private shouldGenerateInvoice(paymentMethod: string): boolean {
    // Generate invoices for bank transfers and other formal payment methods
    const invoiceRequiredMethods = ['bank_transfer', 'wire_transfer', 'ach'];
    return invoiceRequiredMethods.includes(paymentMethod.toLowerCase());
  }

  /**
   * Get payouts for user/partner
   */
  async getPayouts(userId: string, userRole: string): Promise<PayoutResponseDto[]> {
    let payouts: PayoutEntity[];

    if (userRole === 'admin') {
      // Admin can see all payouts
      payouts = await this.payoutRepository.find({
        order: { createdAt: 'DESC' },
        take: 100, // Limit for performance
      });
    } else {
      // Partner can only see their own payouts
      payouts = await this.payoutRepository.find({
        where: { partnerId: userId },
        order: { createdAt: 'DESC' },
      });
    }

    return payouts.map(this.mapToResponseDto);
  }

  /**
   * Map entity to response DTO
   */
  private mapToResponseDto(payout: PayoutEntity): PayoutResponseDto {
    return {
      id: payout.id,
      partnerId: payout.partnerId,
      amount: payout.amount,
      currency: payout.currency,
      status: payout.status,
      paymentMethod: payout.paymentMethod,
      transactionId: payout.transactionId,
      invoiceId: payout.invoiceId,
      payoutDate: payout.payoutDate,
      createdAt: payout.createdAt,
      updatedAt: payout.updatedAt,
    };
  }
}
