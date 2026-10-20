import '../db/database_helper.dart';
import '../models/motorcycle.dart';
import '../models/reminder.dart';
import 'constants.dart';

/// Computes "next due" reminders for a motorcycle by comparing the most
/// recent maintenance log of each service type against that service's
/// interval rule. Due = last service + interval, whichever (km or time)
/// comes first — the same logic explained in the project spec doc.
class ReminderEngine {
  static Future<List<ReminderInfo>> computeForMotorcycle(
      Motorcycle bike) async {
    final db = DatabaseHelper.instance;
    final logs = await db.getMaintenanceLogs(bike.id!);
    final results = <ReminderInfo>[];

    for (final type in ServiceType.all) {
      if (type.key == ServiceType.other.key) continue; // "other" has no interval

      final rule = await db.getEffectiveRule(bike.id!, type.key);
      if (rule.intervalKm == 0 && rule.intervalMonths == 0) continue;

      // Most recent log of this service type (logs are already sorted DESC).
      final matching = logs.where((l) => l.serviceType == type.key).toList();
      final last = matching.isNotEmpty ? matching.first : null;

      final lastOdometer = last?.odometerAtService;
      final lastDateStr = last?.serviceDate;
      final lastDate = lastDateStr != null ? DateTime.tryParse(lastDateStr) : null;

      // If there's no history yet, treat "last" as 0 km / bike creation date
      // so a first reminder still shows up (encourages logging initial state).
      final baselineOdometer = lastOdometer ?? 0;
      final baselineDate = lastDate ?? DateTime.tryParse(bike.createdAt) ?? DateTime.now();

      final dueAtOdometer = baselineOdometer + rule.intervalKm;
      final dueByDate = rule.intervalMonths > 0
          ? DateTime(baselineDate.year, baselineDate.month + rule.intervalMonths,
              baselineDate.day)
          : null;

      final kmRemaining = dueAtOdometer - bike.currentOdometer;
      final daysRemaining =
          dueByDate != null ? dueByDate.difference(DateTime.now()).inDays : null;

      // Overdue if either the km or time threshold has been crossed.
      final isOverdueByKm = rule.intervalKm > 0 && kmRemaining <= 0;
      final isOverdueByDate = daysRemaining != null && daysRemaining <= 0;
      final isUpcomingByKm =
          rule.intervalKm > 0 && kmRemaining > 0 && kmRemaining <= 300;
      final isUpcomingByDate =
          daysRemaining != null && daysRemaining > 0 && daysRemaining <= 14;

      ReminderStatus status;
      if (isOverdueByKm || isOverdueByDate) {
        status = ReminderStatus.overdue;
      } else if (isUpcomingByKm || isUpcomingByDate) {
        status = ReminderStatus.upcoming;
      } else {
        status = ReminderStatus.ok;
      }

      results.add(ReminderInfo(
        serviceType: type.key,
        lastServiceOdometer: lastOdometer,
        lastServiceDate: lastDateStr,
        dueAtOdometer: dueAtOdometer,
        dueByDate: dueByDate,
        kmRemaining: kmRemaining,
        daysRemaining: daysRemaining,
        status: status,
      ));
    }

    // Sort: overdue first, then upcoming, then ok.
    results.sort((a, b) => a.status.index.compareTo(b.status.index));
    return results;
  }
}
