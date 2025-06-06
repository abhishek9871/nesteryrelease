import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';

class OfferCardWidget extends StatelessWidget {
  final OfferCardViewModel offer;

  const OfferCardWidget({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commissionText = offer.commissionRateMin == offer.commissionRateMax
        ? '${offer.commissionRateMin.toStringAsFixed(1)}%'
        : '${offer.commissionRateMin.toStringAsFixed(1)}% - ${offer.commissionRateMax.toStringAsFixed(1)}%';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CachedNetworkImage(
                imageUrl: offer.partnerLogoUrl ?? 'https://placehold.co/100x100/e0e0e0/000000.png?text=Logo',
                placeholder: (context, url) => const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.business),
                ),
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  backgroundImage: imageProvider,
                ),
              ),
              title: Text(offer.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(offer.partnerName, style: theme.textTheme.bodyMedium),
            ),
            const SizedBox(height: 8),
            Text(
              offer.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: [
                Chip(
                  avatar: Icon(offer.category.icon, size: 18),
                  label: Text(offer.category.displayName),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                Chip(
                  avatar: const Icon(Icons.percent, size: 18),
                  label: Text('Commission: $commissionText'),
                  backgroundColor: Colors.green.shade100,
                ),
                Chip(
                  avatar: const Icon(Icons.calendar_today, size: 18),
                  label: Text('Expires: ${DateFormat.yMMMd().format(offer.validTo)}'),
                  backgroundColor: Colors.orange.shade100,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
