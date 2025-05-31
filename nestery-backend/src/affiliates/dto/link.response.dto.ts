import { ApiProperty } from '@nestjs/swagger';
import { AffiliateLinkEntity } from '../entities/affiliate-link.entity';

export class AffiliateLinkResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  offerId: string;

  @ApiProperty({ required: false, nullable: true })
  userId?: string | null;

  @ApiProperty()
  uniqueCode: string;

  @ApiProperty({ required: false, nullable: true })
  qrCodeDataUrl?: string | null;

  @ApiProperty()
  clicks: number;

  @ApiProperty()
  conversions: number;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;

  static fromEntity(entity: AffiliateLinkEntity): AffiliateLinkResponseDto {
    const dto = new AffiliateLinkResponseDto();
    Object.assign(dto, entity);
    return dto;
  }
}

export class GeneratedAffiliateLinkResponseDto {
  @ApiProperty({ type: () => AffiliateLinkResponseDto })
  linkEntity: AffiliateLinkResponseDto;
  @ApiProperty()
  fullTrackableUrl: string;
  @ApiProperty()
  qrCodeDataUrl: string;
}
