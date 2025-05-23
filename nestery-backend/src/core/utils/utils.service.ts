import { Injectable } from '@nestjs/common';
import { LoggerService } from '../logger/logger.service';

/**
 * Utility service providing common helper functions used across the application
 */
@Injectable()
export class UtilsService {
  constructor(private readonly logger: LoggerService) {
    this.logger.setContext('UtilsService');
  }

  /**
   * Safely parses a JSON string, returning null if parsing fails
   */
  safeJsonParse(jsonString: string): any | null {
    try {
      return JSON.parse(jsonString);
    } catch (error) {
      this.logger.warn(`Failed to parse JSON: ${error.message}`);
      return null;
    }
  }

  /**
   * Removes null and undefined values from an object
   */
  removeEmptyValues(obj: Record<string, any>): Record<string, any> {
    return Object.entries(obj)
      .filter(([_, value]) => value !== null && value !== undefined)
      .reduce((acc, [key, value]) => ({ ...acc, [key]: value }), {});
  }

  /**
   * Formats a price with currency symbol
   */
  formatPrice(price: number, currency: string = 'USD'): string {
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency,
    }).format(price);
  }

  /**
   * Generates a slug from a string
   */
  generateSlug(text: string): string {
    return text
      .toString()
      .toLowerCase()
      .trim()
      .replace(/\s+/g, '-')
      .replace(/[^\w\-]+/g, '')
      .replace(/\-\-+/g, '-');
  }

  /**
   * Calculates the distance between two coordinates in kilometers
   */
  calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number,
  ): number {
    const R = 6371; // Radius of the earth in km
    const dLat = this.deg2rad(lat2 - lat1);
    const dLon = this.deg2rad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.deg2rad(lat1)) *
        Math.cos(this.deg2rad(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c; // Distance in km
    return distance;
  }

  private deg2rad(deg: number): number {
    return deg * (Math.PI / 180);
  }
}
