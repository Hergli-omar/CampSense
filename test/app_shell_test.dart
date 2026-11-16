import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campsense/core/constants/common_strings.dart';
import 'package:campsense/core/theme/app_theme.dart';
import 'package:campsense/features/user/models/user.dart';
import 'package:campsense/features/user/providers/auth_provider.dart';
import 'package:campsense/features/user/providers/theme_provider.dart';
import 'package:campsense/features/user/providers/user_provider.dart';
import 'package:campsense/features/user/services/auth_service.dart';
import 'package:campsense/shell/app_shell.dart';
import 'test_helpers.dart';

void main() {
  group('AppShell Navigation & AppBar Tests', () {
    late InMemoryUserRepository repo;
    late AuthService authService;
    late AuthProvider authProvider;
    late UserProvider userProvider;
    late ThemeProvider themeProvider;
    late User testUser;

    setUp(() async {
      repo = InMemoryUserRepository();
      authService = AuthService(userRepository: repo);
      authProvider = AuthProvider(authService: authService);
      userProvider = UserProvider(userRepository: repo);
      themeProvider = ThemeProvider();

      testUser = await repo.createUser(const User(
        id: 1,
        fullName: 'Azza Drissi',
        email: 'azza.drissi@example.com',
        passwordHash: 'hash',
        salt: 'salt',
        role: 'camper',
        experienceLevel: 'intermediate',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ));
      authProvider.refreshCurrentUser(testUser);
    });

    Widget createTestApp() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<UserProvider>.value(value: userProvider),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const AppShell(),
        ),
      );
    }

    testWidgets('AppShell has exactly 5 module tabs and no Profil tab in bottom bar',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final navBarFinder = find.byType(NavigationBar);
      expect(navBarFinder, findsOneWidget);

      final navBar = tester.widget<NavigationBar>(navBarFinder);
      expect(navBar.destinations.length, 5);

      // Verify the 5 labels
      expect(find.text(CommonStrings.moduleEvents), findsWidgets);
      expect(find.text(CommonStrings.moduleMarketplace), findsWidgets);
      expect(find.text(CommonStrings.moduleTransport), findsWidgets);
      expect(find.text(CommonStrings.moduleTutorials), findsWidgets);
      expect(find.text(CommonStrings.moduleCampsite), findsWidgets);

      // Verify Profil is NOT a bottom navigation destination label
      expect(find.text('Profil'), findsNothing);
    });

    testWidgets('AppShell shared AppBar displays title, search icon, and avatar initials',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // CampSense brand title
      expect(find.text(CommonStrings.appName), findsOneWidget);

      // Search button
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // Avatar with initials "AD" for Azza Drissi
      expect(find.text('AD'), findsOneWidget);
    });

    testWidgets('Tapping search icon displays SnackBar "Recherche bientôt disponible"',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      final searchButton = find.byIcon(Icons.search_rounded);
      await tester.tap(searchButton);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 300)); // Render snackbar

      expect(find.text(CommonStrings.searchComingSoon), findsOneWidget);
    });

    testWidgets('Tapping user avatar opens ProfileScreen above shell with back button',
        (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      // Tap the avatar circle
      final avatarFinder = find.text('AD');
      expect(avatarFinder, findsOneWidget);
      await tester.tap(avatarFinder);
      await tester.pumpAndSettle();

      // ProfileScreen should now be visible with the user's name
      expect(find.text('Azza Drissi'), findsWidgets);
      // Profile screen header should have a back button
      expect(find.byTooltip('Retour'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byTooltip('Retour'));
      await tester.pumpAndSettle();

      // Back to shell (AppShell mountain icon / title still present)
      expect(find.text(CommonStrings.appName), findsOneWidget);
    });
  });
}
