import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../database/database_helper.dart';

class AchievementService with ChangeNotifier {
  final DatabaseHelper dbHelper;
  List<Achievement> _achievements = [];

  List<Achievement> get achievements => _achievements;

  AchievementService({required this.dbHelper}) {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    _achievements = await dbHelper.getAchievements();
    notifyListeners();
  }

  Future<void> checkAchievements(int receiptCount, double totalSavings) async {
    bool wasUpdated = false;
    for (int i = 0; i < _achievements.length; i++) {
      var achievement = _achievements[i];
      if (!achievement.unlocked) {
        bool unlocked = false;
        switch (achievement.id) {
          case 'first_receipt':
            if (receiptCount >= 1) unlocked = true;
            break;
          case 'ten_receipts':
            if (receiptCount >= 10) unlocked = true;
            break;
          case 'hundred_deduction':
            if (totalSavings >= 100) unlocked = true;
            break;
          case 'five_hundred_deduction':
            if (totalSavings >= 500) unlocked = true;
            break;
        }

        if (unlocked) {
          _achievements[i] = achievement.copyWith(unlocked: true, unlockedAt: DateTime.now());
          await dbHelper.updateAchievement(_achievements[i]);
          wasUpdated = true;
        }
      }
    }
    if (wasUpdated) {
      notifyListeners();
    }
  }
}
