import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LinkGenerationScreen extends ConsumerWidget {
  const LinkGenerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Generation')),
      body: const Center(
        child: Text('Link Generation Screen - Content goes here'),
      ),
    );
  }
}
