import 'package:flutter/material.dart';

import 'db/database_factory_stub.dart'
    if (dart.library.html) 'db/database_factory_web.dart';
import 'db/database_helper.dart';
import 'models/user.dart';
import 'utils/constants.dart';
import 'screens/splash_screen.dart';
import 'widgets/main_nav_scaffold.dart';

/// PREVIEW MODE
/// Set this to true to skip Splash/Login/Onboarding entirely and open
/// straight to the Dashboard — useful for checking the UI before you have
/// a real account or any data. No database setup needed for this to work;
/// it just queries the local SQLite file for a placeholder user's bikes
/// (which will be empty, so you'll land on the empty-state screen and can
/// add a motorcycle from there to explore the rest of the interface).
///
/// Set back to false before you actually demo the login/registration flow.
const bool kPreviewMode = true;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDatabaseFactory();
  AppUser? previewUser;
  if (kPreviewMode) {
    final preview = AppUser(
      name: 'Preview User',
      email: 'preview@ridelog.app',
      passwordHash: '',
      preferredUnit: 'km',
      preferredCurrency: 'PHP',
      createdAt: DateTime.now().toIso8601String(),
    );
    previewUser = await DatabaseHelper.instance.getUserByEmail(preview.email);
    if (previewUser == null) {
      await DatabaseHelper.instance.createUser(preview);
      previewUser = await DatabaseHelper.instance.getUserByEmail(preview.email);
    }
    if (previewUser == null) {
      throw StateError('Unable to initialize the preview user.');
    }
  }
  runApp(RideLogApp(previewUser: previewUser));
}

class RideLogApp extends StatelessWidget {
  final AppUser? previewUser;

  const RideLogApp({super.key, this.previewUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RideLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: kPreviewMode ? _buildPreviewHome() : const SplashScreen(),
    );
  }

  /// A fake, unsaved AppUser just for browsing the UI. It's never written
  /// to the users table, but that's fine — every query in this app is
  /// scoped by user_id without checking the users table exists, so screens
  /// render normally (just with zero motorcycles/logs to start).
  Widget _buildPreviewHome() {
    return MainNavScaffold(user: previewUser!);
  }
}
