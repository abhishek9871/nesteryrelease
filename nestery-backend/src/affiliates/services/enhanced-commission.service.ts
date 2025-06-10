import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CommissionBatchEntity, BatchStatus } from '../entities/commission-batch.entity';
import { AffiliateEarningEntity, EarningStatusEnum } from '../entities/affiliate-earning.entity';
import {
  CommissionCalculationService,
  CommissionCalculationInput,
} from './commission-calculation.service';

@Injectable()
export class EnhancedCommissionService {
  private readonly logger = new Logger(EnhancedCommissionService.name);

  constructor(
    @InjectRepository(CommissionBatchEntity)
    private commissionBatchRepository: Repository<CommissionBatchEntity>,
    @InjectRepository(AffiliateEarningEntity)
    private affiliateEarningRepository: Repository<AffiliateEarningEntity>,
    private commissionCalculationService: CommissionCalculationService,
  ) {}

  @Cron('0 2 * * *', { timeZone: 'UTC' })
  async processDailyCommissions(): Promise<void> {
    const batchDate = new Date();
    batchDate.setHours(0, 0, 0, 0);

    this.logger.log(`Starting daily commission processing for ${batchDate.toISOString()}`);

    const batch = await this.createCommissionBatch(batchDate);

    try {
      const pendingEarnings = await this.affiliateEarningRepository.find({
        where: { status: EarningStatusEnum.PENDING },
        relations: ['partner', 'offer'],
      });

      let totalCommissions = 0;
      let processedCount = 0;

      for (const earning of pendingEarnings) {
        try {
          const calculationInput: CommissionCalculationInput = {
            partnerId: earning.partnerId,
            offerId: earning.offerId,
            bookingValue: Number(earning.amountEarned),
            currency: earning.currency,
            conversionReferenceId: earning.conversionReferenceId || undefined,
            linkId: earning.linkId || undefined,
            userId: earning.userId || undefined,
            bookingId: earning.bookingId || undefined,
          };

          const calculationResult =
            await this.commissionCalculationService.calculateCommission(calculationInput);

          earning.amountEarned = Number(calculationResult.amountEarned);
          earning.status = EarningStatusEnum.CONFIRMED;
          earning.notes = `Processed in batch ${batch.id} - ${JSON.stringify(calculationResult.calculationDetails)}`;

          await this.affiliateEarningRepository.save(earning);

          totalCommissions += Number(calculationResult.amountEarned);
          processedCount++;
        } catch (error) {
          this.logger.error(`Failed to process earning ${earning.id}:`, error);
        }
      }

      await this.completeCommissionBatch(batch.id, totalCommissions, processedCount);
      this.logger.log(
        `Completed daily commission processing: ${processedCount} earnings, $${totalCommissions} total`,
      );
    } catch (error) {
      await this.failCommissionBatch(batch.id, error.message);
      this.logger.error('Daily commission processing failed:', error);
    }
  }

  async createCommissionBatch(batchDate: Date): Promise<CommissionBatchEntity> {
    const batch = this.commissionBatchRepository.create({
      batchDate,
      status: BatchStatus.PROCESSING,
    });
    return await this.commissionBatchRepository.save(batch);
  }

  async completeCommissionBatch(
    batchId: string,
    totalCommissions: number,
    processedEarnings: number,
  ): Promise<void> {
    await this.commissionBatchRepository.update(batchId, {
      status: BatchStatus.COMPLETED,
      totalCommissions,
      processedEarnings,
    });
  }

  async failCommissionBatch(batchId: string, errorMessage: string): Promise<void> {
    await this.commissionBatchRepository.update(batchId, {
      status: BatchStatus.FAILED,
      errorMessage,
    });
  }

  async getCommissionBatches(): Promise<CommissionBatchEntity[]> {
    return await this.commissionBatchRepository.find({
      order: { createdAt: 'DESC' },
      take: 50,
    });
  }

  async manualProcessCommissions(): Promise<{
    batchId: string;
    processedCount: number;
    totalCommissions: number;
  }> {
    this.logger.log('Starting manual commission processing');

    const batchDate = new Date();
    const batch = await this.createCommissionBatch(batchDate);

    try {
      const pendingEarnings = await this.affiliateEarningRepository.find({
        where: { status: EarningStatusEnum.PENDING },
        relations: ['partner', 'offer'],
      });

      let totalCommissions = 0;
      let processedCount = 0;

      for (const earning of pendingEarnings) {
        try {
          const calculationInput: CommissionCalculationInput = {
            partnerId: earning.partnerId,
            offerId: earning.offerId,
            bookingValue: Number(earning.amountEarned),
            currency: earning.currency,
            conversionReferenceId: earning.conversionReferenceId || undefined,
            linkId: earning.linkId || undefined,
            userId: earning.userId || undefined,
            bookingId: earning.bookingId || undefined,
          };

          const calculationResult =
            await this.commissionCalculationService.calculateCommission(calculationInput);

          earning.amountEarned = Number(calculationResult.amountEarned);
          earning.status = EarningStatusEnum.CONFIRMED;
          earning.notes = `Manually processed in batch ${batch.id} - ${JSON.stringify(calculationResult.calculationDetails)}`;

          await this.affiliateEarningRepository.save(earning);

          totalCommissions += Number(calculationResult.amountEarned);
          processedCount++;
        } catch (error) {
          this.logger.error(`Failed to process earning ${earning.id}:`, error);
        }
      }

      await this.completeCommissionBatch(batch.id, totalCommissions, processedCount);
      this.logger.log(
        `Manual commission processing completed: ${processedCount} earnings, $${totalCommissions} total`,
      );

      return {
        batchId: batch.id,
        processedCount,
        totalCommissions,
      };
    } catch (error) {
      await this.failCommissionBatch(batch.id, error.message);
      this.logger.error('Manual commission processing failed:', error);
      throw error;
    }
  }
}
