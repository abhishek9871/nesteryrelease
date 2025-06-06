import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/models/partner_offer_list_item.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/providers/offer_filter_provider.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/providers/offer_management_provider.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/utils/dashboard_helpers.dart';
import 'package:nestery_flutter/utils/constants.dart';

class OfferListScreen extends ConsumerWidget {
  const OfferListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerListAsync = ref.watch(partnerOfferListProvider);
    final selectedFilter = ref.watch(offerFilterStatusProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Offers')),
      body: Column(
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButtonFormField<OfferFilterStatus>(
              value: selectedFilter,
              decoration: InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Constants.mediumRadius),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              ),
              items: OfferFilterStatus.values.map((OfferFilterStatus status) {
                return DropdownMenuItem<OfferFilterStatus>(
                  value: status,
                  child: Text(status.name[0].toUpperCase() + status.name.substring(1)),
                );
              }).toList(),
              onChanged: (OfferFilterStatus? newValue) {
                if (newValue != null) {
                  ref.read(offerFilterStatusProvider.notifier).state = newValue;
                }
              },
            ),
          ),
          // Offer List
          Expanded(
            child: offerListAsync.when(
              data: (offers) {
                if (offers.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.builder(
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final item = offers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: item.thumbnailUrl != null ? NetworkImage(item.thumbnailUrl!) : null,
                          child: item.thumbnailUrl == null ? const Icon(Icons.local_offer) : null,
                        ),
                        title: Text(
                          item.title,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Status: ${offerStatusToString(item.status)}",
                              style: TextStyle(color: getStatusColor(item.status, context)),
                            ),
                            Text("Category: ${item.partnerCategory}"),
                            Text("Valid: ${DateFormat('dd MMM yyyy').format(item.validFrom)} - ${DateFormat('dd MMM yyyy').format(item.validTo)}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.link),
                              tooltip: 'Generate Link',
                              onPressed: item.status == OfferStatus.active
                                  ? () {
                                      context.go('/partner-dashboard/offers/${item.id}/generate-link');
                                    }
                                  : null,
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () {
                          context.go('${Constants.partnerDashboardOffersRoute}/${item.id}/edit');
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => _buildLoadingState(),
              error: (error, stackTrace) => Center(
                child: Text('Error loading offers: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      itemCount: 4, // Number of shimmer items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.grey[300], radius: 24),
              title: Container(width: 150, height: 16, color: Colors.white),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Container(width: 100, height: 14, color: Colors.white),
                  const SizedBox(height: 4),
                  Container(width: 180, height: 14, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_offer_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No offers found.',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or create a new offer.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create New Offer'),
              onPressed: () {
                const createOfferRoute = '${Constants.partnerDashboardOffersRoute}/new';
                context.go(createOfferRoute);
              },
            ),
          ],
        ),
      ),
    );
  }
}
