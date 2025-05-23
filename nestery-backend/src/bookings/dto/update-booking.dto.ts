import { PartialType } from '@nestjs/swagger';
import { CreateBookingDto } from './create-booking.dto';
import { IsEnum, IsOptional, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

/**
 * Data Transfer Object for updating a booking
 * Extends CreateBookingDto but makes all fields optional and adds status
 */
export class UpdateBookingDto extends PartialType(CreateBookingDto) {
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
    description: 'Cancellation reason',
    example: 'Change of plans',
    required: false,
  })
  @IsOptional()
  @IsString()
  cancellationReason?: string;
}
