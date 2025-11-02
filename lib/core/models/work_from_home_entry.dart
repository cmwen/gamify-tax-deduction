class WorkFromHomeEntry {
  final String id;
  final DateTime workingDate;
  final double hours;

  const WorkFromHomeEntry({
    required this.id,
    required this.workingDate,
    required this.hours,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workingDate': workingDate.toIso8601String(),
      'hours': hours,
    };
  }

  factory WorkFromHomeEntry.fromMap(Map<String, dynamic> map) {
    return WorkFromHomeEntry(
      id: map['id'] as String,
      workingDate: DateTime.parse(map['workingDate'] as String),
      hours: (map['hours'] as num).toDouble(),
    );
  }

  WorkFromHomeEntry copyWith({
    String? id,
    DateTime? workingDate,
    double? hours,
  }) {
    return WorkFromHomeEntry(
      id: id ?? this.id,
      workingDate: workingDate ?? this.workingDate,
      hours: hours ?? this.hours,
    );
  }
}
