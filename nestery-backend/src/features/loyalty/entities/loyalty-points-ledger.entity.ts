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
 * LoyaltyPointsLedger entity for auditable tracking of loyalty points
 * FRS-specific entity for more detailed points tracking
 * Compliant with FRS specifications
 */
@Entity('loyalty_points_ledger')
export class LoyaltyPointsLedger {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({
    type: 'enum',
    enum: ['earned', 'redeemed', 'expired', 'adjusted', 'bonus', 'referral']
  })
  type: string;

  @Column({ type: 'int' })
  amount: number;

  @Column({ name: 'running_balance', type: 'int' })
  runningBalance: number;

  @Column({ length: 255 })
  description: string;

  @Column({ name: 'reference_id', length: 255, nullable: true })
  referenceId: string;

  @Column({ name: 'reference_type', length: 50, nullable: true })
  referenceType: string;

  @Column({ name: 'expiry_date', type: 'date', nullable: true })
  expiryDate: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

// Export for tests
export { LoyaltyPointsLedger as LoyaltyPointsLedgerEntity };
