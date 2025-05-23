import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, ManyToOne, OneToMany } from 'typeorm';

/**
 * Property entity representing the properties table in the database
 */
@Entity('properties')
export class Property {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  name: string;

  @Column()
  description: string;

  @Column()
  address: string;

  @Column()
  city: string;

  @Column()
  state: string;

  @Column()
  country: string;

  @Column()
  zipCode: string;

  @Column('decimal', { precision: 10, scale: 6 })
  latitude: number;

  @Column('decimal', { precision: 10, scale: 6 })
  longitude: number;

  @Column()
  propertyType: string;

  @Column('int')
  starRating: number;

  @Column('decimal', { precision: 10, scale: 2 })
  basePrice: number;

  @Column()
  currency: string;

  @Column('int')
  maxGuests: number;

  @Column('int')
  bedrooms: number;

  @Column('int')
  bathrooms: number;

  @Column('simple-array', { nullable: true })
  amenities: string[];

  @Column('simple-array', { nullable: true })
  images: string[];

  @Column({ nullable: true })
  thumbnailImage: string;

  @Column({ default: true })
  isActive: boolean;

  @Column()
  sourceType: string; // 'booking_com', 'oyo', etc.

  @Column()
  externalId: string; // ID from the source system

  @Column({ nullable: true })
  externalUrl: string; // URL to the property on the source system

  @Column('jsonb', { nullable: true })
  metadata: Record<string, any>; // Additional metadata from the source

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relationships will be added as needed
  // @OneToMany(() => Room, room => room.property)
  // rooms: Room[];

  // @OneToMany(() => Booking, booking => booking.property)
  // bookings: Booking[];
}
