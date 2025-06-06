import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/data/models/partner_category.dart';
import 'package:nestery_flutter/features/affiliate_offers_browser/presentation/providers/offer_filter_provider.dart';

class OfferFilterWidgets extends ConsumerWidget {
  const OfferFilterWidgets({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterNotifier = ref.read(offerFilterProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search Offers',
              hintText: 'Search by title, partner, or description...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (query) => filterNotifier.updateSearchQuery(query),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<PartnerCategoryEnum?>(
            value: ref.watch(offerFilterProvider).selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<PartnerCategoryEnum?>(
                value: null,
                child: Text('All Categories'),
              ),
              ...PartnerCategoryEnum.values.map((category) {
                return DropdownMenuItem<PartnerCategoryEnum?>(
                  value: category,
                  child: Row(
                    children: [
                      Icon(category.icon, size: 20),
                      const SizedBox(width: 8),
                      Text(category.displayName),
                    ],
                  ),
                );
              }),
            ],
            onChanged: (category) => filterNotifier.updateCategory(category),
          ),
        ],
      ),
    );
  }
}
