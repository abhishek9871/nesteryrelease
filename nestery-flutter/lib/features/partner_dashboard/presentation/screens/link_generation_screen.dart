import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/models/partner_offer_list_item.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/providers/link_generation_provider.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/providers/offer_management_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class LinkGenerationScreen extends ConsumerWidget {
  final String offerId;
  const LinkGenerationScreen({super.key, required this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offerAsync = ref.watch(partnerOfferListProvider);
    final linkState = ref.watch(linkGenerationStateProvider(offerId));
    final linkNotifier = ref.read(linkGenerationStateProvider(offerId).notifier);

    final PartnerOfferListItem? offer = offerAsync.when(
      data: (offers) {
        try {
          return offers.firstWhere((o) => o.id == offerId);
        } catch (e) {
          return null;
        }
      },
      loading: () => null,
      error: (e, s) => null,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Generate Link')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Generating Link For:', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    offerAsync.when(
                      data: (offers) {
                        if (offer == null) {
                          return const Text('Offer not found.', style: TextStyle(color: Colors.red));
                        }
                        return Text(offer.title, style: Theme.of(context).textTheme.headlineSmall);
                      },
                      loading: () => const Text('Loading offer details...'),
                      error: (e, s) => Text('Error loading offer: $e', style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: linkState.isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.generating_tokens_outlined),
              label: Text(linkState.isLoading ? 'Generating...' : 'Generate Link & QR Code'),
              onPressed: linkState.isLoading ? null : () => linkNotifier.generateLink(),
            ),
            const SizedBox(height: 24),
            linkState.when(
              data: (data) {
                if (data == null) {
                  return const Center(child: Text('Click the button to generate your link.'));
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: TextEditingController(text: data.fullTrackableUrl),
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Your Trackable URL',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy URL',
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: data.fullTrackableUrl));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('URL copied to clipboard!')));
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: QrImageView(
                        data: data.qrCodeData,
                        version: QrVersions.auto,
                        size: 200.0,
                        errorCorrectionLevel: QrErrorCorrectLevel.M,
                        semanticsLabel: 'QR Code for ${offer?.title ?? 'offer'}',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Scan this QR code to use the link.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(), // Button handles loading state
              error: (error, stackTrace) => Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Text('Failed to generate link: $error', style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
