import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { User } from '../../users/entities/user.entity';
import { Booking } from '../../bookings/entities/booking.entity';

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

  @Column('float')
  latitude: number;

  @Column('float')
  longitude: number;

  @Column()
  type: string;

  @Column('float')
  pricePerNight: number;

  @Column('float')
  basePrice: number;

  @Column({ default: 'USD' })
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

  @Column('float', { nullable: true })
  rating: number;

  @Column('int', { default: 0 })
  reviewCount: number;

  @Column({ default: true })
  isActive: boolean;

  @Column({ nullable: true })
  hostId: string;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'hostId' })
  host: User;

  @OneToMany(() => Booking, booking => booking.property)
  bookings: Booking[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

// Export for tests
export { Property as PropertyEntity };
