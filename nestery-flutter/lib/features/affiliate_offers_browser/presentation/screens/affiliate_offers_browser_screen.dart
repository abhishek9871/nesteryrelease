import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/affiliate_offers_provider.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/affiliate_offers_state.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/widgets/offer_card_widget.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/widgets/offer_filter_widgets.dart';
import 'package:shimmer/shimmer.dart';

class AffiliateOffersBrowserScreen extends ConsumerWidget {
  const AffiliateOffersBrowserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersState = ref.watch(affiliateOffersProvider);
    final filteredOffers = ref.watch(filteredOffersProvider);

    // Initialize offers loading on first build
    if (offersState == const AffiliateOffersState.loading()) {
      Future.microtask(() {
        ref.read(affiliateOffersProvider.notifier).loadOffers();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Offers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(affiliateOffersProvider.notifier).refreshOffers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const OfferFilterWidgets(),
          Expanded(
            child: offersState.when(
              loading: () => _buildLoadingShimmer(),
              error: (message, cachedOffers) => _buildErrorWidget(context, ref, message),
              success: (offers, currentPage, hasMore, totalCount) {
                if (filteredOffers.isEmpty) {
                  return _buildEmptyState(context, ref);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(affiliateOffersProvider.notifier).refreshOffers();
                  },
                  child: ListView.builder(
                    itemCount: filteredOffers.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == filteredOffers.length) {
                        // Load more indicator
                        ref.read(affiliateOffersProvider.notifier).loadMoreOffers();
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final offer = filteredOffers[index];
                      return OfferCardWidget(offer: offer);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(radius: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: double.infinity, height: 16, color: Colors.white),
                            const SizedBox(height: 8),
                            Container(width: 100, height: 14, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(width: double.infinity, height: 14, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: double.infinity, height: 14, color: Colors.white),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(width: 80, height: 30, color: Colors.white, margin: const EdgeInsets.only(right: 8)),
                      Container(width: 120, height: 30, color: Colors.white),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text(
              'Failed to load offers',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(affiliateOffersProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Offers Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => ref.read(offerFilterProvider.notifier).clearFilters(),
              child: const Text('Clear Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
