import 'package:flutter/foundation.dart';
import '../models/achievement.dart';
import '../database/database_helper.dart';

class AchievementService with ChangeNotifier {
  final DatabaseHelper dbHelper;
  List<Achievement> _achievements = [];
  List<Achievement> _newlyUnlocked = [];

  Future<void>? _initialization;
  bool _isLoaded = false;

  List<Achievement> get achievements => _achievements;
  List<Achievement> get newlyUnlocked => _newlyUnlocked;

  AchievementService({required this.dbHelper}) {
    _initialization = _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    _achievements = await dbHelper.getAchievements();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _ensureLoaded() async {
    if (_isLoaded) {
      return;
    }
    _initialization ??= _loadAchievements();
    await _initialization;
  }

  /// Check achievements and return newly unlocked ones
  Future<List<Achievement>> checkAchievements(int receiptCount, double totalSavings) async {
    await _ensureLoaded();
    _newlyUnlocked = [];
    bool wasUpdated = false;
    
    for (int i = 0; i < _achievements.length; i++) {
      var achievement = _achievements[i];
      if (!achievement.unlocked) {
        bool unlocked = false;
        switch (achievement.id) {
          // Scanning milestones
          case 'first_receipt':
            if (receiptCount >= 1) unlocked = true;
            break;
          case 'five_receipts':
            if (receiptCount >= 5) unlocked = true;
            break;
          case 'ten_receipts':
            if (receiptCount >= 10) unlocked = true;
            break;
          case 'twenty_five_receipts':
            if (receiptCount >= 25) unlocked = true;
            break;
          case 'fifty_receipts':
            if (receiptCount >= 50) unlocked = true;
            break;
          case 'hundred_receipts':
            if (receiptCount >= 100) unlocked = true;
            break;
            
          // Savings milestones
          case 'fifty_deduction':
            if (totalSavings >= 50) unlocked = true;
            break;
          case 'hundred_deduction':
            if (totalSavings >= 100) unlocked = true;
            break;
          case 'two_fifty_deduction':
            if (totalSavings >= 250) unlocked = true;
            break;
          case 'five_hundred_deduction':
            if (totalSavings >= 500) unlocked = true;
            break;
          case 'thousand_deduction':
            if (totalSavings >= 1000) unlocked = true;
            break;
          case 'two_thousand_deduction':
            if (totalSavings >= 2000) unlocked = true;
            break;
          case 'five_thousand_deduction':
            if (totalSavings >= 5000) unlocked = true;
            break;
        }

        if (unlocked) {
          _achievements[i] = achievement.copyWith(unlocked: true, unlockedAt: DateTime.now());
          await dbHelper.updateAchievement(_achievements[i]);
          _newlyUnlocked.add(_achievements[i]);
          wasUpdated = true;
        }
      }
    }
    
    if (wasUpdated) {
      notifyListeners();
    }
    
    return _newlyUnlocked;
  }

  /// Clear the newly unlocked list after showing notifications
  void clearNewlyUnlocked() {
    _newlyUnlocked = [];
  }
}
