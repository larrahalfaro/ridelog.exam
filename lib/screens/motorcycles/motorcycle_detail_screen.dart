import 'package:flutter/material.dart';

import '../../models/motorcycle.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import '../maintenance/maintenance_list_screen.dart';
import '../fuel/fuel_list_screen.dart';
import 'add_edit_motorcycle_screen.dart';

class MotorcycleDetailScreen extends StatelessWidget {
  final AppUser user;
  final Motorcycle motorcycle;
  const MotorcycleDetailScreen(
      {super.key, required this.user, required this.motorcycle});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(motorcycle.displayName),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => AddEditMotorcycleScreen(
                      user: user, motorcycle: motorcycle),
                ));
                if (context.mounted) Navigator.of(context).pop(); // refresh caller
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.accent,
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: 'Maintenance'),
              Tab(text: 'Fuel'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: TabBarView(
                children: [
                  MaintenanceListScreen(motorcycle: motorcycle),
                  FuelListScreen(motorcycle: motorcycle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Icon(Icons.speed, color: AppColors.accent),
              const SizedBox(height: 4),
              Text('${motorcycle.currentOdometer} km',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Odometer',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.calendar_today, color: AppColors.accent),
              const SizedBox(height: 4),
              Text('${motorcycle.year}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Year',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          Column(
            children: [
              const Icon(Icons.pin, color: AppColors.accent),
              const SizedBox(height: 4),
              Text(motorcycle.plateNumber ?? '—',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text('Plate',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
