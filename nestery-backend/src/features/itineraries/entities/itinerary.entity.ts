import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../../users/entities/user.entity';

/**
 * Itinerary entity representing the itineraries table
 * Stores user-created travel itineraries
 * FRS-specific entity for AI Trip Weaver feature
 */
@Entity('itineraries')
export class Itinerary {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id' })
  userId: string;

  @ManyToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'user_id' })
  user: User;

  @Column({ length: 255 })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ length: 100 })
  destination: string;

  @Column({ name: 'start_date', type: 'date' })
  startDate: Date;

  @Column({ name: 'end_date', type: 'date' })
  endDate: Date;

  @Column({ name: 'number_of_travelers', type: 'int' })
  numberOfTravelers: number;

  @Column({ name: 'budget_min', type: 'decimal', precision: 10, scale: 2, nullable: true })
  budgetMin: number;

  @Column({ name: 'budget_max', type: 'decimal', precision: 10, scale: 2, nullable: true })
  budgetMax: number;

  @Column({ length: 3, default: 'USD' })
  currency: string;

  @Column({ type: 'text', array: true, nullable: true })
  interests: string[];

  @Column({
    type: 'enum',
    enum: ['draft', 'published', 'shared', 'archived'],
    default: 'draft',
  })
  status: string;

  @Column({ name: 'is_ai_generated', type: 'boolean', default: false })
  isAiGenerated: boolean;

  @Column({ name: 'share_token', length: 255, nullable: true, unique: true })
  shareToken: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata: object;

  // Relationships will be added when ItineraryItem entity is created
  // @OneToMany(() => ItineraryItem, item => item.itinerary)
  // items: ItineraryItem[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

// Export for tests
export { Itinerary as ItineraryEntity };
