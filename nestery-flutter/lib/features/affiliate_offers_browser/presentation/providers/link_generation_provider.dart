import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/repositories/affiliate_offers_repository_impl.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/repositories/affiliate_offers_repository.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/affiliate_offers_state.dart';

class LinkGenerationNotifier extends StateNotifier<LinkGenerationState> {
  final AffiliateOffersRepository _repository;

  LinkGenerationNotifier(this._repository)
      : super(const LinkGenerationState.idle());

  Future<void> generateLink(String offerId) async {
    state = const LinkGenerationState.loading();

    try {
      // Get current user ID from auth repository if available
      // final accessToken = await _authRepository.getAccessToken();
      String? userId;

      // Note: In a real app, you'd decode the JWT to get user ID
      // For now, we'll pass null and let the backend handle it

      final result = await _repository.generateTrackableLink(
        offerId: offerId,
        userId: userId,
      );

      result.fold(
        (error) => state = LinkGenerationState.error(message: error.message),
        (linkData) => state = LinkGenerationState.success(
          trackableUrl: linkData.fullTrackableUrl,
          qrCodeDataUrl: linkData.qrCodeDataUrl,
          uniqueCode: linkData.linkEntity.uniqueCode,
        ),
      );
    } catch (e) {
      state = LinkGenerationState.error(message: e.toString());
    }
  }

  void reset() {
    state = const LinkGenerationState.idle();
  }
}

final linkGenerationProvider = StateNotifierProvider<LinkGenerationNotifier, LinkGenerationState>((ref) {
  final repository = ref.watch(affiliateOffersRepositoryProvider);
  return LinkGenerationNotifier(repository);
});

final selectedOfferProvider = StateProvider<OfferCardViewModel?>((ref) => null);
