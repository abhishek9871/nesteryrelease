import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * LoyaltyReward entity representing the loyalty_rewards table
 * Stores available loyalty rewards that users can redeem
 * Compliant with DATA_DICTIONARY.md specifications
 */
@Entity('loyalty_rewards')
export class LoyaltyReward {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  name: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ name: 'points_cost', type: 'int' })
  pointsCost: number;

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  @Column({ name: 'valid_until', type: 'date', nullable: true })
  validUntil: Date;

  // Relationships will be added when LoyaltyRedemption entity is created
  // @OneToMany(() => LoyaltyRedemption, redemption => redemption.reward)
  // redemptions: LoyaltyRedemption[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

// Export for tests
export { LoyaltyReward as LoyaltyRewardEntity };
