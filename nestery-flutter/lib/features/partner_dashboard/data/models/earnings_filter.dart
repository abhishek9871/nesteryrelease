import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'earning_transaction_item.dart'; // For EarningStatus
part 'earnings_filter.freezed.dart';

@freezed
class EarningsFilter with _$EarningsFilter {
  const factory EarningsFilter({
    DateTimeRange? dateRange,
    EarningStatus? status, // Nullable to represent 'All'
  }) = _EarningsFilter;
}
