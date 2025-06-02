import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { PartnerEntity } from './partner.entity';
import { AffiliateOfferEntity } from './affiliate-offer.entity';
import { AffiliateLinkEntity } from './affiliate-link.entity';
import { BookingEntity } from '../../bookings/entities/booking.entity';
import { UserEntity } from '../../users/entities/user.entity';
import { EarningStatusEnum } from '../enums/earning-status.enum';

// Re-export for convenience
export { EarningStatusEnum };

@Entity('affiliate_earnings')
export class AffiliateEarningEntity {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  partnerId: string;

  @ManyToOne(() => PartnerEntity, partner => partner.earnings, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'partnerId' })
  partner: PartnerEntity;

  @Column({ type: 'uuid' })
  offerId: string;

  @ManyToOne(() => AffiliateOfferEntity, offer => offer.earnings, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'offerId' })
  offer: AffiliateOfferEntity;

  @Column({ type: 'uuid', nullable: true })
  linkId?: string | null;

  @ManyToOne(() => AffiliateLinkEntity, link => link.earnings, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'linkId' })
  link?: AffiliateLinkEntity | null;

  // This field is not explicitly in the requirements but useful for direct user association if no link
  @Column({ type: 'uuid', nullable: true })
  userId?: string | null;

  @ManyToOne(() => UserEntity, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'userId' })
  user?: UserEntity | null;

  @Column({ type: 'uuid', nullable: true })
  bookingId?: string | null;

  @ManyToOne(() => BookingEntity, booking => booking.affiliateEarnings, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'bookingId' })
  booking?: BookingEntity | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  conversionReferenceId?: string | null;

  @Column({ type: 'numeric', precision: 12, scale: 2 })
  amountEarned: number;

  @Column({ type: 'varchar', length: 3 })
  currency: string;

  @Column({ type: 'timestamp with time zone' })
  transactionDate: Date;

  @Column({
    type: 'enum',
    enum: EarningStatusEnum,
    default: EarningStatusEnum.PENDING,
  })
  status: EarningStatusEnum;

  @Column({ type: 'text', nullable: true })
  notes?: string | null;

  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({
    type: 'timestamp with time zone',
    default: () => 'CURRENT_TIMESTAMP',
    onUpdate: 'CURRENT_TIMESTAMP',
  })
  updatedAt: Date;
}
