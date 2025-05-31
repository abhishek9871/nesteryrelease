import { Injectable, NotFoundException, ConflictException, Inject } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';
import { PremiumSubscription } from '../features/subscriptions/entities/premium-subscription.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { UserProfileDto } from './dto/user-profile.dto';
import { LoggerService } from '../core/logger/logger.service';
import { ExceptionService } from '../core/exception/exception.service';
import { CACHE_MANAGER, Cache } from '@nestjs/cache-manager';
import { ConfigService } from '@nestjs/config';

/**
 * Service handling user-related operations
 */
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly usersRepository: Repository<User>,
    @InjectRepository(PremiumSubscription)
    private readonly premiumSubscriptionRepository: Repository<PremiumSubscription>,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
    @Inject(CACHE_MANAGER) private cacheManager: Cache,
    private readonly configService: ConfigService,
  ) {
    this.logger.setContext('UsersService');
  }

  /**
   * Create a new user
   */
  async create(createUserDto: CreateUserDto): Promise<User> {
    try {
      const user = this.usersRepository.create(createUserDto);
      return await this.usersRepository.save(user);
    } catch (error) {
      this.exceptionService.handleException(error);
      if (error.code === '23505') {
        // PostgreSQL unique violation code
        throw new ConflictException('User with this email already exists');
      }
      throw error;
    }
  }

  /**
   * Find all users
   */
  async findAll(): Promise<User[]> {
    return this.usersRepository.find();
  }

  /**
   * Find a user by ID
   */
  async findById(id: string): Promise<User | null> {
    try {
      const user = await this.usersRepository.findOne({ where: { id } });
      if (!user) {
        this.logger.warn(`User with ID ${id} not found`);
        return null;
      }
      return user;
    } catch (error) {
      this.exceptionService.handleException(error);
      return null;
    }
  }

  /**
   * Find a user by email
   */
  async findByEmail(email: string): Promise<User | null> {
    try {
      const user = await this.usersRepository.findOne({ where: { email } });
      if (!user) {
        this.logger.warn(`User with email ${email} not found`);
        return null;
      }
      return user;
    } catch (error) {
      this.exceptionService.handleException(error);
      return null;
    }
  }

  /**
   * Check if a user has an active premium subscription
   */
  async isUserPremium(userId: string): Promise<boolean> {
    try {
      const activeSubscription = await this.premiumSubscriptionRepository.findOne({
        where: {
          userId,
          status: 'active',
        },
      });

      if (!activeSubscription) {
        return false;
      }

      // Additional check: ensure the subscription hasn't expired
      const now = new Date();
      const endDate = new Date(activeSubscription.endDate);

      if (endDate < now) {
        this.logger.warn(`Subscription for user ${userId} has expired but status is still active`);
        return false;
      }

      return true;
    } catch (error) {
      this.logger.error(`Error checking premium status for user ${userId}: ${error.message}`);
      this.exceptionService.handleException(error);
      return false;
    }
  }

  /**
   * Get user profile with premium status
   */
  async getUserProfile(userId: string): Promise<UserProfileDto | null> {
    try {
      const user = await this.findById(userId);
      if (!user) {
        return null;
      }

      const isPremium = await this.isUserPremium(userId);

      const userProfile: UserProfileDto = {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        profilePicture: user.profilePicture,
        phoneNumber: user.phoneNumber,
        loyaltyTier: user.loyaltyTier,
        loyaltyPoints: user.loyaltyPoints,
        isPremium,
        createdAt: user.createdAt,
      };

      return userProfile;
    } catch (error) {
      this.logger.error(`Error getting user profile for user ${userId}: ${error.message}`);
      this.exceptionService.handleException(error);
      return null;
    }
  }

  /**
   * Update a user
   */
  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    try {
      const user = await this.findById(id);
      if (!user) {
        throw new NotFoundException(`User with ID ${id} not found`);
      }

      Object.assign(user, updateUserDto);
      const updatedUser = await this.usersRepository.save(user);

      // Invalidate cache for this specific user
      const adminCacheKey = `/${this.configService.get<string>('API_PREFIX', 'v1')}/users/${id}`;
      await this.cacheManager.del(adminCacheKey);
      // Also invalidate /me if the updated user is the one making the request (tricky from service, usually handled by TTL or controller)
      // For basic invalidation, clearing the specific ID is sufficient as per task interpretation.
      return updatedUser;
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Update user's last login timestamp
   */
  async updateLastLogin(_id: string): Promise<void> {
    try {
      // Note: lastLoginAt field was removed from User entity
      // This functionality should be tracked via a separate UserSession entity
      // await this.usersRepository.update(id, { lastLoginAt: new Date() });
    } catch (error) {
      this.exceptionService.handleException(error);
    }
  }

  /**
   * Add loyalty points to a user
   */
  async addLoyaltyPoints(id: string, points: number): Promise<User> {
    try {
      const user = await this.findById(id);
      if (!user) {
        throw new NotFoundException(`User with ID ${id} not found`);
      }

      user.loyaltyPoints += points;
      return await this.usersRepository.save(user);
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Update user's premium status
   */
  async updatePremiumStatus(id: string, _isPremium: boolean): Promise<User> {
    try {
      const user = await this.findById(id);
      if (!user) {
        throw new NotFoundException(`User with ID ${id} not found`);
      }

      // Note: isPremium field was removed from User entity
      // Premium status should be managed via PremiumSubscription entity
      // user.isPremium = isPremium;
      return await this.usersRepository.save(user);
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Remove a user
   */
  async remove(id: string): Promise<void> {
    try {
      const result = await this.usersRepository.delete(id);
      if (result.affected === 0) {
        throw new NotFoundException(`User with ID ${id} not found`);
      }
    } catch (error) {
      this.exceptionService.handleException(error);
      throw error;
    }
  }
}
