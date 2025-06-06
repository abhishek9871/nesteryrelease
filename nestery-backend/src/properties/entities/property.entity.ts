import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * Property entity representing the properties table in the database
 * Compliant with FRS and DATA_DICTIONARY.md specifications
 */
@Entity('properties')
export class Property {
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

  @Column({ name: 'base_price', type: 'decimal', precision: 10, scale: 2 })
  basePrice: number;

  @Column({ length: 3, default: 'USD' })
  currency: string;

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

  @Column({
    name: 'source_type',
    type: 'enum',
    enum: ['internal', 'booking', 'oyo'],
    default: 'internal',
  })
  sourceType: string;

  @Column({ name: 'external_id', length: 100, nullable: true })
  externalId: string;

  @Column({ name: 'external_url', length: 255, nullable: true })
  externalUrl: string;

  @Column({ type: 'jsonb', nullable: true })
  metadata: object;

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  // Relationships will be added when other entities are created
  // @OneToMany(() => Booking, booking => booking.property)
  // bookings: Booking[];

  // @OneToMany(() => Review, review => review.property)
  // reviews: Review[];

  // @OneToMany(() => PropertyAvailability, availability => availability.property)
  // availability: PropertyAvailability[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

// Export for tests
export { Property as PropertyEntity };
