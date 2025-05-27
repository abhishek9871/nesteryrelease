import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Supplier } from './supplier.entity';
import { NesteryMasterProperty } from '../../properties/entities/nestery-master-property.entity';

/**
 * SupplierProperty entity representing the supplier_properties table
 * Maps supplier-specific property data to NesteryMasterProperties
 * FRS-specific entity for supplier property mapping
 */
@Entity('supplier_properties')
export class SupplierProperty {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'supplier_id' })
  supplierId: string;

  @ManyToOne(() => Supplier, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'supplier_id' })
  supplier: Supplier;

  @Column({ name: 'nestery_master_property_id' })
  nesteryMasterPropertyId: string;

  @ManyToOne(() => NesteryMasterProperty, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'nestery_master_property_id' })
  nesteryMasterProperty: NesteryMasterProperty;

  @Column({ name: 'supplier_native_property_id', length: 255 })
  supplierNativePropertyId: string;

  @Column({ name: 'supplier_property_name', length: 255 })
  supplierPropertyName: string;

  @Column({ name: 'supplier_property_url', length: 255, nullable: true })
  supplierPropertyUrl: string;

  @Column({ name: 'base_price', type: 'decimal', precision: 10, scale: 2, nullable: true })
  basePrice: number;

  @Column({ length: 3, default: 'USD' })
  currency: string;

  @Column({ name: 'last_sync_at', type: 'timestamp', nullable: true })
  lastSyncAt: Date;

  @Column({ name: 'is_active', type: 'boolean', default: true })
  isActive: boolean;

  @Column({ type: 'jsonb', nullable: true })
  metadata: object;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}

// Export for tests
export { SupplierProperty as SupplierPropertyEntity };
