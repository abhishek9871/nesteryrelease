import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/models/subscription.dart';
import 'package:nestery_flutter/services/api_service.dart';

/// State for subscription data
class SubscriptionState {
  final Subscription? subscription;
  final bool isLoading;
  final String? error;
  final bool isProcessingPayment;

  SubscriptionState({
    this.subscription,
    this.isLoading = false,
    this.error,
    this.isProcessingPayment = false,
  });

  SubscriptionState copyWith({
    Subscription? subscription,
    bool? isLoading,
    String? error,
    bool? isProcessingPayment,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
    );
  }

  bool get isPremium => subscription?.isPremium ?? false;
  SubscriptionTier get currentTier => subscription?.tier ?? SubscriptionTier.free;
}

/// Subscription provider for managing premium subscriptions
class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final ApiService _apiService;

  SubscriptionNotifier(this._apiService) : super(SubscriptionState());

  /// Load current subscription
  Future<void> loadSubscription() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/subscriptions/current');

      if (response.statusCode == 200 && response.data != null) {
        final subscription = Subscription.fromJson(response.data);
        state = state.copyWith(subscription: subscription, isLoading: false);
      } else {
        // User has no subscription - set to free tier
        final freeSubscription = Subscription(
          id: 'free',
          userId: 'current-user',
          tier: SubscriptionTier.free,
          status: SubscriptionStatus.active,
          startDate: DateTime.now(),
          autoRenew: false,
        );
        state = state.copyWith(subscription: freeSubscription, isLoading: false);
      }
    } catch (e) {
      // Mock free subscription for development
      final freeSubscription = Subscription(
        id: 'free',
        userId: 'current-user',
        tier: SubscriptionTier.free,
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        autoRenew: false,
      );
      state = state.copyWith(subscription: freeSubscription, isLoading: false);
    }
  }

  /// Create Stripe checkout session and return session URL
  Future<String?> createCheckoutSession({
    required SubscriptionTier tier,
    required BillingPeriod period,
  }) async {
    state = state.copyWith(isProcessingPayment: true, error: null);

    try {
      final response = await _apiService.post('/subscriptions/checkout', data: {
        'tier': tier.value,
        'billingPeriod': period.value,
      });

      if (response.statusCode == 200) {
        state = state.copyWith(isProcessingPayment: false);
        return response.data['sessionUrl'];
      } else {
        state = state.copyWith(
          isProcessingPayment: false,
          error: 'Failed to create checkout session',
        );
        return null;
      }
    } catch (e) {
      state = state.copyWith(
        isProcessingPayment: false,
        error: 'Payment processing error: $e',
      );
      return null;
    }
  }

  /// Upgrade subscription to a new tier
  Future<bool> upgradeSubscription({
    required SubscriptionTier newTier,
    required BillingPeriod period,
  }) async {
    state = state.copyWith(isProcessingPayment: true, error: null);

    try {
      final response = await _apiService.post('/subscriptions/upgrade', data: {
        'tier': newTier.value,
        'billingPeriod': period.value,
      });

      if (response.statusCode == 200) {
        final subscription = Subscription.fromJson(response.data);
        state = state.copyWith(
          subscription: subscription,
          isProcessingPayment: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isProcessingPayment: false,
          error: 'Failed to upgrade subscription',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isProcessingPayment: false,
        error: 'Upgrade error: $e',
      );
      return false;
    }
  }

  /// Cancel subscription (will remain active until period end)
  Future<bool> cancelSubscription() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post('/subscriptions/cancel');

      if (response.statusCode == 200) {
        final subscription = Subscription.fromJson(response.data);
        state = state.copyWith(subscription: subscription, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to cancel subscription',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Cancellation error: $e',
      );
      return false;
    }
  }

  /// Resume a canceled subscription
  Future<bool> resumeSubscription() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.post('/subscriptions/resume');

      if (response.statusCode == 200) {
        final subscription = Subscription.fromJson(response.data);
        state = state.copyWith(subscription: subscription, isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to resume subscription',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Resume error: $e',
      );
      return false;
    }
  }

  /// Refresh subscription data
  Future<void> refresh() async {
    await loadSubscription();
  }
}

/// Provider for subscription management
final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SubscriptionNotifier(apiService);
});
