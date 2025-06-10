import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer_form_state.freezed.dart';

@freezed
class OfferFormState with _$OfferFormState {
  const factory OfferFormState({
    @Default('') String id,
    @Default('') String title,
    @Default('') String description,
    @Default('TOUR_OPERATOR') String partnerCategory,
    @Default('15.0') String commissionRate,
    DateTime? validFrom,
    DateTime? validTo,
    String? imageUrl,
    @Default(false) bool isEditing,
    @Default(false) bool isInitialized,
    @Default(false) bool isSubmitting,
    String? titleError,
    String? commissionRateError,
    String? dateError,
    String? submitError,
  }) = _OfferFormState;
}
