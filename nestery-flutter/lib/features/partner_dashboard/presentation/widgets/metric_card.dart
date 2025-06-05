import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MetricCard extends StatelessWidget {
  final String? title;
  final String? valueText;
  final String? subtitleText;
  final String? trendText;
  final IconData? iconData;
  final Color? iconColor;
  final bool isLoading;

  const MetricCard({
    super.key,
    this.title,
    this.valueText,
    this.subtitleText,
    this.trendText,
    this.iconData,
    this.iconColor,
    this.isLoading = false,
  }) : assert(isLoading || (title != null && valueText != null && iconData != null && iconColor != null && trendText != null),
              'All properties (except subtitleText) must be provided if not loading.');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 24, height: 24, color: Colors.white), // Icon placeholder
                    const SizedBox(width: 8),
                    Container(width: 100, height: 16, color: Colors.white), // Title placeholder
                  ],
                ),
                const SizedBox(height: 12),
                Container(width: 120, height: 28, color: Colors.white), // Value placeholder
                const SizedBox(height: 8),
                Container(width: 150, height: 14, color: Colors.white), // Subtitle placeholder
                const Spacer(),
                Container(width: 80, height: 14, color: Colors.white), // Trend placeholder
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title!,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              valueText!,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: iconColor, // Use iconColor for value emphasis
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (subtitleText != null && subtitleText!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                subtitleText!,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Spacer(), // Pushes trend to the bottom
            Text(
              trendText!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: trendText!.startsWith('+') || trendText!.toLowerCase() == 'new'
                    ? Colors.green[700]
                    : (trendText!.startsWith('-') ? Colors.red[700] : theme.colorScheme.onSurfaceVariant),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
