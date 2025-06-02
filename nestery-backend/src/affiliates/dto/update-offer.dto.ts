import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsBoolean,
  IsDateString,
  IsObject,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { CommissionStructure } from '../entities/affiliate-offer.entity';

export class UpdateOfferDto {
  @ApiProperty({
    description: 'Title of the affiliate offer',
    example: 'Summer Adventure Tours - 20% Commission',
    required: false,
  })
  @IsString()
  @IsOptional()
  title?: string;

  @ApiProperty({
    description: 'Detailed description of the offer',
    example:
      'Promote our exciting summer adventure tours and earn 20% commission on every booking.',
    required: false,
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({
    description: 'Terms and conditions for the offer',
    example: 'Valid for bookings made between June 1 and August 31. Commission paid monthly.',
    required: false,
  })
  @IsString()
  @IsOptional()
  terms?: string;

  @ApiProperty({
    description: 'Start date for offer validity',
    example: '2024-06-01T00:00:00Z',
    required: false,
  })
  @IsDateString()
  @IsOptional()
  validFrom?: string;

  @ApiProperty({
    description: 'End date for offer validity',
    example: '2024-08-31T23:59:59Z',
    required: false,
  })
  @IsDateString()
  @IsOptional()
  validTo?: string;

  @ApiProperty({
    description: 'Whether the offer is currently active',
    example: true,
    required: false,
  })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @ApiProperty({
    description: 'Commission structure for the offer',
    example: {
      type: 'percentage',
      value: 20,
      currency: 'USD',
    },
    required: false,
  })
  @IsObject()
  @IsOptional()
  @ValidateNested()
  @Type(() => Object)
  commissionStructure?: CommissionStructure;

  @ApiProperty({
    description: 'Additional metadata for the offer',
    example: {
      targetAudience: 'adventure travelers',
      seasonality: 'summer',
      priority: 'high',
    },
    required: false,
  })
  @IsObject()
  @IsOptional()
  metadata?: Record<string, unknown>;
}
