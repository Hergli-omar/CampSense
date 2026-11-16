import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campsense/features/user/providers/auth_provider.dart';
import 'package:campsense/features/user/services/auth_service.dart';
import 'package:campsense/features/user/user_api.dart';
import 'test_helpers.dart';

void main() {
  group('UserApi & UserContextX extension tests', () {
    late InMemoryUserRepository repo;
    late AuthService authService;
    late AuthProvider authProvider;

    setUp(() {
      repo = InMemoryUserRepository();
      authService = AuthService(userRepository: repo);
      authProvider = AuthProvider(authService: authService);
    });

    Widget createTestApp({required Widget child}) {
      return ChangeNotifierProvider<AuthProvider>.value(
        value: authProvider,
        child: MaterialApp(
          home: Scaffold(body: child),
        ),
      );
    }

    testWidgets('UserContextX returns null and false when not logged in',
        (tester) async {
      late bool isLoggedIn;
      late bool isAdmin;
      User? user;
      int? userId;
      String? role;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              isLoggedIn = context.isLoggedIn;
              isAdmin = context.isAdmin;
              user = context.currentUser;
              userId = context.currentUserId;
              role = context.currentUserRole;
              return const Text('Test');
            },
          ),
        ),
      );

      expect(isLoggedIn, isFalse);
      expect(isAdmin, isFalse);
      expect(user, isNull);
      expect(userId, isNull);
      expect(role, isNull);
    });

    testWidgets('UserContextX reflects logged-in regular camper',
        (tester) async {
      final camper = await repo.createUser(const User(
        id: 42,
        fullName: 'Test Camper',
        email: 'camper@test.com',
        passwordHash: 'hash',
        salt: 'salt',
        role: UserRoles.camper,
        experienceLevel: 'beginner',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ));
      authProvider.refreshCurrentUser(camper);

      late bool isLoggedIn;
      late bool isAdmin;
      User? user;
      int? userId;
      String? role;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              isLoggedIn = context.isLoggedIn;
              isAdmin = context.isAdmin;
              user = context.currentUser;
              userId = context.currentUserId;
              role = context.currentUserRole;
              return const Text('Test');
            },
          ),
        ),
      );

      expect(isLoggedIn, isTrue);
      expect(isAdmin, isFalse);
      expect(user?.fullName, 'Test Camper');
      expect(userId, camper.id);
      expect(role, UserRoles.camper);
    });

    testWidgets('UserContextX reflects logged-in admin', (tester) async {
      final admin = await repo.createUser(const User(
        id: 99,
        fullName: 'Omar Admin',
        email: 'admin@test.com',
        passwordHash: 'hash',
        salt: 'salt',
        role: UserRoles.admin,
        experienceLevel: 'advanced',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ));
      authProvider.refreshCurrentUser(admin);

      late bool isAdmin;

      await tester.pumpWidget(
        createTestApp(
          child: Builder(
            builder: (context) {
              isAdmin = context.isAdmin;
              return const Text('Test');
            },
          ),
        ),
      );

      expect(isAdmin, isTrue);
    });

    testWidgets('RequireLogin widget displays child only when authenticated',
        (tester) async {
      await tester.pumpWidget(
        createTestApp(
          child: const RequireLogin(
            fallback: Text('Veuillez vous connecter'),
            child: Text('Contenu Protégé'),
          ),
        ),
      );

      expect(find.text('Veuillez vous connecter'), findsOneWidget);
      expect(find.text('Contenu Protégé'), findsNothing);

      // Connecter l'utilisateur
      final user = await repo.createUser(const User(
        fullName: 'Connecté',
        email: 'login@test.com',
        passwordHash: 'h',
        salt: 's',
        role: 'camper',
        experienceLevel: 'beginner',
        createdAt: '2026-01-01',
        updatedAt: '2026-01-01',
      ));
      authProvider.refreshCurrentUser(user);
      await tester.pump();

      expect(find.text('Contenu Protégé'), findsOneWidget);
      expect(find.text('Veuillez vous connecter'), findsNothing);
    });
  });
}
