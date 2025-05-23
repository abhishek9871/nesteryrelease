import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';

/**
 * Service for predicting price trends and optimal booking times
 */
@Injectable()
export class PricePredictionService {
  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    this.logger.setContext('PricePredictionService');
  }

  /**
   * Predict price trends for a specific property and date range
   */
  async predictPriceTrend(propertyId: string, checkInDate: Date, checkOutDate: Date): Promise<any> {
    try {
      this.logger.log(`Predicting price trend for property ${propertyId} from ${checkInDate} to ${checkOutDate}`);
      
      // In a real implementation, this would use historical data and ML models
      // For this example, we're using a simplified algorithm
      
      // Get current date
      const currentDate = new Date();
      
      // Calculate days until check-in
      const daysUntilCheckIn = Math.ceil((checkInDate.getTime() - currentDate.getTime()) / (1000 * 60 * 60 * 24));
      
      // Generate prediction based on days until check-in
      const prediction = this.generatePricePrediction(daysUntilCheckIn);
      
      return {
        propertyId,
        checkInDate,
        checkOutDate,
        currentDate,
        daysUntilCheckIn,
        prediction,
      };
    } catch (error) {
      this.logger.error(`Error predicting price trend: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Recommend optimal booking time for best price
   */
  async recommendBookingTime(propertyId: string, checkInDate: Date, checkOutDate: Date): Promise<any> {
    try {
      this.logger.log(`Recommending booking time for property ${propertyId} from ${checkInDate} to ${checkOutDate}`);
      
      // Get price prediction
      const pricePrediction = await this.predictPriceTrend(propertyId, checkInDate, checkOutDate);
      
      // Determine recommendation based on prediction
      const recommendation = this.generateBookingRecommendation(pricePrediction);
      
      return {
        ...pricePrediction,
        recommendation,
      };
    } catch (error) {
      this.logger.error(`Error recommending booking time: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Generate price prediction based on days until check-in
   * This is a simplified algorithm for demonstration purposes
   */
  private generatePricePrediction(daysUntilCheckIn: number): any {
    // Define price trend patterns based on days until check-in
    if (daysUntilCheckIn > 90) {
      // Far in advance: prices likely to drop before rising again
      return {
        trend: 'decreasing',
        confidence: 0.7,
        expectedPriceChange: -5,
        priceChangeRange: [-10, 0],
        dataPoints: this.generateMockDataPoints(daysUntilCheckIn, 'decreasing'),
      };
    } else if (daysUntilCheckIn > 30) {
      // Medium term: prices relatively stable
      return {
        trend: 'stable',
        confidence: 0.8,
        expectedPriceChange: 0,
        priceChangeRange: [-3, 3],
        dataPoints: this.generateMockDataPoints(daysUntilCheckIn, 'stable'),
      };
    } else if (daysUntilCheckIn > 14) {
      // Approaching check-in: prices likely to rise
      return {
        trend: 'increasing',
        confidence: 0.75,
        expectedPriceChange: 8,
        priceChangeRange: [3, 15],
        dataPoints: this.generateMockDataPoints(daysUntilCheckIn, 'increasing'),
      };
    } else if (daysUntilCheckIn > 3) {
      // Near check-in: prices rising sharply
      return {
        trend: 'sharply_increasing',
        confidence: 0.85,
        expectedPriceChange: 15,
        priceChangeRange: [10, 25],
        dataPoints: this.generateMockDataPoints(daysUntilCheckIn, 'sharply_increasing'),
      };
    } else {
      // Last minute: prices could go either way (either premium or discount)
      const isDiscount = Math.random() > 0.7; // 30% chance of last-minute discount
      
      if (isDiscount) {
        return {
          trend: 'last_minute_discount',
          confidence: 0.6,
          expectedPriceChange: -12,
          priceChangeRange: [-20, -5],
          dataPoints: this.generateMockDataPoints(daysUntilCheckIn, 'last_minute_discount'),
        };
      } else {
        return {
          trend: 'last_minute_premium',
          confidence: 0.65,
          expectedPriceChange: 20,
          priceChangeRange: [15, 30],
          dataPoints: this.generateMockDataPoints(daysUntilCheckIn, 'last_minute_premium'),
        };
      }
    }
  }

  /**
   * Generate booking recommendation based on price prediction
   */
  private generateBookingRecommendation(pricePrediction: any): any {
    const { trend, confidence, expectedPriceChange } = pricePrediction.prediction;
    
    // Generate recommendation based on trend
    switch (trend) {
      case 'decreasing':
        return {
          action: 'wait',
          reason: 'Prices are expected to decrease in the coming weeks.',
          optimalBookingTime: 'Wait until 30-45 days before check-in for best rates.',
          savingsPotential: `Potential savings of approximately ${Math.abs(expectedPriceChange)}%.`,
          confidence,
        };
        
      case 'stable':
        return {
          action: 'book_now',
          reason: 'Prices are relatively stable, with minimal expected changes.',
          optimalBookingTime: 'Current time is good for booking, minimal price fluctuations expected.',
          savingsPotential: 'Minimal savings potential by waiting.',
          confidence,
        };
        
      case 'increasing':
        return {
          action: 'book_soon',
          reason: 'Prices are expected to increase in the coming weeks.',
          optimalBookingTime: 'Book within the next 7 days to avoid price increases.',
          savingsPotential: `Potential additional cost of approximately ${expectedPriceChange}% if delayed.`,
          confidence,
        };
        
      case 'sharply_increasing':
        return {
          action: 'book_immediately',
          reason: 'Prices are expected to increase significantly very soon.',
          optimalBookingTime: 'Book immediately to secure current rates.',
          savingsPotential: `Potential additional cost of approximately ${expectedPriceChange}% if delayed.`,
          confidence,
        };
        
      case 'last_minute_discount':
        return {
          action: 'wait_for_discount',
          reason: 'There is a chance of last-minute discounts.',
          optimalBookingTime: 'Consider waiting until 1-2 days before check-in for possible discounts.',
          savingsPotential: `Potential savings of approximately ${Math.abs(expectedPriceChange)}%, but with higher risk.`,
          confidence,
        };
        
      case 'last_minute_premium':
        return {
          action: 'book_immediately',
          reason: 'Last-minute bookings are likely to be at premium rates.',
          optimalBookingTime: 'Book immediately to avoid last-minute premium pricing.',
          savingsPotential: `Potential additional cost of approximately ${expectedPriceChange}% if delayed.`,
          confidence,
        };
        
      default:
        return {
          action: 'book_now',
          reason: 'Insufficient data to make a specific recommendation.',
          optimalBookingTime: 'Current time is as good as any for booking.',
          savingsPotential: 'Unknown savings potential.',
          confidence: 0.5,
        };
    }
  }

  /**
   * Generate mock data points for visualization
   * In a real implementation, this would use historical data
   */
  private generateMockDataPoints(daysUntilCheckIn: number, trend: string): any[] {
    const dataPoints = [];
    const today = new Date();
    let basePrice = 100;
    
    // Generate data points for the past 30 days and future 30 days
    for (let i = -30; i <= 30; i++) {
      const date = new Date(today);
      date.setDate(date.getDate() + i);
      
      let priceModifier = 0;
      
      // Apply trend-based price modifications
      switch (trend) {
        case 'decreasing':
          priceModifier = i > 0 ? -0.2 * i : 0.1 * Math.abs(i);
          break;
        case 'stable':
          priceModifier = Math.sin(i * 0.2) * 3; // Small oscillations
          break;
        case 'increasing':
          priceModifier = i > 0 ? 0.3 * i : -0.1 * Math.abs(i);
          break;
        case 'sharply_increasing':
          priceModifier = i > 0 ? 0.5 * i : -0.1 * Math.abs(i);
          break;
        case 'last_minute_discount':
          priceModifier = i > 0 ? (i < 3 ? -15 : 0.3 * i) : -0.1 * Math.abs(i);
          break;
        case 'last_minute_premium':
          priceModifier = i > 0 ? (i < 3 ? 20 : 0.3 * i) : -0.1 * Math.abs(i);
          break;
      }
      
      // Add some randomness
      priceModifier += (Math.random() - 0.5) * 5;
      
      const price = basePrice + priceModifier;
      
      dataPoints.push({
        date: date.toISOString().split('T')[0],
        price: Math.max(price, basePrice * 0.7), // Ensure price doesn't go too low
        isForecast: i > 0,
      });
    }
    
    return dataPoints;
  }
}
