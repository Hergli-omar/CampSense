import 'package:flutter/material.dart';
import '../../shell/admin_shell.dart';
import '../../shell/app_shell.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/splash_screen.dart';

/// Définition des routes propres au module User.
class UserRoutes {
  // Constantes de nommage
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String shell = '/shell';
  static const String adminShell = '/admin_shell';
  static const String editProfile = '/edit_profile';

  /// Map des routes déclarées par le module User.
  static final Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    shell: (context) => const AppShell(),
    adminShell: (context) => const AdminShell(),
    editProfile: (context) => const EditProfileScreen(),
  };
}
