import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, FindManyOptions, Between } from 'typeorm';
import { AuditLogEntity } from '../entities/audit-log.entity';

export interface AuditLogInput {
  userId?: string;
  partnerId?: string;
  entityId?: string;
  entityType?: string;
  actionType: string;
  details?: Record<string, any>;
  ipAddress?: string;
  userAgent?: string;
}

export interface AuditLogQuery {
  userId?: string;
  partnerId?: string;
  entityId?: string;
  entityType?: string;
  actionType?: string;
  startDate?: Date;
  endDate?: Date;
  limit?: number;
  offset?: number;
}

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(
    @InjectRepository(AuditLogEntity)
    private readonly auditLogRepository: Repository<AuditLogEntity>,
  ) {}

  /**
   * Log an audit action with comprehensive details
   */
  async logAction(input: AuditLogInput): Promise<AuditLogEntity> {
    try {
      const auditLog = this.auditLogRepository.create({
        userId: input.userId,
        partnerId: input.partnerId,
        entityId: input.entityId,
        entityType: input.entityType,
        actionType: input.actionType,
        details: input.details,
        ipAddress: input.ipAddress,
        userAgent: input.userAgent,
        timestamp: new Date(),
      });

      const savedLog = await this.auditLogRepository.save(auditLog);
      
      this.logger.log(`Audit log created: ${input.actionType} for ${input.entityType || 'unknown'} ${input.entityId || 'N/A'}`);
      
      return savedLog;
    } catch (error) {
      this.logger.error(`Failed to create audit log: ${error.message}`, error.stack);
      throw new Error(`Audit logging failed: ${error.message}`);
    }
  }

  /**
   * Retrieve audit logs with filtering and pagination
   */
  async getAuditLogs(query: AuditLogQuery): Promise<{
    logs: AuditLogEntity[];
    total: number;
    hasMore: boolean;
  }> {
    const findOptions: FindManyOptions<AuditLogEntity> = {
      order: { timestamp: 'DESC' },
      take: query.limit || 50,
      skip: query.offset || 0,
    };

    // Build where conditions
    const whereConditions: any = {};

    if (query.userId) {
      whereConditions.userId = query.userId;
    }

    if (query.partnerId) {
      whereConditions.partnerId = query.partnerId;
    }

    if (query.entityId) {
      whereConditions.entityId = query.entityId;
    }

    if (query.entityType) {
      whereConditions.entityType = query.entityType;
    }

    if (query.actionType) {
      whereConditions.actionType = query.actionType;
    }

    if (query.startDate && query.endDate) {
      whereConditions.timestamp = Between(query.startDate, query.endDate);
    } else if (query.startDate) {
      whereConditions.timestamp = Between(query.startDate, new Date());
    } else if (query.endDate) {
      whereConditions.timestamp = Between(new Date(0), query.endDate);
    }

    findOptions.where = whereConditions;

    const [logs, total] = await this.auditLogRepository.findAndCount(findOptions);

    const hasMore = (query.offset || 0) + logs.length < total;

    return {
      logs,
      total,
      hasMore,
    };
  }

  /**
   * Get audit trail for a specific entity
   */
  async getEntityAuditTrail(
    entityId: string,
    entityType: string,
    limit: number = 100,
  ): Promise<AuditLogEntity[]> {
    return this.auditLogRepository.find({
      where: {
        entityId,
        entityType,
      },
      order: { timestamp: 'DESC' },
      take: limit,
    });
  }

  /**
   * Get audit summary for a partner
   */
  async getPartnerAuditSummary(
    partnerId: string,
    startDate?: Date,
    endDate?: Date,
  ): Promise<{
    totalActions: number;
    actionsByType: Record<string, number>;
    recentActions: AuditLogEntity[];
  }> {
    const whereConditions: any = { partnerId };

    if (startDate && endDate) {
      whereConditions.timestamp = Between(startDate, endDate);
    }

    // Get total count
    const totalActions = await this.auditLogRepository.count({
      where: whereConditions,
    });

    // Get actions by type
    const actionTypeQuery = this.auditLogRepository
      .createQueryBuilder('audit')
      .select('audit.actionType', 'actionType')
      .addSelect('COUNT(*)', 'count')
      .where('audit.partnerId = :partnerId', { partnerId })
      .groupBy('audit.actionType');

    if (startDate && endDate) {
      actionTypeQuery.andWhere('audit.timestamp BETWEEN :startDate AND :endDate', {
        startDate,
        endDate,
      });
    }

    const actionTypeCounts = await actionTypeQuery.getRawMany();
    const actionsByType: Record<string, number> = {};
    
    actionTypeCounts.forEach(item => {
      actionsByType[item.actionType] = parseInt(item.count, 10);
    });

    // Get recent actions
    const recentActions = await this.auditLogRepository.find({
      where: whereConditions,
      order: { timestamp: 'DESC' },
      take: 10,
    });

    return {
      totalActions,
      actionsByType,
      recentActions,
    };
  }

  /**
   * Clean up old audit logs (for maintenance)
   */
  async cleanupOldLogs(olderThanDays: number = 365): Promise<number> {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - olderThanDays);

    const result = await this.auditLogRepository
      .createQueryBuilder()
      .delete()
      .from(AuditLogEntity)
      .where('timestamp < :cutoffDate', { cutoffDate })
      .execute();

    const deletedCount = result.affected || 0;
    
    this.logger.log(`Cleaned up ${deletedCount} audit logs older than ${olderThanDays} days`);
    
    return deletedCount;
  }

  /**
   * Log partner action with automatic context detection
   */
  async logPartnerAction(
    partnerId: string,
    actionType: string,
    details?: Record<string, any>,
    userId?: string,
    request?: any,
  ): Promise<AuditLogEntity> {
    return this.logAction({
      userId,
      partnerId,
      entityId: partnerId,
      entityType: 'partner',
      actionType,
      details,
      ipAddress: request?.ip || request?.connection?.remoteAddress,
      userAgent: request?.get?.('User-Agent') || request?.headers?.['user-agent'],
    });
  }

  /**
   * Log offer action
   */
  async logOfferAction(
    offerId: string,
    partnerId: string,
    actionType: string,
    details?: Record<string, any>,
    userId?: string,
    request?: any,
  ): Promise<AuditLogEntity> {
    return this.logAction({
      userId,
      partnerId,
      entityId: offerId,
      entityType: 'affiliate_offer',
      actionType,
      details,
      ipAddress: request?.ip || request?.connection?.remoteAddress,
      userAgent: request?.get?.('User-Agent') || request?.headers?.['user-agent'],
    });
  }

  /**
   * Log earning action
   */
  async logEarningAction(
    earningId: string,
    partnerId: string,
    actionType: string,
    details?: Record<string, any>,
    userId?: string,
    request?: any,
  ): Promise<AuditLogEntity> {
    return this.logAction({
      userId,
      partnerId,
      entityId: earningId,
      entityType: 'affiliate_earning',
      actionType,
      details,
      ipAddress: request?.ip || request?.connection?.remoteAddress,
      userAgent: request?.get?.('User-Agent') || request?.headers?.['user-agent'],
    });
  }

  /**
   * Log payout action
   */
  async logPayoutAction(
    payoutId: string,
    partnerId: string,
    actionType: string,
    details?: Record<string, any>,
    userId?: string,
    request?: any,
  ): Promise<AuditLogEntity> {
    return this.logAction({
      userId,
      partnerId,
      entityId: payoutId,
      entityType: 'affiliate_payout',
      actionType,
      details,
      ipAddress: request?.ip || request?.connection?.remoteAddress,
      userAgent: request?.get?.('User-Agent') || request?.headers?.['user-agent'],
    });
  }
}
