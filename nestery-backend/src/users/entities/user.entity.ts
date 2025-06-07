import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { Exclude } from 'class-transformer';
import { LoyaltyTierEnum } from '../../features/loyalty/enums/loyalty-tier.enum';
import { AffiliateLinkEntity } from '../../affiliates/entities/affiliate-link.entity';
import { PartnerEntity } from '../../affiliates/entities/partner.entity';

/**
 * User entity representing the users table in the database
 * Compliant with FRS and DATA_DICTIONARY.md specifications
 */
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, length: 255 })
  email: string;

  @Column({ length: 255 })
  @Exclude({ toPlainOnly: true })
  password: string;

  @Column({ name: 'first_name', length: 100 })
  firstName: string;

  @Column({ name: 'last_name', length: 100 })
  lastName: string;

  @Column({ name: 'phone_number', length: 20, nullable: true })
  phoneNumber: string;

  @Column({ name: 'profile_picture', length: 255, nullable: true })
  profilePicture: string;

  @Column({
    type: 'enum',
    enum: ['user', 'admin', 'partner'],
    default: 'user',
  })
  role: string;

  @Column({ type: 'jsonb', nullable: true })
  preferences: object;

  @Column({ name: 'refresh_token', length: 255, nullable: true })
  refreshToken: string;

  @Column({ name: 'loyalty_miles_balance', type: 'int', default: 0 })
  loyaltyMilesBalance: number;

  @Column({
    name: 'loyalty_tier',
    type: 'enum',
    enum: LoyaltyTierEnum,
    default: LoyaltyTierEnum.SCOUT,
  })
  loyaltyTier: LoyaltyTierEnum;

  // Existing loyaltyPoints field, if it's different from loyaltyMilesBalance
  // If loyaltyMilesBalance is meant to replace loyaltyPoints, this should be removed or migrated.
  // For now, keeping it as per instruction "Add loyaltyMilesBalance"
  @Column({ name: 'loyalty_points', type: 'int', default: 0 }) // This might be legacy or for a different system
  loyaltyPoints: number; // This field was pre-existing in the provided structure.

  @Column({ name: 'auth_provider', length: 50, nullable: true })
  authProvider: string;

  @Column({ name: 'auth_provider_id', length: 255, nullable: true })
  authProviderId: string;

  @Column({ name: 'stripe_customer_id', length: 255, nullable: true })
  stripeCustomerId: string;

  @Column({ name: 'email_verified', type: 'boolean', default: false })
  emailVerified: boolean;

  @Column({ name: 'phone_verified', type: 'boolean', default: false })
  phoneVerified: boolean;

  // Relationships will be added when other entities are created
  // @OneToMany(() => Booking, booking => booking.user)
  // bookings: Booking[];

  // @OneToMany(() => LoyaltyTransaction, transaction => transaction.user)
  // loyaltyTransactions: LoyaltyTransaction[];

  // @OneToMany(() => Review, review => review.user)
  // reviews: Review[];

  // @OneToMany(() => Referral, referral => referral.referrer)
  // referrals: Referral[];

  @OneToMany(() => AffiliateLinkEntity, link => link.user)
  affiliateLinks: AffiliateLinkEntity[];

  // Partner relationship - only exists if user role is 'partner'
  @OneToOne(() => PartnerEntity, { nullable: true })
  @JoinColumn({ name: 'partner_id' })
  partner?: PartnerEntity;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

// Export for tests
export { User as UserEntity };
