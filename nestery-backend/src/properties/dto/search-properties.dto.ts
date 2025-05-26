import { IsString, IsNumber, IsOptional, IsEnum, Min } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

/**
 * Data Transfer Object for searching properties
 */
export class SearchPropertiesDto {
  @ApiProperty({
    description: 'City to search in',
    example: 'New York',
    required: false,
  })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiProperty({
    description: 'Country to search in',
    example: 'USA',
    required: false,
  })
  @IsOptional()
  @IsString()
  country?: string;

  @ApiProperty({
    description: 'Minimum price per night',
    example: 50,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  minPrice?: number;

  @ApiProperty({
    description: 'Maximum price per night',
    example: 500,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  maxPrice?: number;

  @ApiProperty({
    description: 'Property type',
    example: 'hotel',
    enum: ['hotel', 'apartment', 'villa', 'resort', 'hostel', 'guesthouse'],
    required: false,
  })
  @IsOptional()
  @IsEnum(['hotel', 'apartment', 'villa', 'resort', 'hostel', 'guesthouse'])
  propertyType?: string;

  @ApiProperty({
    description: 'Star rating (1-5)',
    example: 4,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  starRating?: number;

  @ApiProperty({
    description: 'Page number for pagination',
    example: 1,
    required: false,
    default: 1,
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  page?: number;

  @ApiProperty({
    description: 'Number of results per page',
    example: 10,
    required: false,
    default: 10,
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Type(() => Number)
  limit?: number;
}
