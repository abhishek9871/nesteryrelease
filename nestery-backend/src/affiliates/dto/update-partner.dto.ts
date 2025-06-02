import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsEnum,
  IsObject,
  IsNumber,
  IsBoolean,
  Min,
  Max,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { PartnerCategoryEnum } from '../entities/partner.entity';

class ContactInfoDto {
  @ApiProperty({ description: 'Email address', example: 'contact@partner.com' })
  @IsString()
  @IsOptional()
  email?: string;

  @ApiProperty({ description: 'Phone number', example: '+1-555-0123' })
  @IsString()
  @IsOptional()
  phone?: string;

  @ApiProperty({ description: 'Website URL', example: 'https://partner.com' })
  @IsString()
  @IsOptional()
  website?: string;

  @ApiProperty({ description: 'Physical address', example: '123 Main St, City, State 12345' })
  @IsString()
  @IsOptional()
  address?: string;

  @ApiProperty({ description: 'Primary contact person name', example: 'John Doe' })
  @IsString()
  @IsOptional()
  contactPerson?: string;
}

export class UpdatePartnerDto {
  @ApiProperty({
    description: 'Name of the affiliate partner',
    example: 'Awesome Tour Company',
    required: false,
  })
  @IsString()
  @IsOptional()
  name?: string;

  @ApiProperty({
    description: 'Category of the partner',
    enum: PartnerCategoryEnum,
    example: PartnerCategoryEnum.TOUR_OPERATOR,
    required: false,
  })
  @IsEnum(PartnerCategoryEnum)
  @IsOptional()
  category?: PartnerCategoryEnum;

  @ApiProperty({ description: 'Contact information for the partner', required: false })
  @IsObject()
  @IsOptional()
  @ValidateNested()
  @Type(() => ContactInfoDto)
  contactInfo?: ContactInfoDto;

  @ApiProperty({
    description: 'Optional override for commission rate (e.g., 0.1 for 10%)',
    example: 0.15,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1) // Assuming rate is between 0 and 1
  commissionRateOverride?: number;

  @ApiProperty({ description: 'Whether the partner is active', example: true, required: false })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean;
}
