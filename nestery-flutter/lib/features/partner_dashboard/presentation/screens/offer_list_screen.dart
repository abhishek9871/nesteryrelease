import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfferListScreen extends ConsumerWidget {
  const OfferListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Offers')),
      body: const Center(
        child: Text('Offer List Screen - Content goes here'),
      ),
    );
  }
}
