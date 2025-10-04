// lib/core/models/achievement.dart

class Achievement {
  final String id;
  final String name;
  final String description;
  final bool unlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    this.unlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    bool? unlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id,
      name: name,
      description: description,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'unlocked': unlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      unlocked: map['unlocked'] == 1,
      unlockedAt: map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
    );
  }
}

class Achievements {
  static final List<Achievement> all = [
    // Scanning milestones
    Achievement(
      id: 'first_receipt',
      name: 'First Steps',
      description: 'Scan your first receipt.',
    ),
    Achievement(
      id: 'five_receipts',
      name: 'Getting Started',
      description: 'Scan 5 receipts.',
    ),
    Achievement(
      id: 'ten_receipts',
      name: 'Receipt Collector',
      description: 'Scan 10 receipts.',
    ),
    Achievement(
      id: 'twenty_five_receipts',
      name: 'Diligent Tracker',
      description: 'Scan 25 receipts.',
    ),
    Achievement(
      id: 'fifty_receipts',
      name: 'Receipt Master',
      description: 'Scan 50 receipts.',
    ),
    Achievement(
      id: 'hundred_receipts',
      name: 'Century Club',
      description: 'Scan 100 receipts!',
    ),
    
    // Savings milestones
    Achievement(
      id: 'fifty_deduction',
      name: 'First Savings',
      description: r'Reach $50 in potential tax deductions.',
    ),
    Achievement(
      id: 'hundred_deduction',
      name: 'Deduction Beginner',
      description: r'Reach $100 in potential tax deductions.',
    ),
    Achievement(
      id: 'two_fifty_deduction',
      name: 'Smart Saver',
      description: r'Reach $250 in potential tax deductions.',
    ),
    Achievement(
      id: 'five_hundred_deduction',
      name: 'Deduction Enthusiast',
      description: r'Reach $500 in potential tax deductions.',
    ),
    Achievement(
      id: 'thousand_deduction',
      name: 'Tax Saver',
      description: r'Reach $1,000 in potential tax deductions!',
    ),
    Achievement(
      id: 'two_thousand_deduction',
      name: 'Savings Champion',
      description: r'Reach $2,000 in potential tax deductions!',
    ),
    Achievement(
      id: 'five_thousand_deduction',
      name: 'Elite Saver',
      description: r'Reach $5,000 in potential tax deductions!',
    ),
  ];
}
