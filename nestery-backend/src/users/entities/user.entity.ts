import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn, OneToMany } from 'typeorm';
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

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  // Relationships will be added as needed
  // @OneToMany(() => Booking, booking => booking.user)
  // bookings: Booking[];
}
