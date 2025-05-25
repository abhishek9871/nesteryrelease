import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/data/repositories/property_repository.dart';
import 'package:nestery_flutter/models/property.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

// Property search state
class PropertySearchState {
  final List<Property> properties;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;
  final Map<String, dynamic> filters;

  PropertySearchState({
    this.properties = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
    this.filters = const {},
  });

  // Create a new instance with updated values
  PropertySearchState copyWith({
    List<Property>? properties,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
    Map<String, dynamic>? filters,
  }) {
    return PropertySearchState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filters: filters ?? this.filters,
    );
  }
}

// Property search provider
class PropertySearchNotifier extends StateNotifier<PropertySearchState> {
  final PropertyRepository _propertyRepository;

  PropertySearchNotifier({required PropertyRepository propertyRepository})
      : _propertyRepository = propertyRepository,
        super(PropertySearchState());

  // Search properties with filters
  Future<void> searchProperties({
    String? location,
    DateTime? checkIn,
    DateTime? checkOut,
    int? guests,
    double? minPrice,
    double? maxPrice,
    List<String>? amenities,
    String? propertyType,
    double? minRating,
    String? sortBy,
    String? sortOrder,
    bool reset = true,
  }) async {
    try {
      // If reset is true, start a new search
      if (reset) {
        state = PropertySearchState(
          isLoading: true,
          filters: {
            'location': location,
            'checkIn': checkIn,
            'checkOut': checkOut,
            'guests': guests,
            'minPrice': minPrice,
            'maxPrice': maxPrice,
            'amenities': amenities,
            'propertyType': propertyType,
            'minRating': minRating,
            'sortBy': sortBy,
            'sortOrder': sortOrder,
          },
        );
      } else {
        // Otherwise, load more results
        state = state.copyWith(
          isLoading: true,
          error: null,
        );
      }

      final properties = await _propertyRepository.searchProperties(
        location: location ?? state.filters['location'],
        checkIn: checkIn ?? state.filters['checkIn'],
        checkOut: checkOut ?? state.filters['checkOut'],
        guests: guests ?? state.filters['guests'],
        minPrice: minPrice ?? state.filters['minPrice'],
        maxPrice: maxPrice ?? state.filters['maxPrice'],
        amenities: amenities ?? state.filters['amenities'],
        propertyType: propertyType ?? state.filters['propertyType'],
        minRating: minRating ?? state.filters['minRating'],
        sortBy: sortBy ?? state.filters['sortBy'],
        sortOrder: sortOrder ?? state.filters['sortOrder'],
        page: reset ? 1 : state.currentPage + 1,
      );

      // Update state with new results
      if (reset) {
        state = state.copyWith(
          properties: properties,
          isLoading: false,
          hasMore: properties.length >= 10, // Assuming page size is 10
          currentPage: 1,
        );
      } else {
        state = state.copyWith(
          properties: [...state.properties, ...properties],
          isLoading: false,
          hasMore: properties.length >= 10, // Assuming page size is 10
          currentPage: state.currentPage + 1,
        );
      }
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load more results
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    await searchProperties(
      location: state.filters['location'],
      checkIn: state.filters['checkIn'],
      checkOut: state.filters['checkOut'],
      guests: state.filters['guests'],
      minPrice: state.filters['minPrice'],
      maxPrice: state.filters['maxPrice'],
      amenities: state.filters['amenities'],
      propertyType: state.filters['propertyType'],
      minRating: state.filters['minRating'],
      sortBy: state.filters['sortBy'],
      sortOrder: state.filters['sortOrder'],
      reset: false,
    );
  }

  // Clear search results and filters
  void clearSearch() {
    state = PropertySearchState();
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Featured properties state
class FeaturedPropertiesState {
  final List<Property> properties;
  final bool isLoading;
  final String? error;

  FeaturedPropertiesState({
    this.properties = const [],
    this.isLoading = false,
    this.error,
  });

  // Create a new instance with updated values
  FeaturedPropertiesState copyWith({
    List<Property>? properties,
    bool? isLoading,
    String? error,
  }) {
    return FeaturedPropertiesState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Featured properties provider
class FeaturedPropertiesNotifier extends StateNotifier<FeaturedPropertiesState> {
  final PropertyRepository _propertyRepository;

  FeaturedPropertiesNotifier({required PropertyRepository propertyRepository})
      : _propertyRepository = propertyRepository,
        super(FeaturedPropertiesState()) {
    // Load featured properties on initialization
    loadFeaturedProperties();
  }

  // Load featured properties
  Future<void> loadFeaturedProperties() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final properties = await _propertyRepository.getFeaturedProperties();

      state = state.copyWith(
        properties: properties,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Property details state
class PropertyDetailsState {
  final Property? property;
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? availability;
  final Map<String, dynamic>? reviews;
  final List<Property> similarProperties;

  PropertyDetailsState({
    this.property,
    this.isLoading = false,
    this.error,
    this.availability,
    this.reviews,
    this.similarProperties = const [],
  });

  // Create a new instance with updated values
  PropertyDetailsState copyWith({
    Property? property,
    bool? isLoading,
    String? error,
    Map<String, dynamic>? availability,
    Map<String, dynamic>? reviews,
    List<Property>? similarProperties,
  }) {
    return PropertyDetailsState(
      property: property ?? this.property,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      availability: availability ?? this.availability,
      reviews: reviews ?? this.reviews,
      similarProperties: similarProperties ?? this.similarProperties,
    );
  }
}

// Property details provider
class PropertyDetailsNotifier extends StateNotifier<PropertyDetailsState> {
  final PropertyRepository _propertyRepository;

  PropertyDetailsNotifier({required PropertyRepository propertyRepository})
      : _propertyRepository = propertyRepository,
        super(PropertyDetailsState());

  // Load property details
  Future<void> loadPropertyDetails(String propertyId) async {
    try {
      state = PropertyDetailsState(isLoading: true);

      final property = await _propertyRepository.getPropertyDetails(propertyId);

      state = state.copyWith(
        property: property,
        isLoading: false,
      );

      // Load additional data in parallel
      loadPropertyAvailability(propertyId);
      loadPropertyReviews(propertyId);
      loadSimilarProperties(propertyId);
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Load property availability
  Future<void> loadPropertyAvailability(
    String propertyId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final now = DateTime.now();
      final start = startDate ?? now;
      final end = endDate ?? now.add(const Duration(days: 30));

      final availability = await _propertyRepository.getPropertyAvailability(
        propertyId,
        startDate: start,
        endDate: end,
      );

      state = state.copyWith(availability: availability);
    } catch (e) {
      // Don't update error state, just log it
      print('Error loading availability: $e');
    }
  }

  // Load property reviews
  Future<void> loadPropertyReviews(String propertyId) async {
    try {
      final reviews = await _propertyRepository.getPropertyReviews(propertyId);

      state = state.copyWith(reviews: reviews);
    } catch (e) {
      // Don't update error state, just log it
      print('Error loading reviews: $e');
    }
  }

  // Load similar properties
  Future<void> loadSimilarProperties(String propertyId) async {
    try {
      final similarProperties = await _propertyRepository.getSimilarProperties(propertyId);

      state = state.copyWith(similarProperties: similarProperties);
    } catch (e) {
      // Don't update error state, just log it
      print('Error loading similar properties: $e');
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear state
  void clearState() {
    state = PropertyDetailsState();
  }
}

// Trending destinations state
class TrendingDestinationsState {
  final List<Map<String, dynamic>> destinations;
  final bool isLoading;
  final String? error;

  TrendingDestinationsState({
    this.destinations = const [],
    this.isLoading = false,
    this.error,
  });

  // Create a new instance with updated values
  TrendingDestinationsState copyWith({
    List<Map<String, dynamic>>? destinations,
    bool? isLoading,
    String? error,
  }) {
    return TrendingDestinationsState(
      destinations: destinations ?? this.destinations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Trending destinations provider
class TrendingDestinationsNotifier extends StateNotifier<TrendingDestinationsState> {
  final PropertyRepository _propertyRepository;

  TrendingDestinationsNotifier({required PropertyRepository propertyRepository})
      : _propertyRepository = propertyRepository,
        super(TrendingDestinationsState()) {
    // Load trending destinations on initialization
    loadTrendingDestinations();
  }

  // Load trending destinations
  Future<void> loadTrendingDestinations() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final destinations = await _propertyRepository.getTrendingDestinations();

      state = state.copyWith(
        destinations: destinations,
        isLoading: false,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Providers
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PropertyRepository(apiClient: apiClient);
});

final propertySearchProvider = StateNotifierProvider<PropertySearchNotifier, PropertySearchState>((ref) {
  final propertyRepository = ref.watch(propertyRepositoryProvider);
  return PropertySearchNotifier(propertyRepository: propertyRepository);
});

final featuredPropertiesProvider = StateNotifierProvider<FeaturedPropertiesNotifier, FeaturedPropertiesState>((ref) {
  final propertyRepository = ref.watch(propertyRepositoryProvider);
  return FeaturedPropertiesNotifier(propertyRepository: propertyRepository);
});

final propertyDetailsProvider = StateNotifierProvider.family<PropertyDetailsNotifier, PropertyDetailsState, String>((ref, propertyId) {
  final propertyRepository = ref.watch(propertyRepositoryProvider);
  final notifier = PropertyDetailsNotifier(propertyRepository: propertyRepository);
  notifier.loadPropertyDetails(propertyId);
  return notifier;
});

final trendingDestinationsProvider = StateNotifierProvider<TrendingDestinationsNotifier, TrendingDestinationsState>((ref) {
  final propertyRepository = ref.watch(propertyRepositoryProvider);
  return TrendingDestinationsNotifier(propertyRepository: propertyRepository);
});
