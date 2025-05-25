import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios from 'axios';
import { LoggerService } from '../../core/logger/logger.service';
import { ExceptionService } from '../../core/exception/exception.service';

@Injectable()
export class GoogleMapsService {
  private readonly apiKey: string;
  private readonly mapsApiUrl: string = 'https://maps.googleapis.com/maps/api';
  private readonly routesApiUrl: string = 'https://routes.googleapis.com';

  constructor(
    private readonly configService: ConfigService,
    private readonly logger: LoggerService,
    private readonly exceptionService: ExceptionService,
  ) {
    this.apiKey = this.configService.get<string>('GOOGLE_MAPS_API_KEY');
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
      throw this.exceptionService.handleHttpError(error, 'Failed to geocode address');
    }
  }

  /**
   * Reverse geocode coordinates to get address
   */
  async reverseGeocode(lat: number, lng: number) {
    try {
      this.logger.debug(`Reverse geocoding coordinates: ${lat}, ${lng}`);
      
      const response = await axios.get(`${this.mapsApiUrl}/geocode/json`, {
        params: {
          latlng: `${lat},${lng}`,
          key: this.apiKey,
        },
      });
      
      if (response.data.status !== 'OK') {
        throw new Error(`Reverse geocoding failed: ${response.data.status}`);
      }
      
      const results = response.data.results;
      if (!results || results.length === 0) {
        throw new Error(`No results found for coordinates: ${lat}, ${lng}`);
      }
      
      return {
        formattedAddress: results[0].formatted_address,
        addressComponents: results[0].address_components,
        placeId: results[0].place_id,
      };
    } catch (error) {
      this.logger.error(`Error reverse geocoding: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to reverse geocode coordinates');
    }
  }

  /**
   * Get places nearby a location
   */
  async getNearbyPlaces(params: {
    lat: number;
    lng: number;
    radius: number;
    type?: string;
    keyword?: string;
    language?: string;
  }) {
    try {
      this.logger.debug(`Getting nearby places for location: ${params.lat}, ${params.lng}`);
      
      const response = await axios.get(`${this.mapsApiUrl}/place/nearbysearch/json`, {
        params: {
          location: `${params.lat},${params.lng}`,
          radius: params.radius,
          type: params.type,
          keyword: params.keyword,
          language: params.language || 'en',
          key: this.apiKey,
        },
      });
      
      if (response.data.status !== 'OK' && response.data.status !== 'ZERO_RESULTS') {
        throw new Error(`Nearby places request failed: ${response.data.status}`);
      }
      
      return {
        places: response.data.results.map(place => ({
          id: place.place_id,
          name: place.name,
          address: place.vicinity,
          location: place.geometry.location,
          types: place.types,
          rating: place.rating,
          userRatingsTotal: place.user_ratings_total,
          photos: place.photos,
          openNow: place.opening_hours?.open_now,
          priceLevel: place.price_level,
        })),
        nextPageToken: response.data.next_page_token,
      };
    } catch (error) {
      this.logger.error(`Error getting nearby places: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to get nearby places');
    }
  }

  /**
   * Get place details
   */
  async getPlaceDetails(placeId: string, language: string = 'en') {
    try {
      this.logger.debug(`Getting place details for ID: ${placeId}`);
      
      const response = await axios.get(`${this.mapsApiUrl}/place/details/json`, {
        params: {
          place_id: placeId,
          language,
          fields: 'name,formatted_address,geometry,photos,rating,reviews,types,website,formatted_phone_number,opening_hours',
          key: this.apiKey,
        },
      });
      
      if (response.data.status !== 'OK') {
        throw new Error(`Place details request failed: ${response.data.status}`);
      }
      
      const place = response.data.result;
      return {
        id: place.place_id,
        name: place.name,
        address: place.formatted_address,
        location: place.geometry.location,
        types: place.types,
        rating: place.rating,
        reviews: place.reviews,
        photos: place.photos,
        website: place.website,
        phoneNumber: place.formatted_phone_number,
        openingHours: place.opening_hours,
      };
    } catch (error) {
      this.logger.error(`Error getting place details: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to get place details');
    }
  }

  /**
   * Get route using the new Routes API (replacing Directions API)
   */
  async getRoute(params: {
    originLat: number;
    originLng: number;
    destinationLat: number;
    destinationLng: number;
    travelMode?: string;
    routingPreference?: string;
    language?: string;
    units?: string;
  }) {
    try {
      this.logger.debug(`Getting route from (${params.originLat}, ${params.originLng}) to (${params.destinationLat}, ${params.destinationLng})`);
      
      // Routes API uses POST instead of GET
      const response = await axios.post(
        `${this.routesApiUrl}/routes/v2:computeRoutes`,
        {
          origin: {
            location: {
              latLng: {
                latitude: params.originLat,
                longitude: params.originLng,
              },
            },
          },
          destination: {
            location: {
              latLng: {
                latitude: params.destinationLat,
                longitude: params.destinationLng,
              },
            },
          },
          travelMode: params.travelMode || 'DRIVE',
          routingPreference: params.routingPreference || 'TRAFFIC_AWARE',
          computeAlternativeRoutes: true,
          routeModifiers: {
            avoidTolls: false,
            avoidHighways: false,
            avoidFerries: false,
          },
          languageCode: params.language || 'en',
          units: params.units || 'METRIC',
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': this.apiKey,
            'X-Goog-FieldMask': 'routes.duration,routes.distanceMeters,routes.polyline.encodedPolyline,routes.legs',
          },
        }
      );
      
      return {
        routes: response.data.routes.map(route => ({
          duration: route.duration,
          distance: route.distanceMeters,
          polyline: route.polyline.encodedPolyline,
          legs: route.legs,
        })),
      };
    } catch (error) {
      this.logger.error(`Error getting route: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to get route');
    }
  }

  /**
   * Get distance matrix using the new Routes API (replacing Distance Matrix API)
   */
  async getDistanceMatrix(params: {
    origins: Array<{ lat: number; lng: number }>;
    destinations: Array<{ lat: number; lng: number }>;
    travelMode?: string;
    routingPreference?: string;
    language?: string;
    units?: string;
  }) {
    try {
      this.logger.debug(`Getting distance matrix for ${params.origins.length} origins and ${params.destinations.length} destinations`);
      
      // Routes API uses POST instead of GET
      const response = await axios.post(
        `${this.routesApiUrl}/distancematrix/v2:computeRouteMatrix`,
        {
          origins: params.origins.map(origin => ({
            waypoint: {
              location: {
                latLng: {
                  latitude: origin.lat,
                  longitude: origin.lng,
                },
              },
            },
          })),
          destinations: params.destinations.map(destination => ({
            waypoint: {
              location: {
                latLng: {
                  latitude: destination.lat,
                  longitude: destination.lng,
                },
              },
            },
          })),
          travelMode: params.travelMode || 'DRIVE',
          routingPreference: params.routingPreference || 'TRAFFIC_AWARE',
          languageCode: params.language || 'en',
          units: params.units || 'METRIC',
        },
        {
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': this.apiKey,
            'X-Goog-FieldMask': 'originIndex,destinationIndex,duration,distanceMeters,status',
          },
        }
      );
      
      // Transform the response to a more usable format
      const matrix = Array(params.origins.length).fill(null).map(() => 
        Array(params.destinations.length).fill(null)
      );
      
      response.data.forEach(element => {
        matrix[element.originIndex][element.destinationIndex] = {
          duration: element.duration,
          distance: element.distanceMeters,
          status: element.status,
        };
      });
      
      return {
        matrix,
        originAddresses: params.origins.map((_, i) => `Origin ${i}`),
        destinationAddresses: params.destinations.map((_, i) => `Destination ${i}`),
      };
    } catch (error) {
      this.logger.error(`Error getting distance matrix: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to get distance matrix');
    }
  }

  /**
   * Get autocomplete predictions
   */
  async getPlaceAutocomplete(params: {
    input: string;
    sessionToken?: string;
    lat?: number;
    lng?: number;
    radius?: number;
    types?: string;
    components?: string;
    strictbounds?: boolean;
    language?: string;
  }) {
    try {
      this.logger.debug(`Getting place autocomplete for input: ${params.input}`);
      
      const response = await axios.get(`${this.mapsApiUrl}/place/autocomplete/json`, {
        params: {
          input: params.input,
          sessiontoken: params.sessionToken,
          location: params.lat && params.lng ? `${params.lat},${params.lng}` : undefined,
          radius: params.radius,
          types: params.types,
          components: params.components,
          strictbounds: params.strictbounds,
          language: params.language || 'en',
          key: this.apiKey,
        },
      });
      
      if (response.data.status !== 'OK' && response.data.status !== 'ZERO_RESULTS') {
        throw new Error(`Place autocomplete request failed: ${response.data.status}`);
      }
      
      return {
        predictions: response.data.predictions.map(prediction => ({
          id: prediction.place_id,
          description: prediction.description,
          mainText: prediction.structured_formatting.main_text,
          secondaryText: prediction.structured_formatting.secondary_text,
          types: prediction.types,
        })),
      };
    } catch (error) {
      this.logger.error(`Error getting place autocomplete: ${error.message}`, error.stack);
      throw this.exceptionService.handleHttpError(error, 'Failed to get place autocomplete');
    }
  }

  /**
   * Get static map image URL
   */
  getStaticMapUrl(params: {
    center: { lat: number; lng: number };
    zoom: number;
    width: number;
    height: number;
    markers?: Array<{ lat: number; lng: number; color?: string; label?: string }>;
    paths?: Array<{ points: Array<{ lat: number; lng: number }>; color?: string; weight?: number }>;
    mapType?: string;
    format?: string;
    language?: string;
  }): string {
    this.logger.debug(`Generating static map URL for center: ${params.center.lat}, ${params.center.lng}`);
    
    let url = `${this.mapsApiUrl}/staticmap?`;
    url += `center=${params.center.lat},${params.center.lng}`;
    url += `&zoom=${params.zoom}`;
    url += `&size=${params.width}x${params.height}`;
    url += `&maptype=${params.mapType || 'roadmap'}`;
    url += `&format=${params.format || 'png'}`;
    url += `&language=${params.language || 'en'}`;
    
    // Add markers
    if (params.markers && params.markers.length > 0) {
      for (const marker of params.markers) {
        url += '&markers=';
        if (marker.color) url += `color:${marker.color}|`;
        if (marker.label) url += `label:${marker.label}|`;
        url += `${marker.lat},${marker.lng}`;
      }
    }
    
    // Add paths
    if (params.paths && params.paths.length > 0) {
      for (const path of params.paths) {
        url += '&path=';
        if (path.color) url += `color:${path.color}|`;
        if (path.weight) url += `weight:${path.weight}|`;
        
        url += path.points.map(point => `${point.lat},${point.lng}`).join('|');
      }
    }
    
    url += `&key=${this.apiKey}`;
    
    return url;
  }
}
