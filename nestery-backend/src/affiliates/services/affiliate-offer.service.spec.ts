import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { NotFoundException, BadRequestException } from '@nestjs/common';
import { AffiliateOfferService } from './affiliate-offer.service';
import { AffiliateOfferEntity } from '../entities/affiliate-offer.entity';
import { PartnerEntity, PartnerCategoryEnum } from '../entities/partner.entity';
import { CreateOfferDto } from '../dto/create-offer.dto';
import { UpdateOfferDto } from '../dto/update-offer.dto';

// Mock the FRS validator
jest.mock('../validators/frs-commission.validator', () => ({
  validateCommissionRate: jest.fn().mockReturnValue(true),
  getValidCommissionRateRange: jest.fn().mockReturnValue({ min: 0.15, max: 0.2 }),
}));

describe('AffiliateOfferService', () => {
  let service: AffiliateOfferService;

  const mockOfferRepository = {
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
    findOneBy: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockPartnerRepository = {
    findOneBy: jest.fn(),
  };

  const mockQueryBuilder = {
    leftJoinAndSelect: jest.fn().mockReturnThis(),
    andWhere: jest.fn().mockReturnThis(),
    where: jest.fn().mockReturnThis(),
    orderBy: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    take: jest.fn().mockReturnThis(),
    getManyAndCount: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AffiliateOfferService,
        {
          provide: getRepositoryToken(AffiliateOfferEntity),
          useValue: mockOfferRepository,
        },
        {
          provide: getRepositoryToken(PartnerEntity),
          useValue: mockPartnerRepository,
        },
      ],
    }).compile();

    service = module.get<AffiliateOfferService>(AffiliateOfferService);

    // Reset mocks
    jest.clearAllMocks();
    mockOfferRepository.createQueryBuilder.mockReturnValue(mockQueryBuilder);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('createOffer', () => {
    const partnerId = 'partner-1';
    const createOfferDto: CreateOfferDto = {
      title: 'Test Offer',
      description: 'Test Description',
      commissionStructure: { type: 'percentage', value: 15 },
      validFrom: new Date('2024-01-01'),
      validTo: new Date('2024-12-31'),
      termsConditions: 'Test terms',
      isActive: true,
    };

    const mockPartner = {
      id: partnerId,
      name: 'Test Partner',
      category: PartnerCategoryEnum.TOUR_OPERATOR,
      isActive: true,
    };

    it('should create offer successfully with FRS validation', async () => {
      const mockOffer = { id: 'offer-1', ...createOfferDto, partnerId };

      mockPartnerRepository.findOneBy.mockResolvedValue(mockPartner);
      mockOfferRepository.create.mockReturnValue(mockOffer);
      mockOfferRepository.save.mockResolvedValue(mockOffer);

      const result = await service.createOffer(partnerId, createOfferDto);

      expect(mockPartnerRepository.findOneBy).toHaveBeenCalledWith({ id: partnerId });
      expect(mockOfferRepository.create).toHaveBeenCalledWith({
        ...createOfferDto,
        partnerId,
        partner: mockPartner,
      });
      expect(result).toEqual(mockOffer);
    });

    it('should throw NotFoundException if partner not found', async () => {
      mockPartnerRepository.findOneBy.mockResolvedValue(null);

      await expect(service.createOffer(partnerId, createOfferDto)).rejects.toThrow(
        NotFoundException,
      );
    });

    it('should throw BadRequestException if partner is not active', async () => {
      const inactivePartner = { ...mockPartner, isActive: false };
      mockPartnerRepository.findOneBy.mockResolvedValue(inactivePartner);

      await expect(service.createOffer(partnerId, createOfferDto)).rejects.toThrow(
        BadRequestException,
      );
    });

    it('should throw BadRequestException for invalid date range', async () => {
      const invalidDto = {
        ...createOfferDto,
        validFrom: new Date('2024-12-31'),
        validTo: new Date('2024-01-01'),
      };

      mockPartnerRepository.findOneBy.mockResolvedValue(mockPartner);

      await expect(service.createOffer(partnerId, invalidDto)).rejects.toThrow(BadRequestException);
    });

    it('should validate commission structure', async () => {
      const invalidCommissionDto = {
        ...createOfferDto,
        commissionStructure: { type: 'percentage' as const, value: -5 },
      };

      mockPartnerRepository.findOneBy.mockResolvedValue(mockPartner);

      await expect(service.createOffer(partnerId, invalidCommissionDto)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe('findAll', () => {
    it('should return paginated offers with filters', async () => {
      const mockOffers = [
        { id: '1', title: 'Offer 1' },
        { id: '2', title: 'Offer 2' },
      ];
      const total = 2;

      mockQueryBuilder.getManyAndCount.mockResolvedValue([mockOffers, total]);

      const result = await service.findAll(1, 10, { partnerId: 'partner-1', isActive: true });

      expect(mockOfferRepository.createQueryBuilder).toHaveBeenCalledWith('offer');
      expect(mockQueryBuilder.andWhere).toHaveBeenCalledWith('offer.partnerId = :partnerId', {
        partnerId: 'partner-1',
      });
      expect(mockQueryBuilder.andWhere).toHaveBeenCalledWith('offer.isActive = :isActive', {
        isActive: true,
      });
      expect(result).toEqual({ offers: mockOffers, total });
    });
  });

  describe('findAllActive', () => {
    it('should return only active and valid offers', async () => {
      const mockOffers = [{ id: '1', title: 'Active Offer' }];
      const total = 1;

      mockQueryBuilder.getManyAndCount.mockResolvedValue([mockOffers, total]);

      const result = await service.findAllActive(1, 10);

      expect(mockQueryBuilder.where).toHaveBeenCalledWith('offer.isActive = :isActive', {
        isActive: true,
      });
      expect(mockQueryBuilder.andWhere).toHaveBeenCalledWith('partner.isActive = :partnerActive', {
        partnerActive: true,
      });
      expect(result).toEqual({ offers: mockOffers, total });
    });
  });

  describe('findByPartnerId', () => {
    it('should return offers for specific partner', async () => {
      const partnerId = 'partner-1';
      const mockPartner = { id: partnerId };
      const mockOffers = [{ id: '1', title: 'Partner Offer' }];

      mockPartnerRepository.findOneBy.mockResolvedValue(mockPartner);
      mockQueryBuilder.getManyAndCount.mockResolvedValue([mockOffers, 1]);

      const result = await service.findByPartnerId(partnerId, 1, 10);

      expect(mockPartnerRepository.findOneBy).toHaveBeenCalledWith({ id: partnerId });
      expect(mockQueryBuilder.where).toHaveBeenCalledWith('offer.partnerId = :partnerId', {
        partnerId,
      });
      expect(result).toEqual({ offers: mockOffers, total: 1 });
    });

    it('should throw NotFoundException if partner not found', async () => {
      mockPartnerRepository.findOneBy.mockResolvedValue(null);

      await expect(service.findByPartnerId('invalid-id', 1, 10)).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    const offerId = 'offer-1';
    const updateDto: UpdateOfferDto = {
      title: 'Updated Offer',
      isActive: false,
    };

    it('should update offer successfully', async () => {
      const existingOffer = {
        id: offerId,
        title: 'Old Title',
        validFrom: new Date('2024-01-01'),
        validTo: new Date('2024-12-31'),
        partner: { category: PartnerCategoryEnum.TOUR_OPERATOR },
      };
      const updatedOffer = { ...existingOffer, ...updateDto };

      mockOfferRepository.findOne.mockResolvedValue(existingOffer);
      mockOfferRepository.save.mockResolvedValue(updatedOffer);

      const result = await service.update(offerId, updateDto);

      expect(mockOfferRepository.findOne).toHaveBeenCalledWith({
        where: { id: offerId },
        relations: ['partner'],
      });
      expect(mockOfferRepository.save).toHaveBeenCalled();
      expect(result).toEqual(updatedOffer);
    });

    it('should throw NotFoundException if offer not found', async () => {
      mockOfferRepository.findOne.mockResolvedValue(null);

      await expect(service.update(offerId, updateDto)).rejects.toThrow(NotFoundException);
    });

    it('should validate date range when updating dates', async () => {
      const existingOffer = {
        id: offerId,
        validFrom: new Date('2024-01-01'),
        validTo: new Date('2024-12-31'),
        partner: { category: PartnerCategoryEnum.TOUR_OPERATOR },
      };
      const invalidUpdateDto = {
        validFrom: '2024-12-31',
        validTo: '2024-01-01',
      };

      mockOfferRepository.findOne.mockResolvedValue(existingOffer);

      await expect(service.update(offerId, invalidUpdateDto)).rejects.toThrow(BadRequestException);
    });
  });

  describe('delete', () => {
    it('should soft delete offer', async () => {
      const offerId = 'offer-1';
      const offer = { id: offerId, isActive: true };

      mockOfferRepository.findOneBy.mockResolvedValue(offer);
      mockOfferRepository.save.mockResolvedValue({ ...offer, isActive: false });

      await service.delete(offerId);

      expect(mockOfferRepository.findOneBy).toHaveBeenCalledWith({ id: offerId });
      expect(mockOfferRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({ isActive: false }),
      );
    });

    it('should throw NotFoundException if offer not found', async () => {
      mockOfferRepository.findOneBy.mockResolvedValue(null);

      await expect(service.delete('invalid-id')).rejects.toThrow(NotFoundException);
    });
  });
});
