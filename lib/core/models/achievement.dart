// lib/core/models/achievement.dart

class Achievement {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool unlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
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
      imageUrl: imageUrl,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'unlocked': unlocked ? 1 : 0,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      imageUrl: map['imageUrl'],
      unlocked: map['unlocked'] == 1,
      unlockedAt: map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt']) : null,
    );
  }
}

class Achievements {
  static final List<Achievement> all = [
    Achievement(
      id: 'first_receipt',
      name: 'First Receipt',
      description: 'Scan your first receipt.',
      imageUrl: 'assets/images/first_receipt.png',
    ),
    Achievement(
      id: 'ten_receipts',
      name: 'Receipt Collector',
      description: 'Scan 10 receipts.',
      imageUrl: 'assets/images/ten_receipts.png',
    ),
    Achievement(
      id: 'hundred_deduction',
      name: 'Deduction Beginner',
      description: r'Reach $100 in potential tax deductions.',
      imageUrl: 'assets/images/hundred_deduction.png',
    ),
    Achievement(
      id: 'five_hundred_deduction',
      name: 'Deduction Enthusiast',
      description: r'Reach $500 in potential tax deductions.',
      imageUrl: 'assets/images/five_hundred_deduction.png',
    ),
  ];
}
