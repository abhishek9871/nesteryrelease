import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../../users/entities/user.entity';
import { LoyaltyReward } from './loyalty-reward.entity';

/**
 * LoyaltyRedemption entity representing the loyalty_redemptions table
 * Tracks redemption of loyalty rewards by users
 * Compliant with DATA_DICTIONARY.md specifications
 */
@Entity('loyalty_redemptions')
export class LoyaltyRedemption {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'reward_id' })
  rewardId: string;

  @ManyToOne(() => LoyaltyReward, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'reward_id' })
  reward: LoyaltyReward;

  @Column({ name: 'points_used', type: 'int' })
  pointsUsed: number;

  @Column({ name: 'redemption_code', length: 50 })
  redemptionCode: string;

  @Column({
    type: 'enum',
    enum: ['active', 'used', 'expired'],
    default: 'active'
  })
  status: string;

  @Column({ name: 'expiry_date', type: 'date', nullable: true })
  expiryDate: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @Column({ name: 'used_at', type: 'timestamp', nullable: true })
  usedAt: Date;
}

// Export for tests
export { LoyaltyRedemption as LoyaltyRedemptionEntity };
