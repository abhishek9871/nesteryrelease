import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * NesteryMasterProperty entity representing the nestery_master_properties table
 * Single, canonical record for each unique physical property
 * FRS-specific entity for property de-duplication and normalization
 */
@Entity('nestery_master_properties')
export class NesteryMasterProperty {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 255 })
  name: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ length: 255 })
  address: string;

  @Column({ length: 100 })
  city: string;

  @Column({ length: 100, nullable: true })
  state: string;

  @Column({ length: 100 })
  country: string;

  @Column({ name: 'zip_code', length: 20, nullable: true })
  zipCode: string;

  @Column({ type: 'decimal', precision: 10, scale: 7 })
  latitude: number;

  @Column({ type: 'decimal', precision: 10, scale: 7 })
  longitude: number;

  @Column({
    name: 'property_type',
    type: 'enum',
    enum: ['hotel', 'apartment', 'resort', 'villa', 'hostel', 'guesthouse'],
  })
  propertyType: string;

  @Column({ name: 'star_rating', type: 'decimal', precision: 2, scale: 1, nullable: true })
  starRating: number;

  @Column({ name: 'max_guests', type: 'int' })
  maxGuests: number;

  @Column({ type: 'int', nullable: true })
  bedrooms: number;

  @Column({ type: 'int', nullable: true })
  bathrooms: number;

  @Column({ type: 'text', array: true, nullable: true })
  amenities: string[];

  @Column({ type: 'text', array: true, nullable: true })
  images: string[];

  @Column({ name: 'thumbnail_image', length: 255, nullable: true })
  thumbnailImage: string;

  @Column({ name: 'chain_affiliation', length: 100, nullable: true })
  chainAffiliation: string;

  @Column({ name: 'phone_number', length: 20, nullable: true })
  phoneNumber: string;

  @Column({ name: 'nestery_rating', type: 'decimal', precision: 3, scale: 2, nullable: true })
  nesteryRating: number;

  @Column({ name: 'review_count', type: 'int', default: 0 })
  reviewCount: number;

  @Column({ type: 'jsonb', nullable: true })
  metadata: object;

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  // Relationships will be added when other entities are created
  // @OneToMany(() => SupplierProperty, supplierProperty => supplierProperty.nesteryMasterProperty)
  // supplierProperties: SupplierProperty[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

// Export for tests
export { NesteryMasterProperty as NesteryMasterPropertyEntity };
