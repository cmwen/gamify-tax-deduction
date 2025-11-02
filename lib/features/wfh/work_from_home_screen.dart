import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/models/work_from_home_entry.dart';
import '../../core/services/work_from_home_service.dart';
import 'work_from_home_week_dialog.dart';

class WorkFromHomeScreen extends StatefulWidget {
  const WorkFromHomeScreen({super.key});

  @override
  State<WorkFromHomeScreen> createState() => _WorkFromHomeScreenState();
}

class _WorkFromHomeScreenState extends State<WorkFromHomeScreen> {
  final WorkFromHomeService _service = WorkFromHomeService();
  late Future<List<WorkFromHomeEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = _service.getEntries();
  }

  Future<void> _refreshEntries() async {
    final entries = await _service.getEntries();
    if (mounted) {
      setState(() {
        _entriesFuture = Future.value(entries);
      });
    }
  }

  Future<void> _openWeekPlanner() async {
    final result = await WorkFromHomeWeekPlanner.show(context);
    if (result != null && result.isNotEmpty) {
      await _service.saveWeekSchedule(result);
      await _refreshEntries();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work-from-home hours updated.')),
        );
      }
    }
  }

  Future<void> _editEntry(WorkFromHomeEntry entry) async {
    final controller =
        TextEditingController(text: entry.hours.toStringAsFixed(2));
    final result = await showDialog<double?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adjust logged hours'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(DateFormat('EEEE, MMM d').format(entry.workingDate)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Hours',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter 0 to remove this entry.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = double.tryParse(controller.text.trim());
                Navigator.pop(context, parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null) {
      return;
    }

    if (result <= 0) {
      await _service.deleteEntry(entry.id);
    } else {
      await _service.saveWeekSchedule({entry.workingDate: result});
    }
    await _refreshEntries();
  }

  Future<void> _deleteEntry(WorkFromHomeEntry entry) async {
    await _service.deleteEntry(entry.id);
    await _refreshEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Work From Home Log'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openWeekPlanner,
        icon: const Icon(Icons.add_task),
        label: const Text('Add week'),
      ),
      body: FutureBuilder<List<WorkFromHomeEntry>>(
        future: _entriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child:
                  Text('Unable to load work-from-home data: ${snapshot.error}'),
            );
          }

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.home_work, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      'Track your work-from-home days to estimate the ATO fixed rate deduction.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _openWeekPlanner,
                      child: const Text('Start logging'),
                    ),
                  ],
                ),
              ),
            );
          }

          final totalHours = _service.totalLoggedHours(entries);
          final potentialSavings =
              _service.calculatePotentialSavings(totalHours);
          final dateFormatter = DateFormat('EEE, MMM d');

          return RefreshIndicator(
            onRefresh: _refreshEntries,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: entries.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Summary',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                              'Logged hours: ${totalHours.toStringAsFixed(1)}'),
                          const SizedBox(height: 4),
                          Text(
                              'Estimated deduction: AUD ${potentialSavings.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          Text(
                            'Using ATO fixed rate of ${WorkFromHomeService.deductionRateAudPerHour.toStringAsFixed(2)} per hour.',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final entry = entries[index - 1];
                return Card(
                  margin: EdgeInsets.fromLTRB(16, index == 1 ? 0 : 8, 16, 8),
                  child: ListTile(
                    title: Text(dateFormatter.format(entry.workingDate)),
                    subtitle: Text('Hours: ${entry.hours.toStringAsFixed(2)}'),
                    onTap: () => _editEntry(entry),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteEntry(entry),
                      tooltip: 'Remove entry',
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
