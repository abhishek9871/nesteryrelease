import { IsString, IsNumber, IsOptional, IsEnum, Min, Max, IsArray, ValidateNested, IsUrl, IsBoolean } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

/**
 * Data Transfer Object for creating a property
 */
export class CreatePropertyDto {
  @ApiProperty({
    description: 'Property name',
    example: 'Luxury Ocean View Suite',
  })
  @IsString()
  name: string;

  @ApiProperty({
    description: 'Property description',
    example: 'A beautiful ocean view suite with modern amenities',
  })
  @IsString()
  description: string;

  @ApiProperty({
    description: 'Property address',
    example: '123 Beach Road',
  })
  @IsString()
  address: string;

  @ApiProperty({
    description: 'Property city',
    example: 'Miami',
  })
  @IsString()
  city: string;

  @ApiProperty({
    description: 'Property state/province',
    example: 'Florida',
  })
  @IsString()
  state: string;

  @ApiProperty({
    description: 'Property country',
    example: 'USA',
  })
  @IsString()
  country: string;

  @ApiProperty({
    description: 'Property zip/postal code',
    example: '33139',
  })
  @IsString()
  zipCode: string;

  @ApiProperty({
    description: 'Property latitude',
    example: 25.7617,
  })
  @IsNumber()
  latitude: number;

  @ApiProperty({
    description: 'Property longitude',
    example: -80.1918,
  })
  @IsNumber()
  longitude: number;

  @ApiProperty({
    description: 'Property type',
    example: 'hotel',
    enum: ['hotel', 'apartment', 'villa', 'resort', 'hostel', 'guesthouse'],
  })
  @IsEnum(['hotel', 'apartment', 'villa', 'resort', 'hostel', 'guesthouse'])
  propertyType: string;

  @ApiProperty({
    description: 'Property star rating (1-5)',
    example: 4,
  })
  @IsNumber()
  @Min(1)
  @Max(5)
  starRating: number;

  @ApiProperty({
    description: 'Base price per night',
    example: 199.99,
  })
  @IsNumber()
  @Min(0)
  basePrice: number;

  @ApiProperty({
    description: 'Currency code',
    example: 'USD',
  })
  @IsString()
  currency: string;

  @ApiProperty({
    description: 'Maximum number of guests',
    example: 4,
  })
  @IsNumber()
  @Min(1)
  maxGuests: number;

  @ApiProperty({
    description: 'Number of bedrooms',
    example: 2,
  })
  @IsNumber()
  @Min(0)
  bedrooms: number;

  @ApiProperty({
    description: 'Number of bathrooms',
    example: 2,
  })
  @IsNumber()
  @Min(0)
  bathrooms: number;

  @ApiProperty({
    description: 'List of amenities',
    example: ['wifi', 'pool', 'gym', 'breakfast'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  amenities?: string[];

  @ApiProperty({
    description: 'List of image URLs',
    example: ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
    required: false,
  })
  @IsOptional()
  @IsArray()
  @IsUrl({}, { each: true })
  images?: string[];

  @ApiProperty({
    description: 'Thumbnail image URL',
    example: 'https://example.com/thumbnail.jpg',
    required: false,
  })
  @IsOptional()
  @IsUrl()
  thumbnailImage?: string;

  @ApiProperty({
    description: 'Whether the property is active',
    example: true,
    required: false,
    default: true,
  })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiProperty({
    description: 'Source type (booking_com, oyo, etc.)',
    example: 'booking_com',
  })
  @IsString()
  sourceType: string;

  @ApiProperty({
    description: 'External ID from the source system',
    example: '12345678',
  })
  @IsString()
  externalId: string;

  @ApiProperty({
    description: 'External URL to the property on the source system',
    example: 'https://www.booking.com/hotel/us/example.html',
    required: false,
  })
  @IsOptional()
  @IsUrl()
  externalUrl?: string;

  @ApiProperty({
    description: 'Additional metadata from the source',
    example: { rating: 8.5, reviewCount: 120 },
    required: false,
  })
  @IsOptional()
  metadata?: Record<string, any>;
}
