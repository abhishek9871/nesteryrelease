import { PartialType, OmitType } from '@nestjs/swagger';
import { IsString, IsOptional, MinLength, MaxLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { CreateUserDto } from './create-user.dto';

/**
 * Data Transfer Object for updating a user
 * Extends CreateUserDto but makes all fields optional and omits email and password
 */
export class UpdateUserDto extends PartialType(OmitType(CreateUserDto, ['email', 'password', 'role'] as const)) {
  @ApiProperty({
    description: 'User profile picture URL',
    example: 'https://example.com/profile.jpg',
    required: false,
  })
  @IsOptional()
  @IsString()
  profilePicture?: string;

  @ApiProperty({
    description: 'User phone number',
    example: '+1234567890',
    required: false,
  })
  @IsOptional()
  @IsString()
  @MinLength(10, { message: 'Phone number must be at least 10 characters long' })
  @MaxLength(20, { message: 'Phone number must not exceed 20 characters' })
  phoneNumber?: string;
}
