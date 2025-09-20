import 'package:flutter/material.dart';
import 'package:gamified_tax_deduction/core/services/achievement_service.dart';
import 'package:provider/provider.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<AchievementService>(
        builder: (context, achievementService, child) {
          final achievements = achievementService.achievements;
          if (achievements.isEmpty) {
            return const Center(child: Text("No achievements defined yet."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return Card(
                elevation: achievement.unlocked ? 4 : 1,
                child: ListTile(
                  leading: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      achievement.unlocked ? Colors.transparent : Colors.grey,
                      achievement.unlocked ? BlendMode.dst : BlendMode.saturation,
                    ),
                    child: Image.asset(
                      achievement.imageUrl,
                      width: 50,
                      height: 50,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                  title: Text(
                    achievement.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: achievement.unlocked ? Colors.black : Colors.grey,
                    ),
                  ),
                  subtitle: Text(achievement.description),
                  trailing: achievement.unlocked
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.lock, color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
