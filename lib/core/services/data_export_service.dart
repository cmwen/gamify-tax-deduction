import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';

class DataExportService {
  final DatabaseHelper dbHelper;

  DataExportService({DatabaseHelper? dbHelper})
      : dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<void> exportAllData() async {
    final receipts = await dbHelper.getAllReceipts();
    final workFromHomeEntries = await dbHelper.getWorkFromHomeEntries();
    final payload = {
      'exportedAt': DateTime.now().toIso8601String(),
      'receipts': receipts.map((r) => r.toMap()).toList(),
      'workFromHomeEntries': workFromHomeEntries.map((e) => e.toMap()).toList(),
    };

    final directory = await getTemporaryDirectory();
    final file = File(
        '${directory.path}/tax_tracker_export_${DateTime.now().millisecondsSinceEpoch}.json');
    await file
        .writeAsString(const JsonEncoder.withIndent('  ').convert(payload));

    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Tax tracker data export',
      subject: 'Gamified Tax Deduction export',
    );
  }
}
