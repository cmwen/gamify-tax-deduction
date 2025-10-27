import 'package:flutter/material.dart';
import 'package:gamified_tax_deduction/core/services/achievement_service.dart';
import 'package:provider/provider.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/data_models.dart';
import '../../core/models/educational_tip.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/profile_service.dart';
import '../receipt_scanner/receipt_scanner_screen.dart';
import '../profile/profile_screen.dart';
import '../achievements/achievements_screen.dart';
import '../achievements/achievement_notification.dart';
import '../educational/educational_tip_widgets.dart';
import '../receipts/receipt_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double totalSavings = 0.0;
  int receiptCount = 0;
  List<Receipt> recentReceipts = [];
  bool _showTipOfTheDay = true;
  final ProfileService _profileService = ProfileService();
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    // Also check achievements on initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAchievements();
    });
  }

  Future<void> _loadDashboardData() async {
    final savings = await DatabaseHelper.instance.getTotalPotentialSavings();
    final count = await DatabaseHelper.instance.getReceiptCount();
    final receipts = await DatabaseHelper.instance.getAllReceipts();
    final profile = await _profileService.getOrCreateProfile();

    setState(() {
      totalSavings = savings;
      receiptCount = count;
      recentReceipts = receipts.take(5).toList();
      _userProfile = profile;
    });
    
    // Check for newly unlocked achievements
    await _checkAndShowAchievements();
  }

  Future<void> _checkAndShowAchievements() async {
    final achievementService = Provider.of<AchievementService>(context, listen: false);
    final newAchievements = await achievementService.checkAchievements(receiptCount, totalSavings);
    
    // Show notifications for newly unlocked achievements
    if (mounted && newAchievements.isNotEmpty) {
      for (final achievement in newAchievements) {
        await AchievementUnlockedDialog.show(context, achievement);
      }
      achievementService.clearNewlyUnlocked();
    }
  }

  void _checkAchievements() {
    Provider.of<AchievementService>(context, listen: false)
        .checkAchievements(receiptCount, totalSavings);
  }

  @override
  Widget build(BuildContext context) {
    final tipCountry = _userProfile?.taxCountry ?? TaxCountry.unitedStates;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tax Deduction Tracker'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            onPressed: () => EducationalTipsSheet.show(context, country: tipCountry),
            tooltip: 'Tax Tips',
          ),
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
            tooltip: 'Achievements',
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
            tooltip: 'Profile',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main savings display
                  Card(
                    elevation: 4,
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
                          const SizedBox(height: 4),
                          const Text(
                            'Estimate Only - Not Tax Advice',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ReceiptScannerScreen(),
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
                  const SizedBox(height: 16),

                  // Tip of the Day
                  if (_showTipOfTheDay)
                    EducationalTipCard(
                      tip: EducationalTips.getRandomTip(tipCountry),
                      onDismiss: () {
                        setState(() {
                          _showTipOfTheDay = false;
                        });
                      },
                    ),
                  if (_showTipOfTheDay) const SizedBox(height: 16),
                  
                  // Gamification section with progress
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
                          Row(
                            children: [
                              const Icon(Icons.receipt_long, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text('$receiptCount receipts tracked'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Progress bar toward next milestone
                          _buildProgressBar(
                            context,
                            'Next Milestone: \$${_getNextMilestone(totalSavings).toStringAsFixed(0)}',
                            totalSavings,
                            _getNextMilestone(totalSavings),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Recent receipts
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Receipts',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (recentReceipts.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReceiptListScreen(),
                              ),
                            ).then((_) => _loadDashboardData());
                          },
                          icon: const Icon(Icons.list, size: 18),
                          label: const Text('View All'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (recentReceipts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No receipts yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Scan your first receipt to start\ntracking your tax savings!',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentReceipts.length,
                      itemBuilder: (context, index) {
                        final receipt = recentReceipts[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: const Icon(
                                Icons.receipt,
                                color: Colors.green,
                              ),
                            ),
                            title: Text(receipt.vendorName ?? 'Unknown Vendor'),
                            subtitle: Text(
                              '\$${receipt.totalAmount.toStringAsFixed(2)} - Saves: \$${receipt.potentialTaxSaving.toStringAsFixed(2)}',
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${receipt.createdAt.month}/${receipt.createdAt.day}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Text(
                                  '${receipt.createdAt.year}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    String label,
    double current,
    double target,
  ) {
    final progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    final percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            Text(
              '$percentage%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  double _getNextMilestone(double current) {
    const milestones = [100.0, 250.0, 500.0, 1000.0, 1500.0, 2000.0, 3000.0, 5000.0];
    for (final milestone in milestones) {
      if (current < milestone) {
        return milestone;
      }
    }
    return (current / 1000).ceil() * 1000 + 1000; // Next thousand
  }
}
