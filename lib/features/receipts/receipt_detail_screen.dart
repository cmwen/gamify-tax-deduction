import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/database/database_helper.dart';
import '../../core/models/data_models.dart';
import '../../core/services/profile_service.dart';
import '../../core/services/tax_calculation_service.dart';
import 'receipt_categories.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final String receiptId;

  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptEditResult {
  final double amount;
  final String? vendorName;
  final String? category;

  _ReceiptEditResult({
    required this.amount,
    this.vendorName,
    this.category,
  });
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final ProfileService _profileService = ProfileService();

  Receipt? _receipt;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReceipt();
  }

  Future<void> _loadReceipt() async {
    final receipt = await _databaseHelper.getReceiptById(widget.receiptId);
    if (mounted) {
      setState(() {
        _receipt = receipt;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete receipt'),
        content: const Text(
            'This will remove the receipt and its savings from your tracker.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    await _databaseHelper.deleteReceipt(widget.receiptId);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleEdit() async {
    final receipt = _receipt;
    if (receipt == null) {
      return;
    }

    final amountController =
        TextEditingController(text: receipt.totalAmount.toStringAsFixed(2));
    final vendorController =
        TextEditingController(text: receipt.vendorName ?? '');
    String? selectedCategory = receipt.category;
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<_ReceiptEditResult?>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 4,
                      width: 48,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const Text(
                      'Edit receipt',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final trimmed = value?.trim() ?? '';
                        final amount = double.tryParse(trimmed);
                        if (amount == null || amount <= 0) {
                          return 'Enter an amount greater than zero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: vendorController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Vendor (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String?>(
                      // ignore: deprecated_member_use
                      value: selectedCategory,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Uncategorized'),
                        ),
                        ...receiptCategories.map(
                          (category) => DropdownMenuItem<String?>(
                            value: category,
                            child: Text(formatCategoryLabel(category)),
                          ),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }
                              final amount =
                                  double.parse(amountController.text.trim());
                              Navigator.pop(
                                context,
                                _ReceiptEditResult(
                                  amount: amount,
                                  vendorName:
                                      vendorController.text.trim().isEmpty
                                          ? null
                                          : vendorController.text.trim(),
                                  category: selectedCategory,
                                ),
                              );
                            },
                            child: const Text('Save changes'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    amountController.dispose();
    vendorController.dispose();

    if (result == null) {
      return;
    }

    final profile = await _profileService.getProfile();
    final double updatedSaving;
    if (profile != null) {
      updatedSaving = TaxCalculationService.calculateSavingWithProfile(
        result.amount,
        profile.incomeBracket,
        profile.filingStatus,
        profile.taxCountry,
      );
    } else {
      updatedSaving =
          TaxCalculationService.calculatePotentialSaving(result.amount);
    }

    final updatedReceipt = receipt.copyWith(
      totalAmount: result.amount,
      vendorName: result.vendorName,
      category: result.category,
      potentialTaxSaving: updatedSaving,
    );

    await _databaseHelper.updateReceipt(updatedReceipt);
    if (mounted) {
      setState(() {
        _receipt = updatedReceipt;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receipt updated.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final receipt = _receipt;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: _handleEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : receipt == null
              ? const Center(child: Text('Receipt not found.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (receipt.imagePath.isNotEmpty &&
                          File(receipt.imagePath).existsSync())
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(receipt.imagePath),
                            height: 240,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Summary',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                  'Amount: \$${receipt.totalAmount.toStringAsFixed(2)}'),
                              const SizedBox(height: 6),
                              Text(
                                'Estimated savings: \$${receipt.potentialTaxSaving.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Created: ${MaterialLocalizations.of(context).formatMediumDate(receipt.createdAt)}',
                              ),
                              if (receipt.vendorName != null &&
                                  receipt.vendorName!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text('Vendor: ${receipt.vendorName}'),
                              ],
                              if (receipt.category != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                    'Category: ${formatCategoryLabel(receipt.category!)}'),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Use edit to adjust detected values or reclassify the expense. All updates recalculate the potential deduction based on your profile.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
    );
  }
}
