import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamified_tax_deduction/core/models/user_profile.dart';
import 'package:gamified_tax_deduction/core/services/profile_service.dart';
import 'package:gamified_tax_deduction/core/services/theme_service.dart';
import 'package:gamified_tax_deduction/features/profile/profile_screen.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'profile_screen_test.mocks.dart';

@GenerateMocks([ProfileService])
void main() {
  // Initialize ffi for sqflite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late MockProfileService mockProfileService;

  setUp(() {
    mockProfileService = MockProfileService();
  });

  final testProfile = UserProfile(
    id: 'test_id',
    filingStatus: FilingStatus.single,
    incomeBracket: IncomeBracket.middle,
    taxCountry: TaxCountry.unitedStates,
  );

  // Helper function to build the widget
  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => ThemeService(),
          child: ProfileScreen(profileService: mockProfileService),
        ),
      ),
    );
  }

  testWidgets('should display profile data on load', (WidgetTester tester) async {
    when(mockProfileService.getOrCreateProfile()).thenAnswer((_) async => testProfile);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('United States (IRS)'), findsOneWidget);
    expect(find.text('Established (~90k–170k)'), findsOneWidget);
    expect(find.text('Single'), findsOneWidget);
  });

  testWidgets('Save button should be enabled when fields are selected', (WidgetTester tester) async {
    when(mockProfileService.getOrCreateProfile()).thenAnswer((_) async => testProfile);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final saveButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(saveButton.onPressed, isNotNull);
  });

  testWidgets('should save profile data when save button is pressed', (WidgetTester tester) async {
    when(mockProfileService.getOrCreateProfile()).thenAnswer((_) async => testProfile);
    when(mockProfileService.saveProfile(any)).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: ChangeNotifierProvider(
        create: (_) => ThemeService(),
        child: Navigator(
          onGenerateRoute: (settings) => MaterialPageRoute(
            builder: (context) => ProfileScreen(profileService: mockProfileService),
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    final saveButton = tester.widget<ElevatedButton>(
      find.widgetWithText(ElevatedButton, 'Save Profile'),
    );
    expect(saveButton.onPressed, isNotNull);

    await tester.ensureVisible(find.text('Save Profile'));
    await tester.tap(find.text('Save Profile'));
    await tester.pumpAndSettle();

    verify(mockProfileService.saveProfile(any)).called(1);

    // Check that navigator was popped
    expect(find.byType(ProfileScreen), findsNothing);
  });
}
