import 'package:flutter/material.dart';

import '../../core/database/database_helper.dart';
import '../../core/models/data_models.dart';
import '../receipt_scanner/receipt_review_screen.dart';

class ReceiptListScreen extends StatefulWidget {
  const ReceiptListScreen({super.key});

  @override
  State<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends State<ReceiptListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late Future<List<Receipt>> _receiptsFuture;

  @override
  void initState() {
    super.initState();
    _receiptsFuture = _databaseHelper.getAllReceipts();
  }

  Future<void> _refresh() async {
    final receipts = await _databaseHelper.getAllReceipts();
    if (mounted) {
      setState(() {
        _receiptsFuture = Future.value(receipts);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipts'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<List<Receipt>>(
        future: _receiptsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load receipts: ${snapshot.error}'),
            );
          }
          final receipts = snapshot.data ?? [];
          if (receipts.isEmpty) {
            return const Center(
              child: Text('No receipts saved yet. Start by scanning one!'),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: receipts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final receipt = receipts[index];
                return Card(
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.shade100,
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.green,
                      ),
                    ),
                    title: Text(receipt.vendorName ?? 'Unknown Vendor'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '\$${receipt.totalAmount.toStringAsFixed(2)} • Saves \$${receipt.potentialTaxSaving.toStringAsFixed(2)}',
                        ),
                        if (receipt.category != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            formatCategoryLabel(receipt.category!),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${receipt.createdAt.month}/${receipt.createdAt.day}/${receipt.createdAt.year}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
