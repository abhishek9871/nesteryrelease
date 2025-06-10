import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/earnings_history_model.dart';
import '../providers/payout_provider.dart';
import '../widgets/payout_status_widget.dart';

class PayoutRequestScreen extends ConsumerStatefulWidget {
  const PayoutRequestScreen({super.key});

  @override
  ConsumerState<PayoutRequestScreen> createState() => _PayoutRequestScreenState();
}

class _PayoutRequestScreenState extends ConsumerState<PayoutRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payouts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Request Payout'),
            Tab(text: 'Payout History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _PayoutRequestTab(),
          _PayoutHistoryTab(),
        ],
      ),
    );
  }
}

class _PayoutRequestTab extends ConsumerWidget {
  const _PayoutRequestTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutInfoAsync = ref.watch(payoutInfoProvider);
    final canRequestAsync = ref.watch(canRequestPayoutProvider);
    final availableBalanceAsync = ref.watch(availableBalanceProvider);
    final minimumThresholdAsync = ref.watch(minimumPayoutThresholdProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(payoutInfoProvider);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Balance overview
            payoutInfoAsync.when(
              data: (info) => _BalanceOverview(
                availableBalance: info['availableBalance']?.toDouble() ?? 0.0,
                minimumThreshold: info['minimumThreshold']?.toDouble() ?? 50.0,
                pendingPayouts: info['pendingPayouts']?.toDouble() ?? 0.0,
              ),
              loading: () => _BalanceOverviewSkeleton(),
              error: (error, stack) => _ErrorCard(
                title: 'Failed to load balance',
                error: error.toString(),
                onRetry: () => ref.refresh(payoutInfoProvider),
              ),
            ),
            const SizedBox(height: 24),
            
            // Request payout form
            canRequestAsync.when(
              data: (canRequest) => canRequest
                  ? _PayoutRequestForm()
                  : _PayoutNotAvailable(),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => _ErrorCard(
                title: 'Failed to check payout eligibility',
                error: error.toString(),
                onRetry: () => ref.refresh(canRequestPayoutProvider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceOverview extends StatelessWidget {
  final double availableBalance;
  final double minimumThreshold;
  final double pendingPayouts;

  const _BalanceOverview({
    required this.availableBalance,
    required this.minimumThreshold,
    required this.pendingPayouts,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Balance Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BalanceItem(
                    title: 'Available',
                    amount: availableBalance,
                    color: Colors.green,
                    icon: Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _BalanceItem(
                    title: 'Pending',
                    amount: pendingPayouts,
                    color: Colors.orange,
                    icon: Icons.schedule,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Minimum payout threshold: ${currencyFormat.format(minimumThreshold)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;
  final IconData icon;

  const _BalanceItem({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormat.format(amount),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PayoutRequestForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PayoutRequestForm> createState() => _PayoutRequestFormState();
}

class _PayoutRequestFormState extends ConsumerState<_PayoutRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.bankTransfer;
  final Map<String, String> _paymentDetails = {};

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final payoutCreation = ref.watch(payoutCreationProvider);
    final availableBalanceAsync = ref.watch(availableBalanceProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Request Payout',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Amount field
              availableBalanceAsync.when(
                data: (availableBalance) => TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                    border: const OutlineInputBorder(),
                    helperText: 'Available: \$${availableBalance.toStringAsFixed(2)}',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    if (amount > availableBalance) {
                      return 'Amount exceeds available balance';
                    }
                    return null;
                  },
                ),
                loading: () => const CircularProgressIndicator(),
                error: (error, stack) => Text('Error: $error'),
              ),
              const SizedBox(height: 16),
              
              // Payment method
              Text(
                'Payment Method',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<PaymentMethod>(
                value: _selectedPaymentMethod,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: PaymentMethod.values.map((method) {
                  return DropdownMenuItem(
                    value: method,
                    child: Text(_getPaymentMethodLabel(method)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedPaymentMethod = value;
                      _paymentDetails.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Payment details
              _buildPaymentDetailsFields(),
              const SizedBox(height: 16),
              
              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Error message
              if (payoutCreation.error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    payoutCreation.error!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: payoutCreation.isLoading ? null : _submitRequest,
                  child: payoutCreation.isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Request Payout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsFields() {
    switch (_selectedPaymentMethod) {
      case PaymentMethod.bankTransfer:
        return Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Account Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
              onChanged: (value) => _paymentDetails['accountNumber'] = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Routing Number',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
              onChanged: (value) => _paymentDetails['routingNumber'] = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Account Holder Name',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
              onChanged: (value) => _paymentDetails['accountHolderName'] = value,
            ),
          ],
        );
      case PaymentMethod.paypal:
        return TextFormField(
          decoration: const InputDecoration(
            labelText: 'PayPal Email',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty == true ? 'Required' : null,
          onChanged: (value) => _paymentDetails['email'] = value,
        );
      case PaymentMethod.stripe:
        return TextFormField(
          decoration: const InputDecoration(
            labelText: 'Stripe Account ID',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value?.isEmpty == true ? 'Required' : null,
          onChanged: (value) => _paymentDetails['accountId'] = value,
        );
      case PaymentMethod.crypto:
        return Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Wallet Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
              onChanged: (value) => _paymentDetails['walletAddress'] = value,
            ),
            const SizedBox(height: 12),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Currency (e.g., BTC, ETH)',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
              onChanged: (value) => _paymentDetails['currency'] = value,
            ),
          ],
        );
    }
  }

  String _getPaymentMethodLabel(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.stripe:
        return 'Stripe';
      case PaymentMethod.crypto:
        return 'Cryptocurrency';
    }
  }

  void _submitRequest() {
    if (_formKey.currentState?.validate() == true) {
      final amount = double.parse(_amountController.text);
      final request = CreatePayoutRequestModel(
        amount: amount,
        paymentMethod: _selectedPaymentMethod.name,
        paymentDetails: _paymentDetails,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      ref.read(payoutCreationProvider.notifier).createPayout(request);
    }
  }
}

class _PayoutNotAvailable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.block,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Payout Not Available',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have enough balance to request a payout. Keep earning commissions to reach the minimum threshold.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PayoutHistoryTab extends ConsumerWidget {
  const _PayoutHistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payoutsAsync = ref.watch(payoutRequestsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.refresh(payoutRequestsProvider);
      },
      child: payoutsAsync.when(
        data: (payouts) => payouts.isEmpty
            ? _EmptyPayoutHistory()
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: payouts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: PayoutStatusWidget(payout: payouts[index]),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorCard(
          title: 'Failed to load payout history',
          error: error.toString(),
          onRetry: () => ref.refresh(payoutRequestsProvider),
        ),
      ),
    );
  }
}

class _EmptyPayoutHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No payout requests yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your payout requests will appear here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceOverviewSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(height: 20, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container(height: 80, color: Colors.grey[300])),
                const SizedBox(width: 16),
                Expanded(child: Container(height: 80, color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 40, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String title;
  final String error;
  final VoidCallback onRetry;

  const _ErrorCard({
    required this.title,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
