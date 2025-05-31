import { ApiProperty } from '@nestjs/swagger';
import { EarningStatusEnum } from '../enums/earning-status.enum';
import { AffiliateEarningEntity } from '../entities/affiliate-earning.entity';

export class AffiliateEarningResponseDto {
  @ApiProperty()
  id: string;

  @ApiProperty()
  partnerId: string;

  @ApiProperty()
  offerId: string;

  @ApiProperty({ required: false, nullable: true })
  linkId?: string | null;

  @ApiProperty({ required: false, nullable: true })
  bookingId?: string | null;

  @ApiProperty({ required: false, nullable: true })
  conversionReferenceId?: string | null;

  @ApiProperty({ type: 'number' })
  amountEarned: number;

  @ApiProperty()
  currency: string;

  @ApiProperty()
  transactionDate: Date;

  @ApiProperty({ enum: EarningStatusEnum })
  status: EarningStatusEnum;

  @ApiProperty({ required: false, nullable: true })
  notes?: string | null;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;

  static fromEntity(entity: AffiliateEarningEntity): AffiliateEarningResponseDto {
    const dto = new AffiliateEarningResponseDto();
    Object.assign(dto, entity);
    // Ensure numeric types are numbers
    dto.amountEarned = Number(entity.amountEarned);
    return dto;
  }

  static fromEntities(entities: AffiliateEarningEntity[]): AffiliateEarningResponseDto[] {
    return entities.map(entity => this.fromEntity(entity));
  }
}
