import 'package:flutter/material.dart';

import '../utils/auth_service.dart';
import '../utils/constants.dart';
import '../db/database_helper.dart';
import '../widgets/main_nav_scaffold.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Small delay purely for branding/splash feel.
    await Future.delayed(const Duration(milliseconds: 900));
    final user = await AuthService.getCurrentUser();
    if (!mounted) return;

    if (user != null) {
      final bikes = await DatabaseHelper.instance.getMotorcyclesForUser(user.id!);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => MainNavScaffold(user: user),
      ));
      // If they have no bikes yet, the Dashboard itself will prompt onboarding.
      if (bikes.isEmpty) {
        // no-op: DashboardScreen handles the empty state.
      }
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.two_wheeler, size: 80, color: AppColors.accent),
            const SizedBox(height: 16),
            const Text(
              'RideLog',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Know your bike. Own the road.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: AppColors.accent),
          ],
        ),
      ),
    );
  }
}
