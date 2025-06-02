import { Test, TestingModule } from '@nestjs/testing';
import { getRepositoryToken } from '@nestjs/typeorm';
import { ConflictException, NotFoundException } from '@nestjs/common';
import { PartnerService } from './partner.service';
import { PartnerEntity, PartnerCategoryEnum } from '../entities/partner.entity';
import { CreatePartnerDto } from '../dto/create-partner.dto';
import { UpdatePartnerDto } from '../dto/update-partner.dto';

describe('PartnerService', () => {
  let service: PartnerService;

  const mockRepository = {
    findOneBy: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
    findOne: jest.fn(),
    createQueryBuilder: jest.fn(),
  };

  const mockQueryBuilder = {
    andWhere: jest.fn().mockReturnThis(),
    orderBy: jest.fn().mockReturnThis(),
    skip: jest.fn().mockReturnThis(),
    take: jest.fn().mockReturnThis(),
    leftJoinAndSelect: jest.fn().mockReturnThis(),
    leftJoin: jest.fn().mockReturnThis(),
    where: jest.fn().mockReturnThis(),
    select: jest.fn().mockReturnThis(),
    setParameters: jest.fn().mockReturnThis(),
    groupBy: jest.fn().mockReturnThis(),
    limit: jest.fn().mockReturnThis(),
    getManyAndCount: jest.fn(),
    getRawOne: jest.fn(),
    getRawMany: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PartnerService,
        {
          provide: getRepositoryToken(PartnerEntity),
          useValue: mockRepository,
        },
      ],
    }).compile();

    service = module.get<PartnerService>(PartnerService);

    // Reset mocks
    jest.clearAllMocks();
    mockRepository.createQueryBuilder.mockReturnValue(mockQueryBuilder);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('registerPartner', () => {
    const createPartnerDto: CreatePartnerDto = {
      name: 'Test Partner',
      category: PartnerCategoryEnum.TOUR_OPERATOR,
      contactInfo: {
        email: 'test@partner.com',
        phone: '+1-555-0123',
      },
      commissionRateOverride: 0.15,
    };

    it('should create a new partner successfully', async () => {
      const mockPartner = { id: '1', ...createPartnerDto };

      mockRepository.findOneBy.mockResolvedValue(null);
      mockRepository.create.mockReturnValue(mockPartner);
      mockRepository.save.mockResolvedValue(mockPartner);

      const result = await service.registerPartner(createPartnerDto);

      expect(mockRepository.findOneBy).toHaveBeenCalledWith({ name: createPartnerDto.name });
      expect(mockRepository.create).toHaveBeenCalledWith(createPartnerDto);
      expect(mockRepository.save).toHaveBeenCalledWith(mockPartner);
      expect(result).toEqual(mockPartner);
    });

    it('should throw ConflictException if partner name already exists', async () => {
      const existingPartner = { id: '1', name: 'Test Partner' };
      mockRepository.findOneBy.mockResolvedValue(existingPartner);

      await expect(service.registerPartner(createPartnerDto)).rejects.toThrow(ConflictException);
      expect(mockRepository.findOneBy).toHaveBeenCalledWith({ name: createPartnerDto.name });
      expect(mockRepository.create).not.toHaveBeenCalled();
    });
  });

  describe('findAll', () => {
    it('should return paginated partners with filters', async () => {
      const mockPartners = [
        { id: '1', name: 'Partner 1', category: PartnerCategoryEnum.TOUR_OPERATOR },
        { id: '2', name: 'Partner 2', category: PartnerCategoryEnum.RESTAURANT },
      ];
      const total = 2;

      mockQueryBuilder.getManyAndCount.mockResolvedValue([mockPartners, total]);

      const result = await service.findAll(1, 10, { category: PartnerCategoryEnum.TOUR_OPERATOR });

      expect(mockRepository.createQueryBuilder).toHaveBeenCalledWith('partner');
      expect(mockQueryBuilder.andWhere).toHaveBeenCalledWith('partner.category = :category', {
        category: PartnerCategoryEnum.TOUR_OPERATOR,
      });
      expect(result).toEqual({ partners: mockPartners, total });
    });

    it('should handle pagination correctly', async () => {
      const page = 2;
      const limit = 5;
      mockQueryBuilder.getManyAndCount.mockResolvedValue([[], 0]);

      await service.findAll(page, limit);

      expect(mockQueryBuilder.skip).toHaveBeenCalledWith((page - 1) * limit);
      expect(mockQueryBuilder.take).toHaveBeenCalledWith(limit);
    });
  });

  describe('findById', () => {
    it('should return partner by ID with relations', async () => {
      const partnerId = '1';
      const mockPartner = { id: partnerId, name: 'Test Partner' };

      mockRepository.findOne.mockResolvedValue(mockPartner);

      const result = await service.findById(partnerId);

      expect(mockRepository.findOne).toHaveBeenCalledWith({
        where: { id: partnerId },
        relations: ['offers', 'earnings'],
      });
      expect(result).toEqual(mockPartner);
    });

    it('should throw NotFoundException if partner not found', async () => {
      const partnerId = '999';
      mockRepository.findOne.mockResolvedValue(null);

      await expect(service.findById(partnerId)).rejects.toThrow(NotFoundException);
    });
  });

  describe('update', () => {
    const updateDto: UpdatePartnerDto = {
      name: 'Updated Partner',
      isActive: false,
    };

    it('should update partner successfully', async () => {
      const partnerId = '1';
      const existingPartner = { id: partnerId, name: 'Old Name', isActive: true };
      const updatedPartner = { ...existingPartner, ...updateDto };

      jest.spyOn(service, 'findById').mockResolvedValue(existingPartner as any);
      mockRepository.findOneBy.mockResolvedValue(null); // No name conflict
      mockRepository.save.mockResolvedValue(updatedPartner);

      const result = await service.update(partnerId, updateDto);

      expect(service.findById).toHaveBeenCalledWith(partnerId);
      expect(mockRepository.save).toHaveBeenCalled();
      expect(result).toEqual(updatedPartner);
    });

    it('should throw ConflictException if new name already exists', async () => {
      const partnerId = '1';
      const existingPartner = { id: partnerId, name: 'Old Name' };
      const conflictingPartner = { id: '2', name: 'Updated Partner' };

      jest.spyOn(service, 'findById').mockResolvedValue(existingPartner as any);
      mockRepository.findOneBy.mockResolvedValue(conflictingPartner);

      await expect(service.update(partnerId, updateDto)).rejects.toThrow(ConflictException);
    });
  });

  describe('delete', () => {
    it('should soft delete partner', async () => {
      const partnerId = '1';
      const partner = { id: partnerId, isActive: true };

      jest.spyOn(service, 'findById').mockResolvedValue(partner as any);
      mockRepository.save.mockResolvedValue({ ...partner, isActive: false });

      await service.delete(partnerId);

      expect(service.findById).toHaveBeenCalledWith(partnerId);
      expect(mockRepository.save).toHaveBeenCalledWith(
        expect.objectContaining({ isActive: false }),
      );
    });
  });

  describe('getDashboardData', () => {
    it('should return comprehensive dashboard analytics', async () => {
      const partnerId = '1';
      const mockPartner = { id: partnerId, name: 'Test Partner' };
      const mockAnalytics = {
        totalOffers: '5',
        activeOffers: '3',
        totalEarnings: '10',
        totalConfirmedEarnings: '100.50',
        totalPendingEarnings: '50.25',
        totalPaidEarnings: '200.75',
      };
      const mockRecentEarnings = {
        recentEarningsCount: '3',
        recentEarningsTotal: '75.00',
      };
      const mockTopOffers = [
        { offerId: '1', offerTitle: 'Top Offer', conversionCount: '5', totalEarnings: '150.00' },
      ];

      jest.spyOn(service, 'findById').mockResolvedValue(mockPartner as any);
      mockQueryBuilder.getRawOne
        .mockResolvedValueOnce(mockAnalytics)
        .mockResolvedValueOnce(mockRecentEarnings);
      mockQueryBuilder.getRawMany.mockResolvedValue(mockTopOffers);

      const result = await service.getDashboardData(partnerId);

      expect(result).toHaveProperty('partner');
      expect(result).toHaveProperty('analytics');
      expect(result).toHaveProperty('topOffers');
      expect(result.analytics.totalConfirmedEarnings).toBe(100.5);
      expect(result.topOffers).toHaveLength(1);
    });
  });
});
