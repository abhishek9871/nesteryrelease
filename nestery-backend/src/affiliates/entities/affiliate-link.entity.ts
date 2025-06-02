import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
  OneToMany,
} from 'typeorm';
import { AffiliateOfferEntity } from './affiliate-offer.entity';
import { UserEntity } from '../../users/entities/user.entity';
import { AffiliateEarningEntity } from './affiliate-earning.entity';

@Entity('affiliate_links')
@Index('idx_affiliate_link_unique_code', ['uniqueCode'], { unique: true })
export class AffiliateLinkEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  offerId: string;

  @ManyToOne(() => AffiliateOfferEntity, offer => offer.links, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'offerId' })
  offer: AffiliateOfferEntity;

  @Column({ type: 'uuid', nullable: true })
  userId?: string | null;

  @ManyToOne(() => UserEntity, user => user.affiliateLinks, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'userId' })
  user?: UserEntity | null;

  @Column({ type: 'varchar', length: 50, unique: true })
  uniqueCode: string;

  @Column({ type: 'text', nullable: true })
  qrCodeDataUrl?: string | null;

  @Column({ type: 'integer', default: 0 })
  clicks: number;

  @Column({ type: 'integer', default: 0 })
  conversions: number;

  @OneToMany(() => AffiliateEarningEntity, earning => earning.link)
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
