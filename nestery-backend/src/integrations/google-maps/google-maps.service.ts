import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';

interface NearbyPlace {
  place_id: string;
  name: string;
  vicinity: string;
  types: string[];
  rating?: number;
  user_ratings_total?: number;
  geometry: {
    location: {
      lat: number;
      lng: number;
    };
  };
  photos?: Array<{
    photo_reference: string;
    height: number;
    width: number;
  }>;
  price_level?: number;
  opening_hours?: {
    open_now: boolean;
  };
}

interface PlacePhoto {
  photo_reference: string;
  height: number;
  width: number;
}

interface PlaceReview {
  author_name: string;
  rating: number;
  text: string;
  time: number;
}

interface PlacePrediction {
  place_id: string;
  description: string;
  structured_formatting: {
    main_text: string;
    secondary_text: string;
  };
  types: string[];
}

interface DirectionStep {
  distance: {
    text: string;
    value: number;
  };
  duration: {
    text: string;
    value: number;
  };
  html_instructions: string;
  travel_mode: string;
}

@Injectable()
export class GoogleMapsService {
  private readonly apiKey: string = '';
  private readonly mapsApiUrl: string = 'https://maps.googleapis.com/maps/api';
  private readonly routesApiUrl: string = 'https://routes.googleapis.com';

  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    const apiKey = this.configService.get<string>('GOOGLE_MAPS_API_KEY');
    if (apiKey) this.apiKey = apiKey;
    this.logger.setContext('GoogleMapsService');
  }

  /**
   * Geocode an address to get coordinates
   */
  async geocodeAddress(address: string) {
    try {
      this.logger.debug(`Geocoding address: ${address}`);

      const response = await axios.get(`${this.mapsApiUrl}/geocode/json`, {
        params: {
          address,
          key: this.apiKey,
        },
      });

      if (response.data.status !== 'OK') {
        throw new Error(`Geocoding failed: ${response.data.status}`);
      }

      const results = response.data.results;
      if (!results || results.length === 0) {
        throw new Error(`No results found for address: ${address}`);
      }

      const location = results[0].geometry.location;
      return {
        lat: location.lat,
        lng: location.lng,
        formattedAddress: results[0].formatted_address,
        placeId: results[0].place_id,
      };
    } catch (error) {
      this.logger.error(`Error geocoding address: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      throw error;
    }
  }

  /**
   * Get nearby places based on location
   */
  async getNearbyPlaces(
    latitude: number,
    longitude: number,
    radius: number = 1000,
    type: string = 'restaurant',
  ) {
    try {
      this.logger.debug(
        `Getting nearby places at ${latitude},${longitude} with radius ${radius}m and type ${type}`,
      );

      const response = await axios.get(`${this.mapsApiUrl}/place/nearbysearch/json`, {
        params: {
          location: `${latitude},${longitude}`,
          radius,
          type,
          key: this.apiKey,
        },
      });

      if (response.data.status !== 'OK' && response.data.status !== 'ZERO_RESULTS') {
        throw new Error(`Nearby places search failed: ${response.data.status}`);
      }

      const places = response.data.results || [];

      return {
        success: true,
        places: places.map((place: NearbyPlace) => ({
          id: place.place_id,
          name: place.name,
          address: place.vicinity,
          types: place.types,
          rating: place.rating,
          reviewCount: place.user_ratings_total,
          latitude: place.geometry.location.lat,
          longitude: place.geometry.location.lng,
          photoReference: place.photos?.[0]?.photo_reference,
          priceLevel: place.price_level,
          openNow: place.opening_hours?.open_now,
        })),
      };
    } catch (error) {
      this.logger.error(`Error getting nearby places: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        error: `Failed to get nearby places: ${error.message}`,
      };
    }
  }

  /**
   * Get place details
   */
  async getPlaceDetails(placeId: string) {
    try {
      this.logger.debug(`Getting place details for ID: ${placeId}`);

      const response = await axios.get(`${this.mapsApiUrl}/place/details/json`, {
        params: {
          place_id: placeId,
          fields:
            'name,formatted_address,geometry,rating,formatted_phone_number,website,opening_hours,photos,price_level,review',
          key: this.apiKey,
        },
      });

      if (response.data.status !== 'OK') {
        throw new Error(`Place details request failed: ${response.data.status}`);
      }

      const place = response.data.result;

      return {
        success: true,
        place: {
          id: place.place_id,
          name: place.name,
          address: place.formatted_address,
          latitude: place.geometry.location.lat,
          longitude: place.geometry.location.lng,
          rating: place.rating,
          phoneNumber: place.formatted_phone_number,
          website: place.website,
          openingHours: place.opening_hours?.weekday_text,
          openNow: place.opening_hours?.open_now,
          photos: place.photos?.map((photo: PlacePhoto) => ({
            reference: photo.photo_reference,
            width: photo.width,
            height: photo.height,
          })),
          priceLevel: place.price_level,
          reviews: place.reviews?.map((review: PlaceReview) => ({
            author: review.author_name,
            rating: review.rating,
            text: review.text,
            time: review.time,
          })),
        },
      };
    } catch (error) {
      this.logger.error(`Error getting place details: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        error: `Failed to get place details: ${error.message}`,
      };
    }
  }

  /**
   * Get place autocomplete suggestions
   */
  async getPlaceAutocomplete(input: string, sessionToken: string, types: string = 'establishment') {
    try {
      this.logger.debug(`Getting place autocomplete for input: ${input}`);

      const response = await axios.get(`${this.mapsApiUrl}/place/autocomplete/json`, {
        params: {
          input,
          types,
          sessiontoken: sessionToken,
          key: this.apiKey,
        },
      });

      if (response.data.status !== 'OK' && response.data.status !== 'ZERO_RESULTS') {
        throw new Error(`Place autocomplete request failed: ${response.data.status}`);
      }

      const predictions = response.data.predictions || [];

      return {
        success: true,
        predictions: predictions.map((prediction: PlacePrediction) => ({
          id: prediction.place_id,
          description: prediction.description,
          mainText: prediction.structured_formatting.main_text,
          secondaryText: prediction.structured_formatting.secondary_text,
          types: prediction.types,
        })),
      };
    } catch (error) {
      this.logger.error(`Error getting place autocomplete: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        error: `Failed to get place autocomplete: ${error.message}`,
      };
    }
  }

  /**
   * Get directions between two points
   */
  async getDirections(origin: string, destination: string, mode: string = 'driving') {
    try {
      this.logger.debug(`Getting directions from ${origin} to ${destination} via ${mode}`);

      const response = await axios.get(`${this.mapsApiUrl}/directions/json`, {
        params: {
          origin,
          destination,
          mode,
          key: this.apiKey,
        },
      });

      if (response.data.status !== 'OK') {
        throw new Error(`Directions request failed: ${response.data.status}`);
      }

      const routes = response.data.routes;
      if (!routes || routes.length === 0) {
        throw new Error('No routes found');
      }

      const route = routes[0];
      const leg = route.legs[0];

      return {
        success: true,
        route: {
          distance: leg.distance.text,
          distanceValue: leg.distance.value,
          duration: leg.duration.text,
          durationValue: leg.duration.value,
          startAddress: leg.start_address,
          endAddress: leg.end_address,
          startLocation: leg.start_location,
          endLocation: leg.end_location,
          steps: leg.steps.map((step: DirectionStep) => ({
            distance: step.distance.text,
            duration: step.duration.text,
            instructions: step.html_instructions,
            travelMode: step.travel_mode,
          })),
          polyline: route.overview_polyline.points,
        },
      };
    } catch (error) {
      this.logger.error(`Error getting directions: ${error.message}`, error.stack);
      this.exceptionService.handleException(error);
      return {
        success: false,
        error: `Failed to get directions: ${error.message}`,
      };
    }
  }
}
