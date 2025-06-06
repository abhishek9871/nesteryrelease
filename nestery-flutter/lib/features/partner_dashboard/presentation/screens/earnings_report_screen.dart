import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/earning_transaction_item.dart';
import 'package:nestery_flutter/features/partner_dashboard/data/models/earnings_report_data.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/providers/earnings_report_provider.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/utils/dashboard_helpers.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/widgets/metric_card.dart';

class EarningsReportScreen extends ConsumerWidget {
  const EarningsReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportAsyncValue = ref.watch(earningsReportProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Earnings Report')),
      body: reportAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (reportData) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SummaryMetrics(reportData: reportData),
                const SizedBox(height: 24),
                _FilterControls(),
                const SizedBox(height: 24),
                _TransactionsTable(transactions: reportData.transactions),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryMetrics extends StatelessWidget {
  final EarningsReportData reportData;
  const _SummaryMetrics({required this.reportData});

  @override
  Widget build(BuildContext context) {
    final summary = reportData.summary;
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    if (screenWidth > 1200) {
      crossAxisCount = 4;
    } else if (screenWidth > 800) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 1;
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      childAspectRatio: crossAxisCount == 1 ? 3 : 1.8,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: [
        MetricCard(
          title: "Total Earnings",
          valueText: formatCurrency(summary.totalEarnings),
          iconData: Icons.monetization_on,
          iconColor: Colors.green,
          trendText: "All time",
        ),
        MetricCard(
          title: "Pending Payout",
          valueText: formatCurrency(summary.pendingPayout),
          iconData: Icons.hourglass_top,
          iconColor: Colors.orange,
          trendText: "Awaiting clearance",
        ),
        MetricCard(
          title: "This Month's Earnings",
          valueText: formatCurrency(summary.thisMonthEarnings),
          iconData: Icons.calendar_today,
          iconColor: Colors.blue,
          trendText: "Current cycle",
        ),
        MetricCard(
          title: "Last Payout",
          valueText: formatCurrency(summary.lastPayoutAmount),
          subtitleText: summary.lastPayoutDate != null
              ? "on ${DateFormat.yMMMd().format(summary.lastPayoutDate!)}"
              : "No recent payouts",
          iconData: Icons.payment,
          iconColor: Colors.purple,
          trendText: "Previous cycle",
        ),
      ],
    );
  }
}

class _FilterControls extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(earningsFilterProvider);
    final filterNotifier = ref.read(earningsFilterProvider.notifier);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 16.0,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.date_range),
              label: Text(filter.dateRange != null
                  ? '${DateFormat.yMd().format(filter.dateRange!.start)} - ${DateFormat.yMd().format(filter.dateRange!.end)}'
                  : 'Select Date Range'),
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2022),
                  lastDate: DateTime.now(),
                  currentDate: DateTime.now(),
                );
                if (range != null) {
                  filterNotifier.updateDateRange(range);
                }
              },
            ),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<EarningStatus?>(
                value: filter.status,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Statuses')),
                  ...EarningStatus.values.map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      )),
                ],
                onChanged: (status) => filterNotifier.updateStatus(status),
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
              onPressed: filterNotifier.clearFilters,
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionsTable extends StatelessWidget {
  final List<EarningTransactionItem> transactions;
  const _TransactionsTable({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return PaginatedDataTable(
      header: const Text('Transaction History'),
      columns: const [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Offer')),
        DataColumn(label: Text('Amount')),
        DataColumn(label: Text('Status')),
      ],
      source: _EarningsDataTableSource(transactions),
      rowsPerPage: 10,
      showCheckboxColumn: false,
    );
  }
}

class _EarningsDataTableSource extends DataTableSource {
  final List<EarningTransactionItem> _data;

  _EarningsDataTableSource(this._data);

  @override
  DataRow? getRow(int index) {
    if (index >= _data.length) return null;
    final transaction = _data[index];

    Color statusColor;
    switch (transaction.status) {
      case EarningStatus.PAID:
        statusColor = Colors.green.shade100;
        break;
      case EarningStatus.CONFIRMED:
        statusColor = Colors.blue.shade100;
        break;
      case EarningStatus.PENDING:
        statusColor = Colors.orange.shade100;
        break;
      case EarningStatus.CANCELLED:
        statusColor = Colors.red.shade100;
        break;
    }

    return DataRow(
      cells: [
        DataCell(Text(DateFormat.yMd().format(transaction.transactionDate))),
        DataCell(Text(transaction.offerTitle)),
        DataCell(Text(NumberFormat.currency(symbol: '\$').format(transaction.amountEarned))),
        DataCell(
          Chip(
            label: Text(
              transaction.status.name,
              style: const TextStyle(fontSize: 12),
            ),
            backgroundColor: statusColor,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}
