import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nestery_flutter/providers/auth_provider.dart'; // To get user premium status

class AdServiceState {
  final Map<String, BannerAd?> bannerAds;
  final bool sdkInitialized;

  AdServiceState({
    this.bannerAds = const {},
    this.sdkInitialized = false,
  });

  AdServiceState copyWith({
    Map<String, BannerAd?>? bannerAds,
    bool? sdkInitialized,
  }) {
    return AdServiceState(
      bannerAds: bannerAds ?? this.bannerAds,
      sdkInitialized: sdkInitialized ?? this.sdkInitialized,
    );
  }
}

class AdService extends StateNotifier<AdServiceState> {
  final Ref _ref;

  AdService(this._ref) : super(AdServiceState());

  // Test Ad Unit IDs (replace with your actual IDs for production)
  // TODO: Replace with your real AdMob Ad Unit IDs for production
  static const String _androidBannerTestId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerTestId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _androidInterstitialTestId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _iosInterstitialTestId = 'ca-app-pub-3940256099942544/4411468910';

  String get _bannerAdUnitId => Platform.isAndroid ? _androidBannerTestId : _iosBannerTestId;
  String get _interstitialAdUnitId => Platform.isAndroid ? _androidInterstitialTestId : _iosInterstitialTestId;

  bool get _isUserPremium => _ref.read(authProvider).user?.isPremium ?? false;

  final Map<String, InterstitialAd?> _preloadedInterstitialAds = {};

  Future<void> initialize() async {
    if (state.sdkInitialized) return;
    try {
      await MobileAds.instance.initialize();
      state = state.copyWith(sdkInitialized: true);
      debugPrint("AdMob SDK Initialized");
    } catch (e) {
      debugPrint("Error initializing AdMob SDK: $e");
    }
  }

  Widget? createBannerAdWidget(BuildContext context, {AdSize adSize = AdSize.banner, required String placementIdentifier}) {
    if (!state.sdkInitialized || _isUserPremium) {
      return const SizedBox.shrink();
    }

    final existingAd = state.bannerAds[placementIdentifier];
    if (existingAd != null) {
      return SizedBox(
        width: adSize.width.toDouble(),
        height: adSize.height.toDouble(),
        child: AdWidget(ad: existingAd),
      );
    }

    _loadBannerAd(placementIdentifier, adSize);
    // Return a placeholder while the ad is loading. The UI will rebuild when the ad is loaded.
    return SizedBox(
      width: adSize.width.toDouble(),
      height: adSize.height.toDouble(),
      child: const Center(child: Text("Ad loading...")), // Placeholder
    );
  }

  void _loadBannerAd(String placementIdentifier, AdSize adSize) {
    // Avoid reloading if already in state (could be null if failed previously, allow retry)
    if (state.bannerAds.containsKey(placementIdentifier) && state.bannerAds[placementIdentifier] != null) {
        return;
    }

    final ad = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('BannerAd loaded for $placementIdentifier');
          final newBannerAds = Map<String, BannerAd?>.from(state.bannerAds);
          newBannerAds[placementIdentifier] = ad as BannerAd;
          if (mounted) {
            state = state.copyWith(bannerAds: newBannerAds);
          } else {
            ad.dispose(); // Dispose if notifier is no longer mounted
          }
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('BannerAd failed to load for $placementIdentifier: $error');
          ad.dispose();
          final newBannerAds = Map<String, BannerAd?>.from(state.bannerAds);
          newBannerAds.remove(placementIdentifier); // Or newBannerAds[placementIdentifier] = null; to prevent reload attempts
          if (mounted) {
            state = state.copyWith(bannerAds: newBannerAds);
          }
        },
      ),
    );
    ad.load();
  }

  Future<void> preloadInterstitialAd({required String placementIdentifier}) async {
    if (!state.sdkInitialized || _isUserPremium || _preloadedInterstitialAds.containsKey(placementIdentifier)) {
      return;
    }

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('InterstitialAd loaded for $placementIdentifier');
          _preloadedInterstitialAds[placementIdentifier] = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load for $placementIdentifier: $error');
          _preloadedInterstitialAds.remove(placementIdentifier);
        },
      ),
    );
  }

  void showInterstitialAd({
    required String placementIdentifier,
    required Function onAdDismissed,
    Function? onAdFailedToShow,
  }) {
    if (!state.sdkInitialized || _isUserPremium) {
      onAdDismissed();
      return;
    }

    final ad = _preloadedInterstitialAds[placementIdentifier];
    if (ad == null) {
      debugPrint('InterstitialAd for $placementIdentifier not preloaded.');
      onAdDismissed();
      // Optionally, try to preload again for next time
      preloadInterstitialAd(placementIdentifier: placementIdentifier);
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          debugPrint('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        onAdDismissed();
        ad.dispose();
        _preloadedInterstitialAds.remove(placementIdentifier);
        // Preload the next ad for this placement
        preloadInterstitialAd(placementIdentifier: placementIdentifier);
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        if (onAdFailedToShow != null) {
          onAdFailedToShow();
        } else {
          onAdDismissed();
        }
        ad.dispose();
        _preloadedInterstitialAds.remove(placementIdentifier);
        // Optionally, try to preload again
        preloadInterstitialAd(placementIdentifier: placementIdentifier);
      },
    );
    ad.show();
  }

  @override
  void dispose() {
    // Dispose all loaded banner ads
    for (var ad in state.bannerAds.values) {
      ad?.dispose();
    }
    // Dispose all preloaded interstitial ads
    for (var ad in _preloadedInterstitialAds.values) {
      ad?.dispose();
    }
    _preloadedInterstitialAds.clear();
    super.dispose();
  }
}

final adServiceProvider = StateNotifierProvider<AdService, AdServiceState>((ref) {
  return AdService(ref);
});
