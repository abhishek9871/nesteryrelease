import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfferEditScreen extends ConsumerWidget {
  final String? offerId; // Null for new offer, non-null for editing

  const OfferEditScreen({super.key, this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(offerId == null ? 'Create Offer' : 'Edit Offer')),
      body: const Center(
        child: Text('Offer Edit/Create Screen - Content goes here'),
      ),
    );
  }
}
