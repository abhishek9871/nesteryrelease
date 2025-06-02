import { ApiProperty } from '@nestjs/swagger';
import { PartnerCategoryEnum } from '../enums/partner-category.enum';
import { PartnerEntity, ContactInfo } from '../entities/partner.entity';

export class PartnerResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  name: string;

  @ApiProperty({ enum: PartnerCategoryEnum })
  category: PartnerCategoryEnum;

  @ApiProperty({ type: 'object', additionalProperties: true })
  contactInfo: ContactInfo; // JSONB

  @ApiProperty({ type: 'number', required: false, nullable: true })
  commissionRateOverride?: number | null;

  @ApiProperty()
  isActive: boolean;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;

  static fromEntity(entity: PartnerEntity): PartnerResponseDto {
    const dto = new PartnerResponseDto();
    dto.id = entity.id;
    dto.name = entity.name;
    dto.category = entity.category;
    dto.contactInfo = entity.contactInfo;
    dto.commissionRateOverride = entity.commissionRateOverride
      ? Number(entity.commissionRateOverride)
      : null;
    dto.isActive = entity.isActive;
    dto.createdAt = entity.createdAt;
    dto.updatedAt = entity.updatedAt;
    return dto;
  }
}
