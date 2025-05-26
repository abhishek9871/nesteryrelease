import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Exclude } from 'class-transformer';

/**
 * User entity representing the users table in the database
 */
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  @Exclude({ toPlainOnly: true })
  password: string;

  @Column()
  name: string;

  @Column({ nullable: true })
  firstName: string;

  @Column({ nullable: true })
  lastName: string;

  @Column({ default: 'user' })
  role: string;

  @Column({ nullable: true })
  profilePicture: string;

  @Column({ nullable: true })
  phoneNumber: string;

  @Column({ default: false })
  isPremium: boolean;

  @Column({ default: 0 })
  loyaltyPoints: number;

  @Column({ nullable: true })
  lastLoginAt: Date;

  @Column({ nullable: true, unique: true })
  referralCode: string;

  @Column({ nullable: true })
  referredBy: string;

  @Column({ default: false })
  hasCompletedBooking: boolean;

  @OneToMany(() => User, user => user.referrer)
  referredUsers: User[];

  @ManyToOne(() => User, user => user.referredUsers, { nullable: true })
  @JoinColumn({ name: 'referredBy' })
  referrer: User;

  // Commented out to avoid circular dependency
  // Will be properly set up when Booking entity is available
  // @OneToMany(() => Booking, booking => booking.user)
  // bookings: Booking[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}

// Export for tests
export { User as UserEntity };
