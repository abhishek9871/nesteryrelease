import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../../users/entities/user.entity';
import { Booking } from '../../../bookings/entities/booking.entity';

/**
 * LoyaltyTransaction entity representing the loyalty_transactions table
 * Tracks loyalty point transactions for users
 * Compliant with DATA_DICTIONARY.md specifications
 */
@Entity('loyalty_transactions')
export class LoyaltyTransaction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'booking_id', nullable: true })
  bookingId: string;

  @ManyToOne(() => Booking, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'booking_id' })
  booking: Booking;

  @Column({
    type: 'enum',
    enum: ['earned', 'redeemed', 'expired', 'adjusted']
  })
  type: string;

  @Column({ type: 'int' })
  amount: number;

  @Column({ length: 255 })
  description: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

// Export for tests
export { LoyaltyTransaction as LoyaltyTransactionEntity };
