import { IsString, IsNumber, IsOptional, IsEnum, Min, IsArray, IsBoolean } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty } from '@nestjs/swagger';

/**
 * Data Transfer Object for searching properties
 */
export class SearchPropertiesDto {
  @ApiProperty({
    description: 'City to search for',
    example: 'Miami',
    required: false,
  })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiProperty({
    description: 'Country to search for',
    example: 'USA',
    required: false,
  })
  @IsOptional()
  @IsString()
  country?: string;

  @ApiProperty({
    description: 'Minimum price per night',
    example: 100,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  minPrice?: number;

  @ApiProperty({
    description: 'Maximum price per night',
    example: 300,
    required: false,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
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
  @Type(() => Number)
  starRating?: number;

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
  @Type(() => Number)
  limit?: number;
}
