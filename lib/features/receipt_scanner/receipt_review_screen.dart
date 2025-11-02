import 'dart:io';

import 'package:flutter/material.dart';

import '../receipts/receipt_categories.dart';

class ReceiptReviewResult {
  final double amount;
  final String? vendorName;
  final String? category;

  const ReceiptReviewResult({
    required this.amount,
    this.vendorName,
    this.category,
  });
}

class ReceiptReviewScreen extends StatefulWidget {
  final double initialAmount;
  final String? initialVendorName;
  final String imagePath;

  const ReceiptReviewScreen({
    super.key,
    required this.initialAmount,
    required this.imagePath,
    this.initialVendorName,
  });

  @override
  State<ReceiptReviewScreen> createState() => _ReceiptReviewScreenState();
}

class _ReceiptReviewScreenState extends State<ReceiptReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _vendorController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount > 0
          ? widget.initialAmount.toStringAsFixed(2)
          : '',
    );
    _vendorController = TextEditingController(
      text: widget.initialVendorName ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final parsedAmount = double.tryParse(_amountController.text.trim());
    if (parsedAmount == null) {
      return;
    }

    Navigator.of(context).pop(
      ReceiptReviewResult(
        amount: parsedAmount,
        vendorName: _vendorController.text.trim().isEmpty
            ? null
            : _vendorController.text.trim(),
        category: _selectedCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Receipt'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.imagePath.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.cover,
                      height: 200,
                      width: double.infinity,
                    ),
                  ),
                const SizedBox(height: 16),
                const Text(
                  'Confirm the details we detected. Edit anything that looks off before saving.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Receipt Amount',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) {
                      return 'Please enter the receipt total.';
                    }
                    final parsedValue = double.tryParse(trimmed);
                    if (parsedValue == null) {
                      return 'Enter a valid number (e.g. 42.50).';
                    }
                    if (parsedValue <= 0) {
                      return 'Amount must be greater than zero.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _vendorController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Vendor (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    border: OutlineInputBorder(),
                  ),
                  // ignore: deprecated_member_use
                  value: _selectedCategory,
                  items: receiptCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(formatCategoryLabel(category)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'We keep everything on device. You can always revisit and edit this receipt later.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Save & Continue'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
