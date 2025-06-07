import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/domain/entities/offer_card_view_model.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/affiliate_offers_provider.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/link_generation_provider.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/widgets/link_generation_bottom_sheet.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/widgets/offer_card_widget.dart';

class OfferDetailScreen extends ConsumerWidget {
  final String offerId;

  const OfferDetailScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(offerDetailProvider(offerId));
    
    ref.listen<AsyncValue<GeneratedLink?>>(linkGenerationProvider, (previous, next) {
      next.when(
        data: (generatedLink) {
          if (generatedLink != null) {
            showModalBottomSheet(
              context: context,
              builder: (_) => LinkGenerationBottomSheet(generatedLink: generatedLink),
            );
          }
        },
        error: (error, stack) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating link: $error')),
        ),
        loading: () {
          // Optionally show a loading indicator, but button will be disabled.
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Offer Details')),
      body: offerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (offer) => _buildOfferDetailContent(context, ref, offer),
      ),
    );
  }

  Widget _buildOfferDetailContent(BuildContext context, WidgetRef ref, OfferCardViewModel offer) {
    final linkState = ref.watch(linkGenerationProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          OfferCardWidget(offer: offer), // Re-use the card for the header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Full Description', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(offer.description), // Full description here
                const SizedBox(height: 16),
                Text('Terms & Conditions', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                const Text('Placeholder for terms and conditions...'),
                 const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: linkState.isLoading ? null : () {
                    ref.read(linkGenerationProvider.notifier).generateLink(offer.offerId);
                  },
                  icon: const Icon(Icons.qr_code_2),
                  label: Text(linkState.isLoading ? 'Generating...' : 'Generate Link'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
