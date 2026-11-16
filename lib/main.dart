import 'package:flutter/material.dart';
import 'app.dart';
import 'features/user/data/sqlite_user_repository.dart';
import 'features/user/services/admin_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate data layer and idempotently seed the unique Administrator
  // as well as initial demo users in debug mode.
  final userRepository = SqliteUserRepository();
  await AdminSeeder.seedAll(userRepository);

  runApp(CampSenseApp(userRepository: userRepository));
}
