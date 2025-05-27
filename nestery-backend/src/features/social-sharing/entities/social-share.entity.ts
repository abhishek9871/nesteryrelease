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
 * SocialShare entity representing the social_shares table
 * Tracks property shares on social media platforms
 * Compliant with DATA_DICTIONARY.md specifications
 */
@Entity('social_shares')
export class SocialShare {
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

  @Column({
    type: 'enum',
    enum: ['facebook', 'twitter', 'whatsapp', 'email'],
  })
  platform: string;

  @Column({ name: 'share_link', length: 255 })
  shareLink: string;

  @Column({ name: 'points_earned', type: 'int', default: 0 })
  pointsEarned: number;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

// Export for tests
export { SocialShare as SocialShareEntity };
