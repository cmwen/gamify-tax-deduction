import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkFromHomeWeekPlanner extends StatefulWidget {
  const WorkFromHomeWeekPlanner({super.key});

  static Future<Map<DateTime, double>?> show(BuildContext context) {
    return showDialog<Map<DateTime, double>?>(
      context: context,
      builder: (_) => const Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: WorkFromHomeWeekPlanner(),
      ),
    );
  }

  @override
  State<WorkFromHomeWeekPlanner> createState() =>
      _WorkFromHomeWeekPlannerState();
}

class _DaySchedule {
  final DateTime date;
  bool isSelected;
  final TextEditingController controller;

  _DaySchedule({
    required this.date,
    required this.isSelected,
    required this.controller,
  });
}

class _WorkFromHomeWeekPlannerState extends State<WorkFromHomeWeekPlanner> {
  late DateTime _weekStart;
  late List<_DaySchedule> _schedules;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _weekStart = _startOfWeek(DateTime.now());
    _buildSchedules();
  }

  @override
  void dispose() {
    for (final schedule in _schedules) {
      schedule.controller.dispose();
    }
    super.dispose();
  }

  DateTime _startOfWeek(DateTime date) {
    return DateTime(
        date.year, date.month, date.day - (date.weekday - DateTime.monday));
  }

  void _buildSchedules() {
    _schedules = List.generate(7, (index) {
      final date = _weekStart.add(Duration(days: index));
      final isWeekday = date.weekday <= DateTime.friday;
      return _DaySchedule(
        date: date,
        isSelected: isWeekday,
        controller: TextEditingController(text: isWeekday ? '8' : ''),
      );
    });
  }

  Future<void> _changeWeek() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    for (final schedule in _schedules) {
      schedule.controller.dispose();
    }
    setState(() {
      _weekStart = _startOfWeek(picked);
      _buildSchedules();
      _errorMessage = null;
    });
  }

  void _toggleSelection(_DaySchedule schedule) {
    setState(() {
      schedule.isSelected = !schedule.isSelected;
      if (!schedule.isSelected) {
        schedule.controller.text = '';
      } else if (schedule.controller.text.trim().isEmpty) {
        schedule.controller.text = '8';
      }
    });
  }

  void _submit() {
    final Map<DateTime, double> result = {};
    for (final schedule in _schedules) {
      if (!schedule.isSelected) {
        continue;
      }
      final text = schedule.controller.text.trim();
      final hours = double.tryParse(text);
      if (hours == null || hours <= 0) {
        setState(() {
          _errorMessage =
              'Enter a valid positive number of hours for selected days.';
        });
        return;
      }
      final normalized =
          DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
      result[normalized] = hours;
    }

    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEE d MMM');
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan your week',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormatter.format(_weekStart)} - ${dateFormatter.format(_weekStart.add(const Duration(days: 6)))}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: _changeWeek,
                icon: const Icon(Icons.calendar_today),
                label: const Text('Change week'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 340,
            child: SingleChildScrollView(
              child: Column(
                children: _schedules.map((schedule) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: schedule.isSelected,
                                onChanged: (_) => _toggleSelection(schedule),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dateFormatter.format(schedule.date),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      schedule.date.weekday <= DateTime.friday
                                          ? 'Default 8 hour day'
                                          : 'Weekend',
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (schedule.isSelected)
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 12, right: 12, bottom: 8),
                              child: TextField(
                                controller: schedule.controller,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                decoration: const InputDecoration(
                                  labelText: 'Hours worked',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
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
                  onPressed: _submit,
                  child: const Text('Save week'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
