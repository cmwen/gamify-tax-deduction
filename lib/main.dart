import 'package:flutter/material.dart';
import 'package:gamified_tax_deduction/features/dashboard/dashboard_screen.dart';
import 'package:gamified_tax_deduction/core/database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database
  await DatabaseHelper.instance.database;
  
  runApp(const GamifiedTaxDeductionApp());
}

class GamifiedTaxDeductionApp extends StatelessWidget {
  const GamifiedTaxDeductionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gamified Tax Deduction',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}