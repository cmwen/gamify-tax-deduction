import 'package:flutter/material.dart';
import 'package:gamified_tax_deduction/features/dashboard/dashboard_screen.dart';
import 'package:gamified_tax_deduction/core/database/database_helper.dart';
import 'package:gamified_tax_deduction/core/services/achievement_service.dart';
import 'package:gamified_tax_deduction/core/services/theme_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  final dbHelper = DatabaseHelper.instance;
  await dbHelper.database;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AchievementService(dbHelper: dbHelper),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeService(),
        ),
      ],
      child: const GamifiedTaxDeductionApp(),
    ),
  );
}

class GamifiedTaxDeductionApp extends StatelessWidget {
  const GamifiedTaxDeductionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        const Color baseColor = Colors.green;
        final ThemeData lightTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: baseColor),
          brightness: Brightness.light,
          useMaterial3: true,
        );
        final ThemeData darkTheme = ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: baseColor,
            brightness: Brightness.dark,
          ),
          brightness: Brightness.dark,
          useMaterial3: true,
        );

        return MaterialApp(
          title: 'Gamified Tax Deduction',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeService.themeMode,
          home: const DashboardScreen(),
        );
      },
    );
  }
}
