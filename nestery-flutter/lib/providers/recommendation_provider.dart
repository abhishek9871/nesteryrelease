import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/core/network/api_client.dart';
import 'package:nestery_flutter/utils/constants.dart';
import 'package:nestery_flutter/utils/api_exception.dart';

// Recommendation state
class RecommendationState {
  final List<Map<String, dynamic>> recommendations;
  final bool isLoading;
  final String? error;

  RecommendationState({
    this.recommendations = const [],
    this.isLoading = false,
    this.error,
  });

  // Create a new instance with updated values
  RecommendationState copyWith({
    List<Map<String, dynamic>>? recommendations,
    bool? isLoading,
    String? error,
  }) {
    return RecommendationState(
      recommendations: recommendations ?? this.recommendations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Recommendation provider
class RecommendationNotifier extends StateNotifier<RecommendationState> {
  final ApiClient _apiClient;

  RecommendationNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(RecommendationState());

  // Get personalized recommendations
  Future<void> getPersonalizedRecommendations() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _apiClient.get(
        Constants.recommendationsEndpoint,
      );

      state = state.copyWith(
        recommendations: List<Map<String, dynamic>>.from(response),
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

  // Get recommendations based on a property
  Future<void> getRecommendationsBasedOnProperty(String propertyId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _apiClient.get(
        '${Constants.recommendationsEndpoint}/property/$propertyId',
      );

      state = state.copyWith(
        recommendations: List<Map<String, dynamic>>.from(response),
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

  // Get AI trip itinerary
  Future<Map<String, dynamic>> generateTripItinerary({
    required String destination,
    required DateTime startDate,
    required DateTime endDate,
    required int travelers,
    Map<String, dynamic>? preferences,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _apiClient.post(
        '${Constants.recommendationsEndpoint}/trip-weaver',
        data: {
          'destination': destination,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'travelers': travelers,
          'preferences': preferences,
        },
      );

      state = state.copyWith(isLoading: false);

      return response;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return {'error': e.message};
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return {'error': e.toString()};
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Price prediction state
class PricePredictionState {
  final Map<String, dynamic>? prediction;
  final bool isLoading;
  final String? error;

  PricePredictionState({
    this.prediction,
    this.isLoading = false,
    this.error,
  });

  // Create a new instance with updated values
  PricePredictionState copyWith({
    Map<String, dynamic>? prediction,
    bool? isLoading,
    String? error,
  }) {
    return PricePredictionState(
      prediction: prediction ?? this.prediction,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Price prediction provider
class PricePredictionNotifier extends StateNotifier<PricePredictionState> {
  final ApiClient _apiClient;

  PricePredictionNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(PricePredictionState());

  // Get price prediction for a property
  Future<void> getPricePrediction({
    required String propertyId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guests,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _apiClient.get(
        Constants.pricePredictionEndpoint,
        queryParameters: {
          'propertyId': propertyId,
          'checkInDate': checkInDate.toIso8601String(),
          'checkOutDate': checkOutDate.toIso8601String(),
          'guests': guests,
        },
      );

      state = state.copyWith(
        prediction: response,
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

  // Get price trends for a location
  Future<Map<String, dynamic>> getPriceTrends({
    required String location,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _apiClient.get(
        '${Constants.pricePredictionEndpoint}/trends',
        queryParameters: {
          'location': location,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
        },
      );

      state = state.copyWith(isLoading: false);

      return response;
    } on ApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );
      return {'error': e.message};
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return {'error': e.toString()};
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Clear state
  void clearState() {
    state = PricePredictionState();
  }
}

// Providers
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final recommendationProvider = StateNotifierProvider<RecommendationNotifier, RecommendationState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RecommendationNotifier(apiClient: apiClient);
});

final pricePredictionProvider = StateNotifierProvider<PricePredictionNotifier, PricePredictionState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PricePredictionNotifier(apiClient: apiClient);
});
