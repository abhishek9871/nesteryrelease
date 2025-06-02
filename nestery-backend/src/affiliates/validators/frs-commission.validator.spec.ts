import { ValidationArguments } from 'class-validator';
import {
  FrsCommissionRateValidator,
  validateCommissionRate,
  getValidCommissionRateRange,
} from './frs-commission.validator';
import { PartnerCategoryEnum } from '../entities/partner.entity';

describe('FrsCommissionRateValidator', () => {
  let validator: FrsCommissionRateValidator;

  beforeEach(() => {
    validator = new FrsCommissionRateValidator();
  });

  describe('validate', () => {
    it('should validate TOUR_OPERATOR commission rates (15-20%)', () => {
      const args = {
        object: { category: PartnerCategoryEnum.TOUR_OPERATOR },
        value: 0.15,
      } as ValidationArguments;

      expect(validator.validate(0.15, args)).toBe(true); // 15% - minimum
      expect(validator.validate(0.17, args)).toBe(true); // 17% - within range
      expect(validator.validate(0.2, args)).toBe(true); // 20% - maximum
      expect(validator.validate(0.14, args)).toBe(false); // 14% - below minimum
      expect(validator.validate(0.21, args)).toBe(false); // 21% - above maximum
    });

    it('should validate ACTIVITY_PROVIDER commission rates (15-20%)', () => {
      const args = {
        object: { category: PartnerCategoryEnum.ACTIVITY_PROVIDER },
        value: 0.18,
      } as ValidationArguments;

      expect(validator.validate(0.15, args)).toBe(true);
      expect(validator.validate(0.18, args)).toBe(true);
      expect(validator.validate(0.2, args)).toBe(true);
      expect(validator.validate(0.14, args)).toBe(false);
      expect(validator.validate(0.21, args)).toBe(false);
    });

    it('should validate RESTAURANT commission rates (exactly 10%)', () => {
      const args = {
        object: { category: PartnerCategoryEnum.RESTAURANT },
        value: 0.1,
      } as ValidationArguments;

      expect(validator.validate(0.1, args)).toBe(true); // Exactly 10%
      expect(validator.validate(0.09, args)).toBe(false); // Below 10%
      expect(validator.validate(0.11, args)).toBe(false); // Above 10%
    });

    it('should validate TRANSPORTATION commission rates (8-12%)', () => {
      const args = {
        object: { category: PartnerCategoryEnum.TRANSPORTATION },
        value: 0.1,
      } as ValidationArguments;

      expect(validator.validate(0.08, args)).toBe(true); // 8% - minimum
      expect(validator.validate(0.1, args)).toBe(true); // 10% - within range
      expect(validator.validate(0.12, args)).toBe(true); // 12% - maximum
      expect(validator.validate(0.07, args)).toBe(false); // 7% - below minimum
      expect(validator.validate(0.13, args)).toBe(false); // 13% - above maximum
    });

    it('should validate ECOMMERCE commission rates (8-12%)', () => {
      const args = {
        object: { category: PartnerCategoryEnum.ECOMMERCE },
        value: 0.09,
      } as ValidationArguments;

      expect(validator.validate(0.08, args)).toBe(true);
      expect(validator.validate(0.09, args)).toBe(true);
      expect(validator.validate(0.12, args)).toBe(true);
      expect(validator.validate(0.07, args)).toBe(false);
      expect(validator.validate(0.13, args)).toBe(false);
    });

    it('should handle percentage values > 1 (convert to decimal)', () => {
      const args = {
        object: { category: PartnerCategoryEnum.TOUR_OPERATOR },
        value: 15, // 15% as whole number
      } as ValidationArguments;

      expect(validator.validate(15, args)).toBe(true); // Should convert 15 to 0.15
      expect(validator.validate(25, args)).toBe(false); // Should convert 25 to 0.25 (above max)
    });

    it('should handle alternative category property name', () => {
      const args = {
        object: { partnerCategory: PartnerCategoryEnum.RESTAURANT },
        value: 0.1,
      } as ValidationArguments;

      expect(validator.validate(0.1, args)).toBe(true);
    });

    it('should return false for missing category', () => {
      const args = {
        object: {},
        value: 0.15,
      } as ValidationArguments;

      expect(validator.validate(0.15, args)).toBe(false);
    });

    it('should return false for invalid rate type', () => {
      const args = {
        object: { category: PartnerCategoryEnum.TOUR_OPERATOR },
        value: 'invalid',
      } as ValidationArguments;

      expect(validator.validate('invalid' as any, args)).toBe(false);
    });
  });

  describe('defaultMessage', () => {
    it('should return appropriate error message for invalid rate', () => {
      const args = {
        object: { category: PartnerCategoryEnum.TOUR_OPERATOR },
        value: 0.25, // 25% - above maximum
      } as ValidationArguments;

      const message = validator.defaultMessage(args);

      expect(message).toContain('Commission rate 25% is not compliant with FRS Section 1.2');
      expect(message).toContain('TOUR_OPERATOR');
      expect(message).toContain('Valid range: 15%-20%');
    });

    it('should return error message for invalid category', () => {
      const args = {
        object: { category: 'INVALID_CATEGORY' },
        value: 0.15,
      } as ValidationArguments;

      const message = validator.defaultMessage(args);

      expect(message).toContain('Invalid partner category: INVALID_CATEGORY');
    });

    it('should handle percentage values > 1 in error message', () => {
      const args = {
        object: { category: PartnerCategoryEnum.RESTAURANT },
        value: 0.15, // 15% as decimal
      } as ValidationArguments;

      const message = validator.defaultMessage(args);

      expect(message).toContain('Commission rate 15% is not compliant'); // Should display as percentage
    });
  });

  describe('utility functions', () => {
    describe('validateCommissionRate', () => {
      it('should validate commission rates programmatically', () => {
        expect(validateCommissionRate(0.15, PartnerCategoryEnum.TOUR_OPERATOR)).toBe(true);
        expect(validateCommissionRate(0.25, PartnerCategoryEnum.TOUR_OPERATOR)).toBe(false);
        expect(validateCommissionRate(0.1, PartnerCategoryEnum.RESTAURANT)).toBe(true);
        expect(validateCommissionRate(0.15, PartnerCategoryEnum.RESTAURANT)).toBe(false);
      });
    });

    describe('getValidCommissionRateRange', () => {
      it('should return correct ranges for each category', () => {
        expect(getValidCommissionRateRange(PartnerCategoryEnum.TOUR_OPERATOR)).toEqual({
          min: 0.15,
          max: 0.2,
        });

        expect(getValidCommissionRateRange(PartnerCategoryEnum.ACTIVITY_PROVIDER)).toEqual({
          min: 0.15,
          max: 0.2,
        });

        expect(getValidCommissionRateRange(PartnerCategoryEnum.RESTAURANT)).toEqual({
          min: 0.1,
          max: 0.1,
        });

        expect(getValidCommissionRateRange(PartnerCategoryEnum.TRANSPORTATION)).toEqual({
          min: 0.08,
          max: 0.12,
        });

        expect(getValidCommissionRateRange(PartnerCategoryEnum.ECOMMERCE)).toEqual({
          min: 0.08,
          max: 0.12,
        });
      });

      it('should return null for invalid category', () => {
        expect(getValidCommissionRateRange('INVALID_CATEGORY' as any)).toBeNull();
      });
    });
  });

  describe('FRS Section 1.2 compliance scenarios', () => {
    it('should enforce exact FRS requirements for Tours & Activities', () => {
      // Tours & Activities (TOUR_OPERATOR, ACTIVITY_PROVIDER): 15-20%
      const tourOperatorArgs = {
        object: { category: PartnerCategoryEnum.TOUR_OPERATOR },
        value: 0.17,
      } as ValidationArguments;

      const activityProviderArgs = {
        object: { category: PartnerCategoryEnum.ACTIVITY_PROVIDER },
        value: 0.19,
      } as ValidationArguments;

      expect(validator.validate(0.17, tourOperatorArgs)).toBe(true);
      expect(validator.validate(0.19, activityProviderArgs)).toBe(true);

      // Test boundaries
      expect(validator.validate(0.149, tourOperatorArgs)).toBe(false); // Just below minimum
      expect(validator.validate(0.201, activityProviderArgs)).toBe(false); // Just above maximum
    });

    it('should enforce exact FRS requirements for Restaurant Bookings', () => {
      // Restaurant Bookings (RESTAURANT): 10%
      const restaurantArgs = {
        object: { category: PartnerCategoryEnum.RESTAURANT },
        value: 0.1,
      } as ValidationArguments;

      expect(validator.validate(0.1, restaurantArgs)).toBe(true);
      expect(validator.validate(0.099, restaurantArgs)).toBe(false);
      expect(validator.validate(0.101, restaurantArgs)).toBe(false);
    });

    it('should enforce exact FRS requirements for Transportation & E-commerce', () => {
      // Transportation & E-commerce (TRANSPORTATION, ECOMMERCE): 8-12%
      const transportationArgs = {
        object: { category: PartnerCategoryEnum.TRANSPORTATION },
        value: 0.09,
      } as ValidationArguments;

      const ecommerceArgs = {
        object: { category: PartnerCategoryEnum.ECOMMERCE },
        value: 0.11,
      } as ValidationArguments;

      expect(validator.validate(0.09, transportationArgs)).toBe(true);
      expect(validator.validate(0.11, ecommerceArgs)).toBe(true);

      // Test boundaries
      expect(validator.validate(0.079, transportationArgs)).toBe(false); // Just below minimum
      expect(validator.validate(0.121, ecommerceArgs)).toBe(false); // Just above maximum
    });
  });
});
