import 'package:freezed_annotation/freezed_annotation.dart';
part 'earning_transaction_item.freezed.dart';

enum EarningStatus { PENDING, CONFIRMED, PAID, CANCELLED }

@freezed
class EarningTransactionItem with _$EarningTransactionItem {
  const factory EarningTransactionItem({
    required String id,
    required DateTime transactionDate,
    required String offerTitle,
    required String offerId,
    required double amountEarned,
    required String currency,
    required EarningStatus status,
  }) = _EarningTransactionItem;
}
