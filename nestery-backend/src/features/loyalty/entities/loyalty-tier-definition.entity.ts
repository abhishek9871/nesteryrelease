import { Entity, Column, PrimaryColumn } from 'typeorm';
import { LoyaltyTierEnum } from '../enums/loyalty-tier.enum';

@Entity('loyalty_tier_definitions')
export class LoyaltyTierDefinitionEntity {
  @PrimaryColumn({
    type: 'enum',
    enum: LoyaltyTierEnum,
  })
  tier: LoyaltyTierEnum;

  @Column({ length: 100 })
  name: string;

  @Column({ name: 'min_miles_required', type: 'int' })
  minMilesRequired: number;

  @Column({ name: 'earning_multiplier', type: 'decimal', precision: 3, scale: 2 })
  earningMultiplier: number;

  @Column({ name: 'benefits_description', type: 'text', nullable: true })
  benefitsDescription?: string;
}

// Export for tests and consistency with other entities
export { LoyaltyTierDefinitionEntity as LoyaltyTierDefinition };
