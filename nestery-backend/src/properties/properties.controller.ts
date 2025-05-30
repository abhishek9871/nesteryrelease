import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { PropertiesService } from './properties.service';
import { CreatePropertyDto } from './dto/create-property.dto';
import { UpdatePropertyDto } from './dto/update-property.dto';
import { SearchPropertiesDto } from './dto/search-properties.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CacheInterceptor, CacheKey, CacheTTL } from '@nestjs/cache-manager';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { ApiTags, ApiOperation, ApiResponse, ApiParam, ApiQuery } from '@nestjs/swagger';

@ApiTags('properties')
@Controller('properties')
export class PropertiesController {
  constructor(private readonly propertiesService: PropertiesService) {}

  @Post()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('host', 'admin')
  @ApiOperation({ summary: 'Create a new property' })
  @ApiResponse({ status: 201, description: 'Property created successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - requires host or admin role' })
  create(@Body() createPropertyDto: CreatePropertyDto) {
    return this.propertiesService.create(createPropertyDto);
  }

  @Get()
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(3600 * 1000) // 1 hour in milliseconds
  @ApiOperation({ summary: 'Get all properties with pagination' })
  @ApiQuery({ name: 'page', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Properties retrieved successfully' })
  findAll(@Query('page') page?: number, @Query('limit') limit?: number) {
    return this.propertiesService.findAll(page, limit);
  }

  @Get('search')
  @ApiOperation({ summary: 'Search properties based on criteria' })
  @ApiResponse({ status: 200, description: 'Properties retrieved successfully' })
  search(@Query() searchDto: SearchPropertiesDto) {
    return this.propertiesService.search(searchDto);
  }

  @Get('featured')
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(3600 * 1000) // 1 hour in milliseconds
  @ApiOperation({ summary: 'Get featured properties' })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Featured properties retrieved successfully' })
  getFeaturedProperties(@Query('limit') limit?: number) {
    return this.propertiesService.getFeaturedProperties(limit);
  }

  @Get('trending')
  @UseInterceptors(CacheInterceptor)
  @CacheKey('trending_destinations')
  @CacheTTL(24 * 3600 * 1000) // 24 hours in milliseconds
  @ApiOperation({ summary: 'Get trending destinations' })
  @ApiResponse({ status: 200, description: 'Trending destinations retrieved successfully' })
  getTrendingDestinations() {
    return this.propertiesService.getTrendingDestinations();
  }

  @Get('nearby')
  @ApiOperation({ summary: 'Find properties near a location' })
  @ApiQuery({ name: 'latitude', required: true, type: Number })
  @ApiQuery({ name: 'longitude', required: true, type: Number })
  @ApiQuery({ name: 'radius', required: false, type: Number })
  @ApiQuery({ name: 'limit', required: false, type: Number })
  @ApiResponse({ status: 200, description: 'Nearby properties retrieved successfully' })
  findNearby(
    @Query('latitude') latitude: number,
    @Query('longitude') longitude: number,
    @Query('radius') radius?: number,
    @Query('limit') limit?: number,
  ) {
    return this.propertiesService.findNearby(latitude, longitude, radius, limit);
  }

  @Get(':id')
  @UseInterceptors(CacheInterceptor)
  @CacheTTL(6 * 3600 * 1000) // 6 hours in milliseconds
  @ApiOperation({ summary: 'Get a property by ID' })
  @ApiParam({ name: 'id', required: true, description: 'Property ID' })
  @ApiResponse({ status: 200, description: 'Property retrieved successfully' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  findById(@Param('id') id: string) {
    return this.propertiesService.findById(id);
  }

  @Patch(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('host', 'admin')
  @ApiOperation({ summary: 'Update a property' })
  @ApiParam({ name: 'id', required: true, description: 'Property ID' })
  @ApiResponse({ status: 200, description: 'Property updated successfully' })
  @ApiResponse({ status: 400, description: 'Bad request' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - requires host or admin role' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  update(@Param('id') id: string, @Body() updatePropertyDto: UpdatePropertyDto) {
    return this.propertiesService.update(id, updatePropertyDto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('host', 'admin')
  @ApiOperation({ summary: 'Remove a property' })
  @ApiParam({ name: 'id', required: true, description: 'Property ID' })
  @ApiResponse({ status: 200, description: 'Property removed successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - requires host or admin role' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  remove(@Param('id') id: string) {
    return this.propertiesService.remove(id);
  }

  @Patch(':id/availability')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('host', 'admin')
  @ApiOperation({ summary: 'Update property availability' })
  @ApiParam({ name: 'id', required: true, description: 'Property ID' })
  @ApiResponse({ status: 200, description: 'Property availability updated successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  @ApiResponse({ status: 403, description: 'Forbidden - requires host or admin role' })
  @ApiResponse({ status: 404, description: 'Property not found' })
  updateAvailability(@Param('id') id: string, @Body('isAvailable') isAvailable: boolean) {
    return this.propertiesService.updateAvailability(id, isAvailable);
  }

  @Get('host/:hostId')
  @UseGuards(JwtAuthGuard)
  @ApiOperation({ summary: 'Get properties by host ID' })
  @ApiParam({ name: 'hostId', required: true, description: 'Host ID' })
  @ApiResponse({ status: 200, description: 'Host properties retrieved successfully' })
  @ApiResponse({ status: 401, description: 'Unauthorized' })
  getPropertiesByHostId(@Param('hostId') hostId: string) {
    return this.propertiesService.getPropertiesByHostId(hostId);
  }
}
