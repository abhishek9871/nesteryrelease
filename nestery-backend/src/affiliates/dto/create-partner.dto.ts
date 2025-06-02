import { ApiProperty } from '@nestjs/swagger';
import {
  IsString,
  IsNotEmpty,
  IsEnum,
  IsObject,
  IsOptional,
  IsNumber,
  Min,
  Max,
  IsBoolean,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { PartnerCategoryEnum } from '../enums/partner-category.enum';

class ContactInfoDto {
  @ApiProperty({ example: 'partner@example.com' })
  @IsString()
  @IsNotEmpty()
  email: string;

  @ApiProperty({ example: '+1234567890', required: false })
  @IsOptional()
  @IsString()
  phone?: string;
}

export class CreatePartnerDto {
  @ApiProperty({ description: 'Name of the affiliate partner', example: 'Awesome Tour Company' })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    description: 'Category of the partner',
    enum: PartnerCategoryEnum,
    example: PartnerCategoryEnum.TOUR_OPERATOR,
  })
  @IsEnum(PartnerCategoryEnum)
  category: PartnerCategoryEnum;

  @ApiProperty({ description: 'Contact information for the partner' })
  @IsObject()
  @ValidateNested()
  @Type(() => ContactInfoDto)
  contactInfo: ContactInfoDto;

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

  @ApiProperty({ description: 'Whether the partner is active', example: true, default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean = true;
}
