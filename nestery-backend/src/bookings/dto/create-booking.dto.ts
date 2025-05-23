import { IsString, IsDate, IsNumber, IsEnum, IsOptional, IsBoolean, Min, IsUUID } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

/**
 * Data Transfer Object for creating a booking
 */
export class CreateBookingDto {
  @ApiProperty({
    description: 'Property ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
  })
  @IsUUID()
  propertyId: string;

  @ApiProperty({
    description: 'Check-in date',
    example: '2025-06-15',
  })
  @IsDate()
  @Type(() => Date)
  checkInDate: Date;

  @ApiProperty({
    description: 'Check-out date',
    example: '2025-06-20',
  })
  @IsDate()
  @Type(() => Date)
  checkOutDate: Date;

  @ApiProperty({
    description: 'Number of guests',
    example: 2,
  })
  @IsNumber()
  @Min(1)
  numberOfGuests: number;

  @ApiProperty({
    description: 'Special requests',
    example: 'Late check-in, non-smoking room',
    required: false,
  })
  @IsOptional()
  @IsString()
  specialRequests?: string;

  @ApiProperty({
    description: 'Payment method',
    example: 'credit_card',
    required: false,
  })
  @IsOptional()
  @IsString()
  paymentMethod?: string;

  @ApiProperty({
    description: 'Loyalty points to redeem',
    example: 500,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  loyaltyPointsToRedeem?: number;

  @ApiProperty({
    description: 'Is premium booking',
    example: false,
    required: false,
  })
  @IsOptional()
  @IsBoolean()
  isPremiumBooking?: boolean;

  @ApiProperty({
    description: 'Source type',
    example: 'direct',
    required: false,
  })
  @IsOptional()
  @IsString()
  sourceType?: string;
}
