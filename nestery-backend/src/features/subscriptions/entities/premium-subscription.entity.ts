import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../../users/entities/user.entity';

/**
 * PremiumSubscription entity representing the premium_subscriptions table
 * Manages premium subscription details for users
 * FRS-specific entity for subscription management
 */
@Entity('premium_subscriptions')
export class PremiumSubscription {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({
    type: 'enum',
    enum: ['monthly', 'yearly'],
  })
  plan: string;

  @Column({
    type: 'enum',
    enum: ['active', 'cancelled', 'expired', 'pending'],
  })
  status: string;

  @Column({ name: 'start_date', type: 'date' })
  startDate: Date;

  @Column({ name: 'end_date', type: 'date' })
  endDate: Date;

  @Column({ name: 'price_paid', type: 'decimal', precision: 10, scale: 2 })
  pricePaid: number;

  @Column({ length: 3, default: 'USD' })
  currency: string;

  @Column({ name: 'payment_method', length: 50 })
  paymentMethod: string;

  @Column({ name: 'stripe_subscription_id', length: 255, nullable: true })
  stripeSubscriptionId: string;

  @Column({ name: 'auto_renew', type: 'boolean', default: true })
  autoRenew: boolean;

  @Column({ name: 'cancelled_at', type: 'timestamp', nullable: true })
  cancelledAt: Date;

  @Column({ name: 'cancellation_reason', length: 255, nullable: true })
  cancellationReason: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

// Export for tests
export { PremiumSubscription as PremiumSubscriptionEntity };
