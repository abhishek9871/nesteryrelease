import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

/**
 * Supplier entity representing the suppliers table
 * Manages information about OTA partners and API aggregators
 * FRS-specific entity for supplier integration
 */
@Entity('suppliers')
export class Supplier {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ length: 100 })
  name: string;

  @Column({
    type: 'enum',
    enum: ['booking', 'oyo', 'goibibo', 'makemytrip', 'agoda', 'expedia', 'other'],
  })
  type: string;

  @Column({ name: 'api_endpoint', length: 255, nullable: true })
  apiEndpoint: string;

  @Column({ name: 'api_key', length: 255, nullable: true })
  apiKey: string;

  @Column({ name: 'commission_rate', type: 'decimal', precision: 5, scale: 4, nullable: true })
  commissionRate: number;

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  @Column({ type: 'jsonb', nullable: true })
  configuration: object;

  @Column({ name: 'contact_email', length: 255, nullable: true })
  contactEmail: string;

  @Column({ name: 'contact_phone', length: 20, nullable: true })
  contactPhone: string;

  // Relationships will be added when other entities are created
  // @OneToMany(() => SupplierProperty, supplierProperty => supplierProperty.supplier)
  // supplierProperties: SupplierProperty[];

  // @OneToMany(() => Booking, booking => booking.supplier)
  // bookings: Booking[];

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

// Export for tests
export { Supplier as SupplierEntity };
