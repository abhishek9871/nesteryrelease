import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { PartnerEntity } from './partner.entity';
import { AffiliateLinkEntity } from './affiliate-link.entity';
import { AffiliateEarningEntity } from './affiliate-earning.entity';

export interface CommissionStructure {
  type: 'percentage' | 'fixed' | 'tiered';
  value?: number; // For percentage (0-100) or fixed amount
  tiers?: Tier[];
}

export interface Tier {
  threshold: number; // e.g., number of sales, revenue amount
  value: number; // Commission value for this tier
  valueType: 'percentage' | 'fixed'; // Type of value (percentage or fixed amount)
}

@Entity('affiliate_offers')
export class AffiliateOfferEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  partnerId: string;

  @ManyToOne(() => PartnerEntity, partner => partner.offers, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'partnerId' })
  partner: PartnerEntity;

  @Column({ type: 'varchar', length: 255 })
  title: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ type: 'jsonb' })
  commissionStructure: CommissionStructure;

  @Column({ type: 'timestamp with time zone' })
  validFrom: Date;

  @Column({ type: 'timestamp with time zone' })
  validTo: Date;

  @Column({ type: 'text' })
  termsConditions: string;

  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @Column({ type: 'varchar', length: 2048, nullable: true })
  originalUrl?: string | null;

  @OneToMany(() => AffiliateLinkEntity, link => link.offer)
  links: AffiliateLinkEntity[];

  @OneToMany(() => AffiliateEarningEntity, earning => earning.offer)
  earnings: AffiliateEarningEntity[];

  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({
    type: 'timestamp with time zone',
    default: () => 'CURRENT_TIMESTAMP',
    onUpdate: 'CURRENT_TIMESTAMP',
  })
  updatedAt: Date;
}
