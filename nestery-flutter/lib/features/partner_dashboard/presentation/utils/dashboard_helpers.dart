import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Calculates the trend percentage and returns a formatted string.
/// Example: "+5.0% MoM"
String calculateTrend(double currentValue, double previousValue, String periodLabel) {
  if (previousValue == 0 && currentValue > 0) return "New";
  if (previousValue == 0 && currentValue == 0) return "N/A";
  // If previousValue is 0 and currentValue is also 0, it's handled above.
  // If previousValue is 0 and currentValue is non-zero, it's "New".
  // So, if we reach here and previousValue is 0, it implies an issue or unhandled case.
  // However, to prevent division by zero if currentValue is also zero, we check again.
  if (previousValue == 0) return "N/A"; // Should ideally not happen if current is also 0 or handled above

  double change = ((currentValue - previousValue) / previousValue.abs()) * 100;
  String sign = change >= 0 ? "+" : "";

  if (change.isInfinite || change.isNaN) return "N/A";

  return "$sign${change.toStringAsFixed(1)}% $periodLabel";
}

/// Data class for traffic quality information (label and color).
class TrafficQualityInfo {
  final String label;
  final Color color;
  TrafficQualityInfo(this.label, this.color);
}

/// Determines the traffic quality label and color based on conversion rate.
TrafficQualityInfo getTrafficQualityInfo(double conversionRateValue) {
  if (conversionRateValue >= 0.10) { // ≥10%
    return TrafficQualityInfo("Excellent", Colors.green[600]!);
  } else if (conversionRateValue >= 0.05) { // 5% - 9.9%
    return TrafficQualityInfo("Good", Colors.blue[600]!);
  } else if (conversionRateValue >= 0.02) { // 2% - 4.9%
    return TrafficQualityInfo("Fair", Colors.orange[600]!);
  } else { // <2%
    return TrafficQualityInfo("Poor", Colors.red[600]!);
  }
}

/// Formats a double value as currency.
/// Example: 1234.56 -> "$1,234.56"
String formatCurrency(double value, {String symbol = '\$', int decimalDigits = 2}) {
  final format = NumberFormat.currency(
    locale: 'en_US', // Ensures consistent formatting
    symbol: symbol,
    decimalDigits: decimalDigits,
  );
  return format.format(value);
}

/// Formats a double value (e.g., 0.125) as a percentage string.
/// Example: 0.125 -> "12.5%"
String formatPercentage(double value, {int decimalDigits = 1}) {
  final format = NumberFormat.decimalPercentPattern(
    locale: 'en_US', // Ensures consistent formatting
    decimalDigits: decimalDigits,
  );
  return format.format(value);
}