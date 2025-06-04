import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EarningsReportScreen extends ConsumerWidget {
  const EarningsReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings Reports')),
      body: const Center(
        child: Text('Earnings Report Screen - Content goes here'),
      ),
    );
  }
}
