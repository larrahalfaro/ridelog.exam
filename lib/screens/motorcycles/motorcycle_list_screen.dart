import 'package:flutter/material.dart';

import '../../db/database_helper.dart';
import '../../models/motorcycle.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import 'add_edit_motorcycle_screen.dart';
import 'motorcycle_detail_screen.dart';

class MotorcycleListScreen extends StatefulWidget {
  final AppUser user;
  const MotorcycleListScreen({super.key, required this.user});

  @override
  State<MotorcycleListScreen> createState() => _MotorcycleListScreenState();
}

class _MotorcycleListScreenState extends State<MotorcycleListScreen> {
  List<Motorcycle> _bikes = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bikes = await DatabaseHelper.instance
          .getMotorcyclesForUser(widget.user.id!);
      if (!mounted) return;
      setState(() {
        _bikes = bikes;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load motorcycles: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Motorcycles')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AddEditMotorcycleScreen(user: widget.user),
          ));
          _load();
        },
        child: const Icon(Icons.add),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
            ? _buildErrorState()
          : _bikes.isEmpty
              ? const Center(
                  child: Text('No motorcycles yet. Tap + to add one.',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bikes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final bike = _bikes[i];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.surfaceLight,
                          child: Icon(Icons.two_wheeler, color: AppColors.accent),
                        ),
                        title: Text(bike.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${bike.currentOdometer} km${bike.plateNumber != null ? " • ${bike.plateNumber}" : ""}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => MotorcycleDetailScreen(
                                user: widget.user, motorcycle: bike),
                          ));
                          _load();
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
