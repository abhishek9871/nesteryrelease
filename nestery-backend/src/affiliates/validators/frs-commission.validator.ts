import {
  ValidatorConstraint,
  ValidatorConstraintInterface,
  ValidationArguments,
  registerDecorator,
  ValidationOptions,
} from 'class-validator';
import { Injectable } from '@nestjs/common';
import { PartnerCategoryEnum } from '../entities/partner.entity';

/**
 * FRS Section 1.2 Commission Rate Validation
 * Enforces exact commission rate ranges based on partner category:
 * - Tours & Activities (TOUR_OPERATOR, ACTIVITY_PROVIDER): 15-20%
 * - Restaurant Bookings (RESTAURANT): 10%
 * - Transportation & E-commerce (TRANSPORTATION, ECOMMERCE): 8-12%
 */
@ValidatorConstraint({ name: 'isFrsCompliantCommissionRate', async: false })
@Injectable()
export class FrsCommissionRateValidator implements ValidatorConstraintInterface {
  validate(rate: number, args: ValidationArguments): boolean {
    const object = args.object as any;
    const category = object.category || object.partnerCategory;

    if (!category || typeof rate !== 'number') {
      return false;
    }

    // Convert percentage to decimal if needed (e.g., 15% -> 0.15)
    const normalizedRate = rate > 1 ? rate / 100 : rate;

    return this.isValidRateForCategory(normalizedRate, category);
  }

  defaultMessage(args: ValidationArguments): string {
    const object = args.object as any;
    const category = object.category || object.partnerCategory;
    const rate = args.value;

    const ranges = this.getCategoryRateRanges();
    const categoryRange = ranges[category as PartnerCategoryEnum];

    if (!categoryRange) {
      return `Invalid partner category: ${category}`;
    }

    const displayRate = rate > 1 ? rate : rate * 100;
    return `Commission rate ${displayRate}% is not compliant with FRS Section 1.2 for category ${category}. Valid range: ${categoryRange.min * 100}%-${categoryRange.max * 100}%`;
  }

  private isValidRateForCategory(rate: number, category: PartnerCategoryEnum): boolean {
    const ranges = this.getCategoryRateRanges();
    const categoryRange = ranges[category];

    if (!categoryRange) {
      return false;
    }

    return rate >= categoryRange.min && rate <= categoryRange.max;
  }

  private getCategoryRateRanges(): Record<PartnerCategoryEnum, { min: number; max: number }> {
    return {
      [PartnerCategoryEnum.TOUR_OPERATOR]: { min: 0.15, max: 0.2 }, // 15-20%
      [PartnerCategoryEnum.ACTIVITY_PROVIDER]: { min: 0.15, max: 0.2 }, // 15-20%
      [PartnerCategoryEnum.RESTAURANT]: { min: 0.1, max: 0.1 }, // Exactly 10%
      [PartnerCategoryEnum.TRANSPORTATION]: { min: 0.08, max: 0.12 }, // 8-12%
      [PartnerCategoryEnum.ECOMMERCE]: { min: 0.08, max: 0.12 }, // 8-12%
    };
  }
}

/**
 * Custom decorator for FRS commission rate validation
 * Usage: @IsFrsCompliantCommissionRate()
 */
export function IsFrsCompliantCommissionRate(validationOptions?: ValidationOptions) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      target: object.constructor,
      propertyName: propertyName,
      options: validationOptions,
      constraints: [],
      validator: FrsCommissionRateValidator,
    });
  };
}

/**
 * Utility function to get valid commission rate range for a category
 */
export function getValidCommissionRateRange(
  category: PartnerCategoryEnum,
): { min: number; max: number } | null {
  const validator = new FrsCommissionRateValidator();
  const ranges = (validator as any).getCategoryRateRanges();
  return ranges[category] || null;
}

/**
 * Utility function to validate commission rate programmatically
 */
export function validateCommissionRate(rate: number, category: PartnerCategoryEnum): boolean {
  const validator = new FrsCommissionRateValidator();
  return (validator as any).isValidRateForCategory(rate, category);
}
