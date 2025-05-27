import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Itinerary } from './itinerary.entity';
import { Property } from '../../../properties/entities/property.entity';

/**
 * ItineraryItem entity representing the itinerary_items table
 * Stores individual items within an itinerary
 * FRS-specific entity for AI Trip Weaver feature
 */
@Entity('itinerary_items')
export class ItineraryItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'itinerary_id' })
  itineraryId: string;

  @ManyToOne(() => Itinerary, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'itinerary_id' })
  itinerary: Itinerary;

  @Column({
    type: 'enum',
    enum: ['accommodation', 'activity', 'transport', 'dining', 'other']
  })
  type: string;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ name: 'day_number', type: 'int' })
  dayNumber: number;

  @Column({ name: 'start_time', type: 'time', nullable: true })
  startTime: string;

  @Column({ name: 'end_time', type: 'time', nullable: true })
  endTime: string;

  @Column({ name: 'estimated_cost', type: 'decimal', precision: 10, scale: 2, nullable: true })
  estimatedCost: number;

  @Column({ length: 3, default: 'USD' })
  currency: string;

  @Column({ length: 255, nullable: true })
  location: string;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  latitude: number;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  longitude: number;

  @Column({ name: 'property_id', nullable: true })
  propertyId: string;

  @ManyToOne(() => Property, { nullable: true, onDelete: 'SET NULL' })
  @JoinColumn({ name: 'property_id' })
  property: Property;

  @Column({ name: 'external_url', length: 255, nullable: true })
  externalUrl: string;

  @Column({ name: 'booking_reference', length: 100, nullable: true })
  bookingReference: string;

  @Column({ name: 'sort_order', type: 'int', default: 0 })
  sortOrder: number;

  @Column({ type: 'jsonb', nullable: true })
  metadata: object;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

// Export for tests
export { ItineraryItem as ItineraryItemEntity };
