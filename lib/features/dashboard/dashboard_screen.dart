import 'package:flutter/material.dart';
import 'package:gamified_tax_deduction/core/services/achievement_service.dart';
import 'package:provider/provider.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/data_models.dart';
import '../receipt_scanner/receipt_scanner_screen.dart';
import '../profile/profile_screen.dart';
import '../achievements/achievements_screen.dart';
import '../../core/services/educational_content_service.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalSavings = 0.0;
  int receiptCount = 0;
  List<Receipt> recentReceipts = [];
  bool _showAnimation = false;
  int scanningStreak = 0;
  int receiptsScannedThisMonth = 0;
  double savingsGoal = 1500.0;

  late final AchievementService _achievementService;

  @override
  void initState() {
    super.initState();
    _achievementService = Provider.of<AchievementService>(context, listen: false);
    _loadDashboardData();
    // Also check achievements on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAchievements();
      _achievementService.addListener(_onAchievementUnlocked);
    });
  }

  @override
  void dispose() {
    _achievementService.removeListener(_onAchievementUnlocked);
    super.dispose();
  }

  void _onAchievementUnlocked() {
    final service = Provider.of<AchievementService>(context, listen: false);
    if (service.achievements.any((a) => a.unlocked && a.unlockedAt!.isAfter(DateTime.now().subtract(const Duration(seconds: 1))))) {
      setState(() {
        _showAnimation = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        setState(() {
          _showAnimation = false;
        });
      });
    }
  }

  Future<void> _loadDashboardData() async {
    final savings = await DatabaseHelper.instance.getTotalPotentialSavings();
    final count = await DatabaseHelper.instance.getReceiptCount();
    final receipts = await DatabaseHelper.instance.getAllReceipts();
    final streak = await DatabaseHelper.instance.getScanningStreak();
    final scannedThisMonth = await DatabaseHelper.instance.getReceiptsScannedThisMonth();
    
    setState(() {
      totalSavings = savings;
      receiptCount = count;
      recentReceipts = receipts.take(5).toList();
      scanningStreak = streak;
      receiptsScannedThisMonth = scannedThisMonth;
    });
    _checkAchievements();
  }

  void _checkAchievements() {
    Provider.of<AchievementService>(context, listen: false)
        .checkAchievements(receiptCount, totalSavings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Deduction Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AchievementsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Main savings display
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        const Text(
                          'Total Potential Savings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '\$${totalSavings.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReceiptScannerScreen(),
                              ),
                            );
                            _loadDashboardData(); // Refresh data after scan
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Scan New Receipt'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '💡 Tip of the Day',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(EducationalContentService.getTipOfTheDay()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<AchievementService>(
                  builder: (context, achievementService, child) {
                    final unlockedAchievements = achievementService.achievements
                        .where((a) => a.unlocked)
                        .toList();
                    if (unlockedAchievements.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🏆 Recent Achievements',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: unlockedAchievements.length > 3
                                ? 3
                                : unlockedAchievements.length,
                            itemBuilder: (context, index) {
                              final achievement = unlockedAchievements[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Column(
                                  children: [
                                    Image.asset(
                                      achievement.imageUrl,
                                      width: 64,
                                      height: 64,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(achievement.name),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

                // Gamification section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🎯 This Year\'s Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearPercentIndicator(
                          lineHeight: 20.0,
                          percent: totalSavings / savingsGoal > 1.0 ? 1.0 : totalSavings / savingsGoal,
                          center: Text(
                            "${(totalSavings / savingsGoal * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(color: Colors.white),
                          ),
                          barRadius: const Radius.circular(10),
                          progressColor: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        Text("Total Potential Savings: \$${totalSavings.toStringAsFixed(2)} of \$${savingsGoal.toStringAsFixed(2)} goal"),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text('$scanningStreak-day scanning streak'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.receipt_long, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text('$receiptsScannedThisMonth receipts this month'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recent receipts
                const Text(
                  'Recent Receipts',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (recentReceipts.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.receipt),
                      title: Text(recentReceipts.first.vendorName ?? 'Unknown Vendor'),
                      subtitle: Text(
                        '\$${recentReceipts.first.totalAmount.toStringAsFixed(2)} - Potential saving: \$${recentReceipts.first.potentialTaxSaving.toStringAsFixed(2)}',
                      ),
                      trailing: Text(
                        '${recentReceipts.first.createdAt.day}/${recentReceipts.first.createdAt.month}',
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Text(
                      'No receipts yet. Scan your first receipt to get started!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
          if (_showAnimation)
            Center(
              child: Lottie.asset('assets/animations/achievement_unlocked.json'),
            ),
        ],
      ),
    );
  }
}