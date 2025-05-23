import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PropertiesService } from './properties.service';
import { PropertiesController } from './properties.controller';
import { Property } from './entities/property.entity';
import { CoreModule } from '../core/core.module';

/**
 * Properties module handling property-related operations
 */
@Module({
  imports: [
    TypeOrmModule.forFeature([Property]),
    CoreModule,
  ],
  controllers: [PropertiesController],
  providers: [PropertiesService],
  exports: [PropertiesService],
})
export class PropertiesModule {}
