import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsDate,
  IsOptional,
  IsBoolean,
  IsUrl,
  MinLength,
  MaxLength,
  IsObject,
  ValidateIf,
} from 'class-validator';
import { Type } from 'class-transformer';

export class CreateOfferDto {
  @ApiProperty({ description: 'Title of the affiliate offer', example: '10% Off Summer Tours' })
  @IsString()
  @IsNotEmpty()
  @MinLength(5)
  @MaxLength(255)
  title: string;

  @ApiProperty({
    description: 'Detailed description of the offer',
    example: 'Get 10% off all summer tours booked through this link.',
  })
  @IsString()
  @IsNotEmpty()
  description: string;

  @ApiProperty({
    description: 'Commission structure for the offer',
    example: { type: 'percentage', value: 10 },
    oneOf: [
      {
        type: 'object',
        properties: { type: { type: 'string', enum: ['percentage'] }, value: { type: 'number' } },
      },
      {
        type: 'object',
        properties: { type: { type: 'string', enum: ['fixed'] }, value: { type: 'number' } },
      },
      {
        type: 'object',
        properties: {
          type: { type: 'string', enum: ['tiered'] },
          tiers: { type: 'array', items: { type: 'object' } },
        },
      },
    ],
  })
  @IsObject()
  // Detailed validation of the structure will be handled in the service
  commissionStructure:
    | { type: 'percentage'; value: number }
    | { type: 'fixed'; value: number }
    | {
        type: 'tiered';
        tiers: { threshold: number; value: number; valueType: 'percentage' | 'fixed' }[];
      };

  @ApiProperty({
    description: 'Date from which the offer is valid',
    example: '2025-06-01T00:00:00.000Z',
  })
  @IsDate()
  @Type(() => Date)
  validFrom: Date;

  @ApiProperty({
    description: 'Date until which the offer is valid',
    example: '2025-08-31T23:59:59.000Z',
  })
  @IsDate()
  @Type(() => Date)
  validTo: Date;

  @ApiProperty({
    description: 'Terms and conditions for the offer',
    example: 'Valid for new customers only. Cannot be combined with other offers.',
  })
  @IsString()
  @IsNotEmpty()
  termsConditions: string;

  @ApiProperty({
    description: 'Whether the offer is currently active',
    example: true,
    default: true,
  })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean = true;

  @ApiProperty({
    description: 'Original URL the partner wants users to be redirected to',
    example: 'https://partnertours.com/summer-special',
    required: false,
  })
  @IsOptional()
  @IsUrl()
  @ValidateIf(o => o.originalUrl !== null && o.originalUrl !== '') // Allow null or empty string to bypass IsUrl if not provided
  originalUrl?: string | null;
}
