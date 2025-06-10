import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class LinkGenerationBottomSheet extends StatelessWidget {
  final String trackableUrl;
  final String? qrCodeDataUrl;
  final String uniqueCode;

  const LinkGenerationBottomSheet({
    super.key,
    required this.trackableUrl,
    this.qrCodeDataUrl,
    required this.uniqueCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Trackable Link', style: theme.textTheme.headlineSmall),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: QrImageView(
              data: qrCodeDataUrl ?? trackableUrl,
              version: QrVersions.auto,
              size: 200.0,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
              semanticsLabel: 'QR Code for sharing the offer link',
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(child: Text(trackableUrl, style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'), overflow: TextOverflow.ellipsis,)),
                IconButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: trackableUrl));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copied to clipboard!')),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy)
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              textStyle: theme.textTheme.titleMedium,
            ),
            onPressed: () async {
              final box = context.findRenderObject() as RenderBox?;
              try {
                await Share.share(
                  trackableUrl,
                  sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
                );
              } catch (e) {
                if (context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open share options.')),
                  );
                }
              }
            },
            icon: const Icon(Icons.share),
            label: const Text('Share Link'),
          ),
        ],
      ),
    );
  }
}
