import 'chart_data_point.dart';

class DashboardChartData {
  final List<ChartDataPoint> netEarningsData;
  final List<ChartDataPoint> conversionRateData;

  DashboardChartData({
    required this.netEarningsData,
    required this.conversionRateData,
  });
}
