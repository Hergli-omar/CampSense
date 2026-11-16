import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/camp_sense_scroll_behavior.dart';
import 'features/user/data/sqlite_user_repository.dart';
import 'features/user/data/user_repository.dart';
import 'features/user/providers/admin_users_provider.dart';
import 'features/user/providers/auth_provider.dart';
import 'features/user/providers/theme_provider.dart';
import 'features/user/providers/user_provider.dart';
import 'features/user/services/auth_service.dart';
import 'features/user/services/identity_verifier.dart';

/// Root application widget that configures:
/// - Dependency injection with Providers
/// - French localization
/// - Dynamic Light/Dark theming driven by ambient sensor or manual preference
/// - Centralized modular routing via [AppRouter]
class CampSenseApp extends StatelessWidget {
  final UserRepository? userRepository;

  const CampSenseApp({super.key, this.userRepository});

  @override
  Widget build(BuildContext context) {
    // 1. Data layer abstraction
    // NOTE: To migrate to Firebase or a remote API, replace SqliteUserRepository
    // with FirebaseUserRepository here.
    final UserRepository repo = userRepository ?? SqliteUserRepository();
    const IdentityVerifier identityVerifier = PasswordIdentityVerifier();

    // 2. Service layer
    final authService = AuthService(
      userRepository: repo,
      identityVerifier: identityVerifier,
    );

    return MultiProvider(
      providers: [
        Provider<UserRepository>.value(value: repo),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService: authService),
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(
            userRepository: repo,
            identityVerifier: identityVerifier,
          ),
        ),
        ChangeNotifierProvider<AdminUsersProvider>(
          create: (_) => AdminUsersProvider(
            userRepository: repo,
            identityVerifier: identityVerifier,
          ),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'CampSense',
            debugShowCheckedModeBanner: false,
            // Theme configuration
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            scrollBehavior: const CampSenseScrollBehavior(),
            // French localization setup
            locale: const Locale('fr', 'FR'),
            supportedLocales: const [
              Locale('fr', 'FR'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            // Centralized modular routes
            initialRoute: AppRoutes.splash,
            routes: AppRouter.allRoutes,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}
