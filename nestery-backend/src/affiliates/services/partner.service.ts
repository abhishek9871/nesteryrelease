import { Injectable, ConflictException, NotFoundException, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PartnerEntity } from '../entities/partner.entity';
import { CreatePartnerDto } from '../dto/create-partner.dto';
import { UpdatePartnerDto } from '../dto/update-partner.dto';
import { PartnerDashboardDto } from '../dto/partner-dashboard.dto';

@Injectable()
export class PartnerService {
  private readonly logger = new Logger(PartnerService.name);

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

  /**
   * Find all partners with pagination, filtering, and sorting
   */
  async findAll(
    page: number = 1,
    limit: number = 10,
    filters?: Record<string, unknown>,
  ): Promise<{ partners: PartnerEntity[]; total: number }> {
    this.logger.log(
      `Finding all partners - page: ${page}, limit: ${limit}, filters: ${JSON.stringify(filters)}`,
    );

    const queryBuilder = this.partnerRepository.createQueryBuilder('partner');

    // Apply filters
    if (filters) {
      if (filters.category) {
        queryBuilder.andWhere('partner.category = :category', { category: filters.category });
      }
      if (filters.isActive !== undefined) {
        queryBuilder.andWhere('partner.isActive = :isActive', { isActive: filters.isActive });
      }
      if (filters.name) {
        queryBuilder.andWhere('partner.name ILIKE :name', { name: `%${filters.name}%` });
      }
      if (filters.createdAfter) {
        queryBuilder.andWhere('partner.createdAt >= :createdAfter', {
          createdAfter: filters.createdAfter,
        });
      }
      if (filters.createdBefore) {
        queryBuilder.andWhere('partner.createdAt <= :createdBefore', {
          createdBefore: filters.createdBefore,
        });
      }
    }

    // Apply sorting (default by createdAt DESC)
    const sortField = (filters?.sortField as string) || 'createdAt';
    const sortOrder = (filters?.sortOrder as 'ASC' | 'DESC') || 'DESC';
    queryBuilder.orderBy(`partner.${sortField}`, sortOrder);

    // Apply pagination
    queryBuilder.skip((page - 1) * limit).take(limit);

    // Load relations for dashboard data
    queryBuilder.leftJoinAndSelect('partner.offers', 'offers');

    const [partners, total] = await queryBuilder.getManyAndCount();

    this.logger.log(`Found ${partners.length} partners out of ${total} total`);
    return { partners, total };
  }

  /**
   * Find partner by ID with relations
   */
  async findById(id: string): Promise<PartnerEntity> {
    this.logger.log(`Finding partner by ID: ${id}`);

    const partner = await this.partnerRepository.findOne({
      where: { id },
      relations: ['offers', 'earnings'],
    });

    if (!partner) {
      throw new NotFoundException(`Partner with ID ${id} not found`);
    }

    return partner;
  }

  /**
   * Update partner information
   */
  async update(id: string, updateDto: UpdatePartnerDto): Promise<PartnerEntity> {
    this.logger.log(`Updating partner ${id} with data: ${JSON.stringify(updateDto)}`);

    const partner = await this.findById(id);

    // Check for name conflicts if name is being updated
    if (updateDto.name && updateDto.name !== partner.name) {
      const existingPartner = await this.partnerRepository.findOneBy({ name: updateDto.name });
      if (existingPartner && existingPartner.id !== id) {
        throw new ConflictException(`Partner with name "${updateDto.name}" already exists.`);
      }
    }

    // Update partner
    Object.assign(partner, updateDto);
    partner.updatedAt = new Date();

    const updatedPartner = await this.partnerRepository.save(partner);
    this.logger.log(`Successfully updated partner ${id}`);

    return updatedPartner;
  }

  /**
   * Soft delete partner
   */
  async delete(id: string): Promise<void> {
    this.logger.log(`Soft deleting partner: ${id}`);

    const partner = await this.findById(id);

    // Implement soft delete by setting isActive to false
    partner.isActive = false;
    partner.updatedAt = new Date();

    await this.partnerRepository.save(partner);
    this.logger.log(`Successfully soft deleted partner ${id}`);
  }

