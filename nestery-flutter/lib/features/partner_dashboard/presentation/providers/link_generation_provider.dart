import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/generated_link_dto.dart';
import 'package:nestery_flutter/providers/repository_providers.dart';

final linkGenerationStateProvider = StateNotifierProvider.family.autoDispose<
    LinkGenerationNotifier, AsyncValue<GeneratedAffiliateLinkResponseDto?>, String>(
  (ref, offerId) {
    return LinkGenerationNotifier(ref, offerId);
  },
);

class LinkGenerationNotifier extends StateNotifier<AsyncValue<GeneratedAffiliateLinkResponseDto?>> {
  final Ref _ref;
  final String _offerId;

  LinkGenerationNotifier(this._ref, this._offerId) : super(const AsyncValue.data(null));

  Future<void> generateLink() async {
    state = const AsyncValue.loading();
    final repository = _ref.read(partnerDashboardRepositoryProvider);
    final result = await repository.generateTrackableLink(_offerId);

    result.fold(
      (failure) => state = AsyncValue.error(failure, StackTrace.current),
      (linkData) => state = AsyncValue.data(linkData),
    );
  }
}
