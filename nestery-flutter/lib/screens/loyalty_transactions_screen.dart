import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nestery_flutter/models/loyalty.dart';
import 'package:nestery_flutter/providers/loyalty_provider.dart';
import 'package:nestery_flutter/widgets/loading_overlay.dart';

class LoyaltyTransactionsScreen extends ConsumerStatefulWidget {
  const LoyaltyTransactionsScreen({super.key});

  @override
  ConsumerState<LoyaltyTransactionsScreen> createState() => _LoyaltyTransactionsScreenState();
}

class _LoyaltyTransactionsScreenState extends ConsumerState<LoyaltyTransactionsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch initial transactions
    Future.microtask(() => ref.read(loyaltyTransactionsProvider.notifier).fetchInitialTransactions());

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        ref.read(loyaltyTransactionsProvider.notifier).fetchMoreTransactions();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loyaltyTransactionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Miles Transaction History'),
        centerTitle: true,
      ),
      body: LoadingOverlay(
        isLoading: state.isLoading && state.transactions.isEmpty, // Show overlay only on initial load
        child: _buildContent(state, theme),
      ),
    );
  }

  Widget _buildContent(LoyaltyTransactionsState state, ThemeData theme) {
    if (state.transactions.isEmpty) {
      if (state.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (state.error != null) {
        return Center(child: Text('Error: ${state.error}'));
      }
      return const Center(child: Text('No transactions yet.'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(loyaltyTransactionsProvider.notifier).fetchInitialTransactions(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.transactions.length) {
            return state.isLoading
                ? const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ))
                : const SizedBox.shrink();
          }

          final transaction = state.transactions[index];
          final isCredit = transaction.milesAmount >= 0;
          final amountColor = isCredit ? Colors.green : Colors.red;
          final amountPrefix = isCredit ? '+' : '';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 1,
            child: ListTile(
              leading: Icon(
                isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                color: amountColor,
              ),
              title: Text(
                transaction.description ?? transaction.transactionType.displayDescription,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(transaction.createdAt.toLocal()),
                style: theme.textTheme.bodySmall,
              ),
              trailing: Text(
                '$amountPrefix${transaction.milesAmount} Miles',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
