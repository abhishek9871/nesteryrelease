// nestery-flutter/lib/features/partner_dashboard/presentation/models/chart_data_point.dart
class ChartDataPoint {
  final DateTime date; // Represents the X-axis point (e.g., a day)
  final double value;  // Represents the Y-axis point

  ChartDataPoint({required this.date, required this.value});
}
