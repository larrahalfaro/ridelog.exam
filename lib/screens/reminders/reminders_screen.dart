import 'package:flutter/material.dart';

import '../../db/database_helper.dart';
import '../../models/motorcycle.dart';
import '../../models/reminder.dart';
import '../../models/user.dart';
import '../../utils/constants.dart';
import '../../utils/reminder_logic.dart';
import '../../widgets/status_badge.dart';

class RemindersScreen extends StatefulWidget {
  final AppUser user;
  const RemindersScreen({super.key, required this.user});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  // Each entry pairs a bike with its computed reminder list, flattened for display.
  final List<_ReminderRow> _rows = [];
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
      final db = DatabaseHelper.instance;
      final bikes = await db.getMotorcyclesForUser(widget.user.id!);
      final rows = <_ReminderRow>[];

      for (final bike in bikes) {
        final reminders = await ReminderEngine.computeForMotorcycle(bike);
        for (final r in reminders) {
          rows.add(_ReminderRow(bike: bike, reminder: r));
        }
      }

      rows.sort((a, b) => a.reminder.status.index.compareTo(b.reminder.status.index));

      if (!mounted) return;
      setState(() {
        _rows.clear();
        _rows.addAll(rows);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load reminders: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reminders')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
            ? _buildErrorState()
          : _rows.isEmpty
              ? const Center(
                  child: Text('No reminders yet. Add a motorcycle first.',
                      style: TextStyle(color: AppColors.textSecondary)),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  color: AppColors.accent,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _rows.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _buildRow(_rows[i]),
                  ),
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

  Widget _buildRow(_ReminderRow row) {
    final type = ServiceType.fromKey(row.reminder.serviceType);
    final bike = row.bike;
    final r = row.reminder;

    // Baseline for the progress bar is the last service odometer (or 0).
    final startKm = r.lastServiceOdometer ?? 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(type.icon, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.label,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(bike.displayName,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                StatusBadge(status: r.status),
              ],
            ),
            const SizedBox(height: 12),
            KmProgressBar(
              currentKm: bike.currentOdometer,
              targetKm: r.dueAtOdometer,
              startKm: startKm,
            ),
            if (r.daysRemaining != null) ...[
              const SizedBox(height: 6),
              Text(
                r.daysRemaining! > 0
                    ? 'Also due within ${r.daysRemaining} days'
                    : 'Also overdue by ${-r.daysRemaining!} days',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReminderRow {
  final Motorcycle bike;
  final ReminderInfo reminder;
  _ReminderRow({required this.bike, required this.reminder});
}
