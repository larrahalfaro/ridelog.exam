import 'package:flutter/material.dart';

import '../models/reminder.dart';
import '../utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final ReminderStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    late Color color;
    late String label;
    switch (status) {
      case ReminderStatus.overdue:
        color = AppColors.danger;
        label = 'OVERDUE';
        break;
      case ReminderStatus.upcoming:
        color = AppColors.accent;
        label = 'DUE SOON';
        break;
      case ReminderStatus.ok:
        color = AppColors.success;
        label = 'OK';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// A horizontal progress bar showing "1,800 / 3,000 km until next service" —
/// this is the "wow factor" progress indicator called out in the UX notes.
class KmProgressBar extends StatelessWidget {
  final int currentKm;
  final int targetKm;
  final int startKm;

  const KmProgressBar({
    super.key,
    required this.currentKm,
    required this.targetKm,
    required this.startKm,
  });

  @override
  Widget build(BuildContext context) {
    final total = (targetKm - startKm).clamp(1, double.infinity);
    final done = (currentKm - startKm).clamp(0, total);
    final ratio = (done / total).clamp(0.0, 1.0);
    final remaining = (targetKm - currentKm);

    Color barColor;
    if (remaining <= 0) {
      barColor = AppColors.danger;
    } else if (remaining <= 300) {
      barColor = AppColors.accent;
    } else {
      barColor = AppColors.success;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation(barColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          remaining > 0
              ? '$remaining km remaining (due at $targetKm km)'
              : 'Overdue by ${-remaining} km (was due at $targetKm km)',
          style: TextStyle(fontSize: 12, color: barColor),
        ),
      ],
    );
  }
}
