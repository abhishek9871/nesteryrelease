import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../../users/entities/user.entity';

/**
 * Referral entity representing the referrals table
 * Tracks user referrals and their status
 * Compliant with DATA_DICTIONARY.md specifications
 */
@Entity('referrals')
export class Referral {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'referrer_id' })
  referrerId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'referrer_id' })
  referrer: User;

  @Column({ name: 'referred_id', nullable: true })
  referredId: string;

  @ManyToOne(() => User, { nullable: true, onDelete: 'CASCADE' })
  @JoinColumn({ name: 'referred_id' })
  referred: User;

  @Column({ name: 'referral_code', length: 50, unique: true })
  referralCode: string;

  @Column({
    type: 'enum',
    enum: ['pending', 'completed', 'expired'],
    default: 'pending',
  })
  status: string;

  @Column({ name: 'points_awarded', type: 'int', nullable: true })
  pointsAwarded: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @Column({ name: 'completed_at', type: 'timestamp', nullable: true })
  completedAt: Date;
}

// Export for tests
export { Referral as ReferralEntity };
