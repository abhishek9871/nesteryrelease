import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfferEditScreen extends ConsumerWidget {
  final String? offerId; // Null for new offer, non-null for editing

  const OfferEditScreen({super.key, this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isNewOffer = offerId == null || offerId == 'new';
    final String appBarTitle = isNewOffer ? 'Create New Offer' : 'Offer Details - ID: $offerId';

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isNewOffer ? 'Create a New Offer' : 'Displaying details for Offer ID: $offerId',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                isNewOffer
                    ? 'Offer creation form will be implemented in a future LFS.'
                    : 'Full offer details and editing functionality will be implemented in a future LFS.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (!isNewOffer)
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edit action placeholder for Offer ID: $offerId')),
                    );
                  },
                  child: const Text('Edit Offer (Placeholder Action)'),
                )
              else // This is for the 'new' offer case
                ElevatedButton(
                  onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Save new offer action placeholder.')),
                    );
                  },
                  child: const Text('Save New Offer (Placeholder)'),
                )
            ],
          ),
        ),
      ),
    );
  }
}
