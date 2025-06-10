import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nestery_flutter/features/partner_dashboard/presentation/providers/offer_form_provider.dart';

class OfferEditScreen extends ConsumerWidget {
  final String? offerId;
  final _formKey = GlobalKey<FormState>();

  OfferEditScreen({super.key, this.offerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formProvider = offerFormStateNotifierProvider(offerId);
    final formState = ref.watch(formProvider);
    final formNotifier = ref.read(formProvider.notifier);
    final appBarTitle = formState.isEditing ? 'Edit Offer' : 'Create New Offer';

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)),
      body: !formState.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildBasicInfoCard(context, formNotifier, formState),
                    const SizedBox(height: 16),
                    _buildValidityCard(context, formNotifier, formState),
                    const SizedBox(height: 16),
                    _buildMediaCard(context),
                    const SizedBox(height: 24),
                    if (formState.submitError != null)
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Error: ${formState.submitError}',
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ElevatedButton(
                      onPressed: formState.isSubmitting
                          ? null
                          : () async {
                              await formNotifier.saveOffer();
                              final currentState = ref.read(formProvider);

                              if (currentState.submitError == null &&
                                  currentState.titleError == null &&
                                  currentState.commissionRateError == null &&
                                  currentState.dateError == null &&
                                  !currentState.isSubmitting) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(currentState.isEditing
                                          ? 'Offer updated successfully!'
                                          : 'Offer created successfully!'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  // Navigate back to offer list
                                  Navigator.of(context).pop();
                                }
                              } else if (currentState.submitError == null &&
                                        (currentState.titleError != null ||
                                         currentState.commissionRateError != null ||
                                         currentState.dateError != null)) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text('Please fix the errors before saving.'),
                                    ),
                                  );
                                }
                              }
                            },
                      child: formState.isSubmitting
                          ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Save Offer'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBasicInfoCard(BuildContext context, OfferFormStateNotifier notifier, dynamic state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Information', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.title,
              decoration: InputDecoration(
                labelText: 'Offer Title *',
                errorText: state.titleError,
                border: const OutlineInputBorder(),
              ),
              onChanged: notifier.updateTitle,
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.description,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: notifier.updateDescription,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: state.partnerCategory,
              decoration: const InputDecoration(
                labelText: 'Partner Category *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'TOUR_OPERATOR', child: Text('Tour Operator')),
                DropdownMenuItem(value: 'ACTIVITY_PROVIDER', child: Text('Activity Provider')),
                DropdownMenuItem(value: 'RESTAURANT', child: Text('Restaurant')),
                DropdownMenuItem(value: 'TRANSPORTATION', child: Text('Transportation')),
                DropdownMenuItem(value: 'ECOMMERCE', child: Text('E-commerce')),
              ],
              onChanged: (value) => notifier.updatePartnerCategory(value!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: state.commissionRate,
              decoration: InputDecoration(
                labelText: 'Commission Rate (%) *',
                errorText: state.commissionRateError,
                border: const OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
              onChanged: notifier.updateCommissionRate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidityCard(BuildContext context, OfferFormStateNotifier notifier, dynamic state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Validity Period', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (state.dateError != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(state.dateError!, style: TextStyle(color: Colors.red.shade700)),
              ),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: state.validFrom ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) notifier.updateValidFrom(date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Valid From *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        state.validFrom != null
                            ? DateFormat('dd MMM yyyy').format(state.validFrom!)
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: state.validTo ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: state.validFrom ?? DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) notifier.updateValidTo(date);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Valid To *',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        state.validTo != null
                            ? DateFormat('dd MMM yyyy').format(state.validTo!)
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Media', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Image upload placeholder', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
