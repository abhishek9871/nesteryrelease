import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/earnings_history_model.dart';
import '../providers/payout_provider.dart';

class PayoutStatusWidget extends ConsumerWidget {
  final PayoutRequestModel payout;

  const PayoutStatusWidget({
    super.key,
    required this.payout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with amount and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currencyFormat.format(payout.amount),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Requested ${dateFormat.format(payout.requestedAt)} at ${timeFormat.format(payout.requestedAt)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: payout.status),
              ],
            ),
            const SizedBox(height: 16),
            
            // Payment method
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPaymentMethodIcon(payout.paymentMethod),
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Method',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _getPaymentMethodLabel(payout.paymentMethod),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Payment details
            if (payout.paymentDetails != null) ...[
              const SizedBox(height: 12),
              _PaymentDetailsSection(
                paymentMethod: payout.paymentMethod,
                paymentDetails: payout.paymentDetails!,
              ),
            ],
            
            // Processing date (if processed)
            if (payout.processedAt != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[700],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Processed On',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${dateFormat.format(payout.processedAt!)} at ${timeFormat.format(payout.processedAt!)}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Notes (if any)
            if (payout.notes != null && payout.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      payout.notes!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Cancel button (if pending)
            if (payout.status.toLowerCase() == 'pending') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelDialog(context, ref),
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancel Request'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payout Request'),
        content: const Text(
          'Are you sure you want to cancel this payout request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Request'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(payoutCreationProvider.notifier).cancelPayout(payout.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }

  IconData _getPaymentMethodIcon(String? paymentMethod) {
    switch (paymentMethod?.toLowerCase()) {
      case 'bank_transfer':
        return Icons.account_balance;
      case 'paypal':
        return Icons.payment;
      case 'stripe':
        return Icons.credit_card;
      case 'crypto':
        return Icons.currency_bitcoin;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodLabel(String? paymentMethod) {
    switch (paymentMethod?.toLowerCase()) {
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'paypal':
        return 'PayPal';
      case 'stripe':
        return 'Stripe';
      case 'crypto':
        return 'Cryptocurrency';
      default:
        return paymentMethod ?? 'Unknown';
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'approved':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        icon = Icons.check_circle;
        break;
      case 'completed':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        icon = Icons.payment;
        break;
      case 'processing':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        icon = Icons.hourglass_empty;
        break;
      case 'pending':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        icon = Icons.schedule;
        break;
      case 'rejected':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        icon = Icons.cancel;
        break;
      case 'cancelled':
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = Icons.block;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentDetailsSection extends StatelessWidget {
  final String? paymentMethod;
  final Map<String, dynamic> paymentDetails;

  const _PaymentDetailsSection({
    required this.paymentMethod,
    required this.paymentDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Details',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          ..._buildPaymentDetailsWidgets(),
        ],
      ),
    );
  }

  List<Widget> _buildPaymentDetailsWidgets() {
    final widgets = <Widget>[];

    switch (paymentMethod?.toLowerCase()) {
      case 'bank_transfer':
        if (paymentDetails['accountNumber'] != null) {
          widgets.add(_DetailRow(
            label: 'Account Number',
            value: _maskAccountNumber(paymentDetails['accountNumber']),
          ));
        }
        if (paymentDetails['routingNumber'] != null) {
          widgets.add(_DetailRow(
            label: 'Routing Number',
            value: paymentDetails['routingNumber'],
          ));
        }
        if (paymentDetails['accountHolderName'] != null) {
          widgets.add(_DetailRow(
            label: 'Account Holder',
            value: paymentDetails['accountHolderName'],
          ));
        }
        break;
      case 'paypal':
        if (paymentDetails['email'] != null) {
          widgets.add(_DetailRow(
            label: 'PayPal Email',
            value: _maskEmail(paymentDetails['email']),
          ));
        }
        break;
      case 'stripe':
        if (paymentDetails['accountId'] != null) {
          widgets.add(_DetailRow(
            label: 'Stripe Account',
            value: _maskAccountId(paymentDetails['accountId']),
          ));
        }
        break;
      case 'crypto':
        if (paymentDetails['walletAddress'] != null) {
          widgets.add(_DetailRow(
            label: 'Wallet Address',
            value: _maskWalletAddress(paymentDetails['walletAddress']),
          ));
        }
        if (paymentDetails['currency'] != null) {
          widgets.add(_DetailRow(
            label: 'Currency',
            value: paymentDetails['currency'],
          ));
        }
        break;
      default:
        // Generic display for unknown payment methods
        paymentDetails.forEach((key, value) {
          widgets.add(_DetailRow(
            label: key,
            value: value.toString(),
          ));
        });
    }

    return widgets;
  }

  String _maskAccountNumber(String accountNumber) {
    if (accountNumber.length <= 4) return accountNumber;
    return '****${accountNumber.substring(accountNumber.length - 4)}';
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 2) return email;
    return '${username.substring(0, 2)}***@$domain';
  }

  String _maskAccountId(String accountId) {
    if (accountId.length <= 8) return accountId;
    return '${accountId.substring(0, 4)}****${accountId.substring(accountId.length - 4)}';
  }

  String _maskWalletAddress(String address) {
    if (address.length <= 8) return address;
    return '${address.substring(0, 6)}...${address.substring(address.length - 6)}';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
