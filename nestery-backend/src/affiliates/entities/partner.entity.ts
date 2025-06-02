import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { PartnerCategoryEnum } from '../enums/partner-category.enum';
import { AffiliateOfferEntity } from './affiliate-offer.entity';
import { AffiliateEarningEntity } from './affiliate-earning.entity';

// Re-export for convenience
export { PartnerCategoryEnum };

export interface ContactInfo {
  email: string;
  phone?: string;
  address?: string;
  website?: string;
}

@Entity('affiliate_partners')
export class PartnerEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({
    type: 'enum',
    enum: PartnerCategoryEnum,
  })
  category: PartnerCategoryEnum;

  @Column({ type: 'jsonb' })
  contactInfo: ContactInfo;

  @Column({ type: 'numeric', precision: 5, scale: 4, nullable: true })
  commissionRateOverride?: number | null; // e.g., 0.10 for 10%

  @Column({ type: 'boolean', default: true })
  isActive: boolean;

  @OneToMany(() => AffiliateOfferEntity, offer => offer.partner)
  offers: AffiliateOfferEntity[];

  @OneToMany(() => AffiliateEarningEntity, earning => earning.partner)
  earnings: AffiliateEarningEntity[];

  @CreateDateColumn({
    type: 'timestamp with time zone',
    default: () => 'CURRENT_TIMESTAMP',
  })
  createdAt: Date;

  @UpdateDateColumn({
    type: 'timestamp with time zone',
    default: () => 'CURRENT_TIMESTAMP',
    onUpdate: 'CURRENT_TIMESTAMP',
  })
  updatedAt: Date;
}
