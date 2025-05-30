import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PropertiesService } from './properties.service';
import { PropertiesController } from './properties.controller';
import { Property } from './entities/property.entity';
import { CoreModule } from '../core/core.module';
import { ConfigModule } from '@nestjs/config'; // Import ConfigModule

/**
 * Properties module handling property-related operations
 */
@Module({
  imports: [TypeOrmModule.forFeature([Property]), CoreModule, ConfigModule], // Add ConfigModule
  controllers: [PropertiesController],
  providers: [PropertiesService],
  exports: [PropertiesService],
})
export class PropertiesModule {}
