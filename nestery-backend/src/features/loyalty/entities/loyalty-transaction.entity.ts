import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../../users/entities/user.entity';
import { LoyaltyTransactionTypeEnum } from '../enums/loyalty-transaction-type.enum';

/**
 * LoyaltyTransaction entity representing the loyalty_transactions table
 * Tracks loyalty point transactions for users
 * FRS 1.4
 */
@Entity('loyalty_transactions')
export class LoyaltyTransaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({
    type: 'enum',
    enum: LoyaltyTransactionTypeEnum,
  })
  transactionType: LoyaltyTransactionTypeEnum;

  @Column({ type: 'int' })
  milesAmount: number;

  @Column({ length: 255, nullable: true })
  description?: string;

  @Column({ name: 'related_booking_id', type: 'uuid', nullable: true })
  relatedBookingId?: string;

  @Column({ name: 'related_referral_id', type: 'uuid', nullable: true })
  relatedReferralId?: string;

  @Column({ name: 'related_subscription_id', type: 'uuid', nullable: true })
  relatedSubscriptionId?: string;

  @Column({ name: 'related_review_id', type: 'uuid', nullable: true })
  relatedReviewId?: string;

  @Column({ name: 'related_partner_offer_id', type: 'uuid', nullable: true })
  relatedPartnerOfferId?: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

// Export for tests
export { LoyaltyTransaction as LoyaltyTransactionEntity };
