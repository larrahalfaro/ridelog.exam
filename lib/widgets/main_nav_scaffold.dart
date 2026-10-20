import 'package:flutter/material.dart';

import '../models/user.dart';
import '../screens/home/dashboard_screen.dart';
import '../screens/motorcycles/motorcycle_list_screen.dart';
import '../screens/reminders/reminders_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/profile/profile_screen.dart';

/// Hosts the 5 bottom-nav tabs described in the navigation structure:
/// Home, My Bikes, Reminders, Reports, Profile.
class MainNavScaffold extends StatefulWidget {
  final AppUser user;
  const MainNavScaffold({super.key, required this.user});

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(user: widget.user),
      MotorcycleListScreen(user: widget.user),
      RemindersScreen(user: widget.user),
      ReportsScreen(user: widget.user),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.two_wheeler), label: 'My Bikes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_active), label: 'Reminders'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
