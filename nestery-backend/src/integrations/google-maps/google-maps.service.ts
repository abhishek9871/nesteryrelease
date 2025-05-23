import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { HttpService } from '@nestjs/axios';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';
import { firstValueFrom } from 'rxjs';

/**
 * Service for integrating with Google Maps API
 * Based on Google Maps API documentation (2025)
 */
@Injectable()
export class GoogleMapsService {
  private readonly apiUrl: string;
  private readonly apiKey: string;

  constructor(
    private readonly configService: ConfigService,
    private readonly httpService: HttpService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    this.logger.setContext('GoogleMapsService');
    this.apiUrl = this.configService.get<string>('GOOGLE_MAPS_API_URL');
    this.apiKey = this.configService.get<string>('GOOGLE_MAPS_API_KEY');
  }

  /**
   * Geocode an address to get coordinates
   */
  async geocodeAddress(address: string): Promise<any> {
    try {
      this.logger.log(`Geocoding address: ${address}`);
      
      // Make API request
      const response = await firstValueFrom(
        this.httpService.get(`${this.apiUrl}/geocode/json`, {
          params: {
            address,
            key: this.apiKey,
          },
        }),
      );
      
      if (response.data.status !== 'OK') {
        throw new Error(`Geocoding failed: ${response.data.status}`);
      }
      
      const result = response.data.results[0];
      
      return {
        latitude: result.geometry.location.lat,
        longitude: result.geometry.location.lng,
        formattedAddress: result.formatted_address,
        placeId: result.place_id,
      };
    } catch (error) {
      this.logger.error(`Error geocoding address: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Get nearby places of interest
   */
  async getNearbyPlaces(latitude: number, longitude: number, radius: number = 1000, type?: string): Promise<any[]> {
    try {
      this.logger.log(`Getting nearby places: lat=${latitude}, lng=${longitude}, radius=${radius}, type=${type}`);
      
      const params: any = {
        location: `${latitude},${longitude}`,
        radius,
        key: this.apiKey,
      };
      
      if (type) {
        params.type = type;
      }
      
      // Make API request
      const response = await firstValueFrom(
        this.httpService.get(`${this.apiUrl}/place/nearbysearch/json`, {
          params,
        }),
      );
      
      if (response.data.status !== 'OK' && response.data.status !== 'ZERO_RESULTS') {
        throw new Error(`Nearby search failed: ${response.data.status}`);
      }
      
      return response.data.results.map(place => ({
        id: place.place_id,
        name: place.name,
        latitude: place.geometry.location.lat,
        longitude: place.geometry.location.lng,
        address: place.vicinity,
        types: place.types,
        rating: place.rating,
        userRatingsTotal: place.user_ratings_total,
        icon: place.icon,
        photos: place.photos?.map(photo => ({
          reference: photo.photo_reference,
          width: photo.width,
          height: photo.height,
          url: this.getPhotoUrl(photo.photo_reference),
        })),
      }));
    } catch (error) {
      this.logger.error(`Error getting nearby places: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Get directions between two points
   */
  async getDirections(
    originLat: number,
    originLng: number,
    destinationLat: number,
    destinationLng: number,
    mode: string = 'driving',
  ): Promise<any> {
    try {
      this.logger.log(`Getting directions: origin=(${originLat},${originLng}), destination=(${destinationLat},${destinationLng}), mode=${mode}`);
      
      // Make API request
      const response = await firstValueFrom(
        this.httpService.get(`${this.apiUrl}/directions/json`, {
          params: {
            origin: `${originLat},${originLng}`,
            destination: `${destinationLat},${destinationLng}`,
            mode,
            key: this.apiKey,
          },
        }),
      );
      
      if (response.data.status !== 'OK') {
        throw new Error(`Directions request failed: ${response.data.status}`);
      }
      
      const route = response.data.routes[0];
      const leg = route.legs[0];
      
      return {
        distance: leg.distance,
        duration: leg.duration,
        startAddress: leg.start_address,
        endAddress: leg.end_address,
        steps: leg.steps.map(step => ({
          distance: step.distance,
          duration: step.duration,
          instructions: step.html_instructions,
          travelMode: step.travel_mode,
          polyline: step.polyline,
        })),
        polyline: route.overview_polyline,
      };
    } catch (error) {
      this.logger.error(`Error getting directions: ${error.message}`);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Get photo URL from photo reference
   */
  private getPhotoUrl(photoReference: string): string {
    return `${this.apiUrl}/place/photo?maxwidth=400&photoreference=${photoReference}&key=${this.apiKey}`;
  }
}
