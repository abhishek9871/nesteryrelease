import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../../users/entities/user.entity';
import { Property } from '../../../properties/entities/property.entity';

/**
 * UserRecommendation entity representing the user_recommendations table
 * Stores personalized property recommendations for users
 * Compliant with DATA_DICTIONARY.md specifications
 */
@Entity('user_recommendations')
export class UserRecommendation {
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

  @Column({ type: 'decimal', precision: 5, scale: 4 })
  score: number;

  @Column({ length: 100, nullable: true })
  reason: string;

  @Column({ name: 'is_viewed', type: 'boolean', default: false })
  isViewed: boolean;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

// Export for tests
export { UserRecommendation as UserRecommendationEntity };