  /**
   * Get comprehensive dashboard data for a partner
   */
  async getDashboardData(partnerId: string): Promise<PartnerDashboardDto> {
    this.logger.log(`Getting dashboard data for partner: ${partnerId}`);

    const partner = await this.findById(partnerId);

    // Use QueryBuilder for analytics aggregations
    const analyticsQuery = this.partnerRepository
      .createQueryBuilder('partner')
      .leftJoin('partner.offers', 'offers')
      .leftJoin('partner.earnings', 'earnings')
      .where('partner.id = :partnerId', { partnerId })
      .select([
        'COUNT(DISTINCT offers.id) as totalOffers',
        'COUNT(DISTINCT CASE WHEN offers.isActive = true THEN offers.id END) as activeOffers',
        'COUNT(DISTINCT earnings.id) as totalEarnings',
        'COALESCE(SUM(CASE WHEN earnings.status = :confirmedStatus THEN earnings.amountEarned END), 0) as totalConfirmedEarnings',
        'COALESCE(SUM(CASE WHEN earnings.status = :pendingStatus THEN earnings.amountEarned END), 0) as totalPendingEarnings',
        'COALESCE(SUM(CASE WHEN earnings.status = :paidStatus THEN earnings.amountEarned END), 0) as totalPaidEarnings',
      ])
      .setParameters({
        confirmedStatus: 'confirmed',
        pendingStatus: 'pending',
        paidStatus: 'paid',
      });

    const analytics = await analyticsQuery.getRawOne();

    // Get recent earnings (last 30 days)
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const recentEarningsQuery = this.partnerRepository
      .createQueryBuilder('partner')
      .leftJoin('partner.earnings', 'earnings')
      .where('partner.id = :partnerId', { partnerId })
      .andWhere('earnings.transactionDate >= :thirtyDaysAgo', { thirtyDaysAgo })
      .select([
        'COUNT(earnings.id) as recentEarningsCount',
        'COALESCE(SUM(earnings.amountEarned), 0) as recentEarningsTotal',
      ]);

    const recentEarnings = await recentEarningsQuery.getRawOne();

    // Get top performing offers
    const topOffersQuery = this.partnerRepository
      .createQueryBuilder('partner')
      .leftJoin('partner.offers', 'offers')
      .leftJoin('offers.earnings', 'earnings')
      .where('partner.id = :partnerId', { partnerId })
      .groupBy('offers.id, offers.title')
      .select([
        'offers.id as offerId',
        'offers.title as offerTitle',
        'COUNT(earnings.id) as conversionCount',
        'COALESCE(SUM(earnings.amountEarned), 0) as totalEarnings',
      ])
      .orderBy('totalEarnings', 'DESC')
      .limit(5);

    const topOffers = await topOffersQuery.getRawMany();

    const dashboardData: PartnerDashboardDto = {
      partner: {
        id: partner.id,
        name: partner.name,
        category: partner.category,
        isActive: partner.isActive,
        createdAt: partner.createdAt,
      },
      analytics: {
        totalOffers: parseInt(analytics.totalOffers) || 0,
        activeOffers: parseInt(analytics.activeOffers) || 0,
        totalEarnings: parseInt(analytics.totalEarnings) || 0,
        totalConfirmedEarnings: parseFloat(analytics.totalConfirmedEarnings) || 0,
        totalPendingEarnings: parseFloat(analytics.totalPendingEarnings) || 0,
        totalPaidEarnings: parseFloat(analytics.totalPaidEarnings) || 0,
        recentEarningsCount: parseInt(recentEarnings.recentEarningsCount) || 0,
        recentEarningsTotal: parseFloat(recentEarnings.recentEarningsTotal) || 0,
      },
      topOffers: topOffers.map(offer => ({
        offerId: offer.offerId,
        offerTitle: offer.offerTitle,
        conversionCount: parseInt(offer.conversionCount) || 0,
        totalEarnings: parseFloat(offer.totalEarnings) || 0,
      })),
    };

    this.logger.log(`Generated dashboard data for partner ${partnerId}`);
    return dashboardData;
  }
}
