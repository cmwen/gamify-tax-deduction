import 'package:flutter/material.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/data_models.dart';
import '../receipt_scanner/receipt_scanner_screen.dart';
import '../profile/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalSavings = 0.0;
  int receiptCount = 0;
  List<Receipt> recentReceipts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final savings = await DatabaseHelper.instance.getTotalPotentialSavings();
    final count = await DatabaseHelper.instance.getReceiptCount();
    final receipts = await DatabaseHelper.instance.getAllReceipts();
    
    setState(() {
      totalSavings = savings;
      receiptCount = count;
      recentReceipts = receipts.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Deduction Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main savings display
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const Text(
                      'Total Potential Savings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalSavings.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ReceiptScannerScreen(),
                          ),
                        );
                        _loadDashboardData(); // Refresh data after scan
                      },
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan New Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Gamification section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🎯 This Year\'s Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.receipt_long, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text('$receiptCount receipts tracked'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.savings, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text('\$${totalSavings.toStringAsFixed(2)} potential savings'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Recent receipts
            const Text(
              'Recent Receipts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: recentReceipts.isEmpty
                  ? const Center(
                      child: Text(
                        'No receipts yet. Scan your first receipt to get started!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: recentReceipts.length,
                      itemBuilder: (context, index) {
                        final receipt = recentReceipts[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.receipt),
                            title: Text(receipt.vendorName ?? 'Unknown Vendor'),
                            subtitle: Text(
                              '\$${receipt.totalAmount.toStringAsFixed(2)} - Potential saving: \$${receipt.potentialTaxSaving.toStringAsFixed(2)}',
                            ),
                            trailing: Text(
                              '${receipt.createdAt.day}/${receipt.createdAt.month}',
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}