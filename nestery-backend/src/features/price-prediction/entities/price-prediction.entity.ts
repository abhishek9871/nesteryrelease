import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Property } from '../../../properties/entities/property.entity';

/**
 * PricePrediction entity representing the price_predictions table
 * Stores price prediction data for properties
 * Compliant with DATA_DICTIONARY.md specifications
 */
@Entity('price_predictions')
export class PricePrediction {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'property_id' })
  propertyId: string;

  @ManyToOne(() => Property, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'property_id' })
  property: Property;

  @Column({ type: 'date' })
  date: Date;

  @Column({ name: 'predicted_price', type: 'decimal', precision: 10, scale: 2 })
  predictedPrice: number;

  @Column({ type: 'decimal', precision: 5, scale: 4 })
  confidence: number;

  @Column({
    type: 'enum',
    enum: ['rising', 'falling', 'stable']
  })
  trend: string;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;
}

// Export for tests
export { PricePrediction as PricePredictionEntity };
