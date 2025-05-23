import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Property } from '../../properties/entities/property.entity';

/**
 * Booking entity representing the bookings table in the database
 */
@Entity('bookings')
export class Booking {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  propertyId: string;

  @ManyToOne(() => Property)
  @JoinColumn({ name: 'propertyId' })
  property: Property;

  @Column({ type: 'date' })
  checkInDate: Date;

  @Column({ type: 'date' })
  checkOutDate: Date;

  @Column('int')
  numberOfGuests: number;

  @Column('decimal', { precision: 10, scale: 2 })
  totalPrice: number;

  @Column()
  currency: string;

  @Column({
    type: 'enum',
    enum: ['pending', 'confirmed', 'cancelled', 'completed'],
    default: 'pending',
  })
  status: string;

  @Column({ nullable: true })
  confirmationCode: string;

  @Column({ nullable: true })
  cancellationReason: string;

  @Column({ default: false })
  isPaid: boolean;

  @Column({ nullable: true })
  paymentMethod: string;

  @Column({ nullable: true })
  paymentTransactionId: string;

  @Column({ default: false })
  isRefunded: boolean;

  @Column({ default: 0 })
  loyaltyPointsEarned: number;

  @Column({ default: 0 })
  loyaltyPointsRedeemed: number;

  @Column({ default: false })
  isPremiumBooking: boolean;

  @Column({ nullable: true })
  specialRequests: string;

  @Column({ nullable: true })
  sourceType: string; // 'booking_com', 'oyo', 'direct', etc.

  @Column({ nullable: true })
  externalBookingId: string;

  @Column('jsonb', { nullable: true })
  metadata: Record<string, any>; // Additional metadata

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
