import { PartialType } from '@nestjs/swagger';
import { CreatePropertyDto } from './create-property.dto';

/**
 * Data Transfer Object for updating a property
 * Extends CreatePropertyDto but makes all fields optional
 */
export class UpdatePropertyDto extends PartialType(CreatePropertyDto) {}
