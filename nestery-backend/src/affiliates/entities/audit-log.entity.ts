import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  Index,
} from 'typeorm';

@Entity('affiliate_audit_logs')
@Index('IDX_audit_logs_userId', ['userId'])
@Index('IDX_audit_logs_partnerId', ['partnerId'])
@Index('IDX_audit_logs_entityId_entityType', ['entityId', 'entityType'])
@Index('IDX_audit_logs_actionType', ['actionType'])
export class AuditLogEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @CreateDateColumn({ 
    type: 'timestamp with time zone', 
    default: () => 'CURRENT_TIMESTAMP' 
  })
  timestamp: Date;

  @Column({ type: 'uuid', nullable: true })
  userId?: string | null;

  @Column({ type: 'uuid', nullable: true })
  partnerId?: string | null;

  @Column({ type: 'uuid', nullable: true })
  entityId?: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true })
  entityType?: string | null;

  @Column({ type: 'varchar', length: 255 })
  actionType: string;

  @Column({ type: 'jsonb', nullable: true })
  details?: Record<string, any> | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  ipAddress?: string | null;

  @Column({ type: 'text', nullable: true })
  userAgent?: string | null;
}
