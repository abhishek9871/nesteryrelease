import { IsOptional, IsEnum, IsUUID, IsDate, IsNumber, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

/**
 * Data Transfer Object for searching bookings
 */
export class SearchBookingsDto {
  @ApiProperty({
    description: 'User ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    required: false,
  })
  @IsOptional()
  @IsUUID()
  userId?: string;

  @ApiProperty({
    description: 'Property ID',
    example: '123e4567-e89b-12d3-a456-426614174000',
    required: false,
  })
  @IsOptional()
  @IsUUID()
  propertyId?: string;

  @ApiProperty({
    description: 'Booking status',
    example: 'confirmed',
    enum: ['pending', 'confirmed', 'cancelled', 'completed'],
    required: false,
  })
  @IsOptional()
  @IsEnum(['pending', 'confirmed', 'cancelled', 'completed'])
  status?: string;

  @ApiProperty({
    description: 'Start date for check-in range',
    example: '2025-06-01',
    required: false,
  })
  @IsOptional()
  @IsDate()
  @Type(() => Date)
  checkInDateStart?: Date;

  @ApiProperty({
    description: 'End date for check-in range',
    example: '2025-06-30',
    required: false,
  })
  @IsOptional()
  @IsDate()
  @Type(() => Date)
  checkInDateEnd?: Date;

  @ApiProperty({
    description: 'Page number for pagination',
    example: 1,
    default: 1,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  page?: number;

  @ApiProperty({
    description: 'Number of items per page',
    example: 10,
    default: 10,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  @Type(() => Number)
  limit?: number;
}
