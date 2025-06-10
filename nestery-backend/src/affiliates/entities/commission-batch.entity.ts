import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

export enum BatchStatus {
  PROCESSING = 'processing',
  COMPLETED = 'completed',
  FAILED = 'failed',
}

@Entity('commission_batches')
export class CommissionBatchEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'date' })
  batchDate: Date;

  @Column({ type: 'decimal', precision: 12, scale: 2, default: 0 })
  totalCommissions: number;

  @Column({ type: 'integer', default: 0 })
  processedEarnings: number;

  @Column({
    type: 'enum',
    enum: BatchStatus,
    default: BatchStatus.PROCESSING,
  })
  status: BatchStatus;

  @Column({ type: 'text', nullable: true })
  errorMessage: string | null;

  @CreateDateColumn({ type: 'timestamp with time zone' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone' })
  updatedAt: Date;
}
