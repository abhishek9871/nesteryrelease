import { ApiProperty } from '@nestjs/swagger';
import { LoyaltyTierEnum } from '../../features/loyalty/enums/loyalty-tier.enum';

/**
 * Data Transfer Object for user profile responses
 * Used for /users/me and other user profile endpoints
 */
export class UserProfileDto {
  @ApiProperty({
    description: 'User unique identifier',
    example: 'uuid-string',
  })
  id: string;

  @ApiProperty({
    description: 'User email address',
    example: 'user@example.com',
  })
  email: string;

  @ApiProperty({
    description: 'User first name',
    example: 'John',
  })
  firstName: string;

  @ApiProperty({
    description: 'User last name',
    example: 'Doe',
  })
  lastName: string;

  @ApiProperty({
    description: 'User role',
    example: 'user',
  })
  role: string;

  @ApiProperty({
    description: 'User profile picture URL',
    example: 'https://example.com/profile.jpg',
    required: false,
  })
  profilePicture?: string;

  @ApiProperty({
    description: 'User phone number',
    example: '+1234567890',
    required: false,
  })
  phoneNumber?: string;

  @ApiProperty({
    description: 'User loyalty tier',
    enum: LoyaltyTierEnum,
    example: LoyaltyTierEnum.SCOUT,
  })
  loyaltyTier: LoyaltyTierEnum;

  @ApiProperty({
    description: 'User loyalty points',
    example: 1500,
  })
  loyaltyPoints: number;

  @ApiProperty({
    description: 'Whether the user has an active premium subscription',
    example: true,
  })
  isPremium: boolean;

  @ApiProperty({
    description: 'User account creation date',
    example: '2025-01-01T00:00:00.000Z',
  })
  createdAt: Date;
}
