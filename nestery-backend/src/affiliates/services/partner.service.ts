import { Injectable, ConflictException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PartnerEntity } from '../entities/partner.entity';
import { CreatePartnerDto } from '../dto/create-partner.dto';

@Injectable()
export class PartnerService {
  constructor(
    @InjectRepository(PartnerEntity)
    private readonly partnerRepository: Repository<PartnerEntity>,
  ) {}

  async registerPartner(createPartnerDto: CreatePartnerDto): Promise<PartnerEntity> {
    const existingPartner = await this.partnerRepository.findOneBy({ name: createPartnerDto.name });
    if (existingPartner) {
      throw new ConflictException(`Partner with name "${createPartnerDto.name}" already exists.`);
    }
    const partner = this.partnerRepository.create(createPartnerDto);
    return this.partnerRepository.save(partner);
  }
}
