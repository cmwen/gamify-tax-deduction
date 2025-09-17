import 'package:flutter/material.dart';
import 'package:gamified_tax_deduction/core/services/achievement_service.dart';
import 'package:provider/provider.dart';
import 'package:gamified_tax_deduction/core/models/achievement.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: Consumer<AchievementService>(
        builder: (context, achievementService, child) {
          final achievements = achievementService.achievements;
          if (achievements.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return ListTile(
                leading: Icon(
                  achievement.unlocked ? Icons.lock_open : Icons.lock,
                  color: achievement.unlocked ? Colors.green : Colors.grey,
                ),
                title: Text(achievement.name),
                subtitle: Text(achievement.description),
                trailing: achievement.unlocked && achievement.unlockedAt != null
                    ? Text(
                        'Unlocked on ${achievement.unlockedAt!.toLocal().toString().split(' ')[0]}')
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
