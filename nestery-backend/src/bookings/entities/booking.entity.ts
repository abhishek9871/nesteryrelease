import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Property } from '../../properties/entities/property.entity';

import { AffiliateEarningEntity } from '../../affiliates/entities/affiliate-earning.entity';

/**
 * Booking entity representing the bookings table in the database
 * Compliant with FRS and DATA_DICTIONARY.md specifications
 */
@Entity('bookings')
export class Booking {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ name: 'property_id' })
  propertyId: string;

  @ManyToOne(() => Property, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'property_id' })
  property: Property;

  @Column({ name: 'check_in_date', type: 'date' })
  checkInDate: Date;

  @Column({ name: 'check_out_date', type: 'date' })
  checkOutDate: Date;

  @Column({ name: 'number_of_guests', type: 'int' })
  numberOfGuests: number;

  @Column({ name: 'total_price', type: 'decimal', precision: 10, scale: 2 })
  totalPrice: number;

  @Column({ length: 3, default: 'USD' })
  currency: string;

  @Column({
    type: 'enum',
    enum: ['confirmed', 'completed', 'cancelled'],
    default: 'confirmed',
  })
  status: string;

  @Column({ name: 'confirmation_code', length: 50 })
  confirmationCode: string;

  @Column({ name: 'special_requests', type: 'text', nullable: true })
  specialRequests: string;

  @Column({
    name: 'payment_method',
    type: 'enum',
    enum: ['credit_card', 'paypal', 'points'],
  })
  paymentMethod: string;

  @Column({ name: 'payment_details', type: 'jsonb', nullable: true })
  paymentDetails: object;

  @Column({ name: 'loyalty_points_earned', type: 'int', default: 0 })
  loyaltyPointsEarned: number;

  @Column({
    name: 'source_type',
    type: 'enum',
    enum: ['internal', 'booking', 'oyo'],
    default: 'internal',
  })
  sourceType: string;

  @Column({ name: 'external_booking_id', length: 100, nullable: true })
  externalBookingId: string;

  // FRS-specific fields for supplier integration
  @Column({ name: 'supplier_id', nullable: true })
  supplierId: string;

  @Column({ name: 'supplier_booking_reference', length: 100, nullable: true })
  supplierBookingReference: string;

  // Relationships will be added when other entities are created
  // @ManyToOne(() => Supplier, { nullable: true })
  // @JoinColumn({ name: 'supplier_id' })
  // supplier: Supplier;

  @OneToMany(() => AffiliateEarningEntity, (earning) => earning.booking)
  affiliateEarnings: AffiliateEarningEntity[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

// Export for tests
export { Booking as BookingEntity };
