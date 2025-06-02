import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { PartnerEntity } from './partner.entity';

export enum InvoiceStatus {
  DRAFT = 'DRAFT',
  SENT = 'SENT',
  PAID = 'PAID',
  VOID = 'VOID',
  OVERDUE = 'OVERDUE',
}

export interface InvoiceLineItem {
  description: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  period?: {
    from: string;
    to: string;
  };
}

@Entity('affiliate_invoices')
@Index('IDX_invoices_partnerId', ['partnerId'])
export class InvoiceEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  partnerId: string;

  @ManyToOne(() => PartnerEntity, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'partnerId' })
  partner: PartnerEntity;

  @Column({ type: 'varchar', length: 100, unique: true })
  invoiceNumber: string;

  @Column({ type: 'timestamp with time zone' })
  issueDate: Date;

  @Column({ type: 'timestamp with time zone' })
  dueDate: Date;

  @Column({ type: 'numeric', precision: 12, scale: 2 })
  amountDue: number;

  @Column({ type: 'varchar', length: 3 })
  currency: string;

  @Column({
    type: 'enum',
    enum: InvoiceStatus,
    default: InvoiceStatus.DRAFT,
  })
  status: InvoiceStatus;

  @Column({ type: 'jsonb' })
  lineItems: InvoiceLineItem[];

  @Column({ type: 'text', nullable: true })
  notes?: string | null;

  @CreateDateColumn({ 
    type: 'timestamp with time zone', 
    default: () => 'CURRENT_TIMESTAMP' 
  })
  createdAt: Date;

  @UpdateDateColumn({
    type: 'timestamp with time zone',
    default: () => 'CURRENT_TIMESTAMP',
    onUpdate: 'CURRENT_TIMESTAMP',
  })
  updatedAt: Date;
}
