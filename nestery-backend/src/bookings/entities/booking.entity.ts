import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Property } from '../../properties/entities/property.entity';

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

  @Column()
  checkInDate: Date;

  @Column()
  checkOutDate: Date;

  @Column('float')
  totalPrice: number;

  @Column({ default: 'USD' })
  currency: string;

  @Column({ default: 'pending' })
  status: string;

  @Column('int', { name: 'guest_count' })
  guestCount: number;

  @Column('int', { name: 'number_of_guests', nullable: true })
  numberOfGuests: number;

  @Column({ nullable: true })
  specialRequests: string;

  @Column({ default: false })
  isCancelled: boolean;

  @Column({ nullable: true })
  cancellationReason: string;

  @Column({ nullable: true })
  cancellationDate: Date;

  @Column({ default: false })
  isRefunded: boolean;

  @Column('float', { nullable: true })
  refundAmount: number;

  @Column({ nullable: true })
  paymentId: string;

  @Column({ nullable: true })
  paymentMethod: string;

  @Column({ default: false })
  isPaid: boolean;

  @Column({ nullable: true })
  paymentDate: Date;

  @Column({ nullable: true })
  confirmationCode: string;

  @Column('int', { default: 0 })
  loyaltyPointsEarned: number;

  @Column('int', { default: 0 })
  loyaltyPointsRedeemed: number;

  @Column({ default: false })
  isPremiumBooking: boolean;

  @Column({ default: 'direct' })
  sourceType: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

// Export for tests
export { Booking as BookingEntity };
