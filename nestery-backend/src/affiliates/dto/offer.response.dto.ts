import { ApiProperty } from '@nestjs/swagger';
import { AffiliateOfferEntity, CommissionStructure } from '../entities/affiliate-offer.entity';

export class OfferResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  partnerId: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  description: string;

  @ApiProperty({ type: 'object', additionalProperties: true })
  commissionStructure: CommissionStructure; // JSONB

  @ApiProperty()
  validFrom: Date;

  @ApiProperty()
  validTo: Date;

  @ApiProperty()
  termsConditions: string;

  @ApiProperty()
  isActive: boolean;

  @ApiProperty({ required: false, nullable: true })
  originalUrl?: string | null;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;

  static fromEntity(entity: AffiliateOfferEntity): OfferResponseDto {
    const dto = new OfferResponseDto();
    dto.id = entity.id;
    dto.partnerId = entity.partnerId;
    dto.title = entity.title;
    dto.description = entity.description;
    dto.commissionStructure = entity.commissionStructure;
    dto.validFrom = entity.validFrom;
    dto.validTo = entity.validTo;
    dto.termsConditions = entity.termsConditions;
    dto.isActive = entity.isActive;
    dto.originalUrl = entity.originalUrl;
    dto.createdAt = entity.createdAt;
    dto.updatedAt = entity.updatedAt;
    return dto;
  }
}
