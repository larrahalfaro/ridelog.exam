/// A maintenance rule defines how often a service type should recur.
/// Global defaults live in ServiceType; this table lets a user override
/// per motorcycle if they want (e.g. a heavily-used bike needs oil changes
/// more often than the default).
class MaintenanceRule {
  final int? id;
  final int? motorcycleId; // null = global default, not used to override
  final String serviceType;
  final int intervalKm;
  final int intervalMonths;

  MaintenanceRule({
    this.id,
    this.motorcycleId,
    required this.serviceType,
    required this.intervalKm,
    required this.intervalMonths,
  });

  Map<String, dynamic> toMap() {
    return {
      'rule_id': id,
      'motorcycle_id': motorcycleId,
      'service_type': serviceType,
      'interval_km': intervalKm,
      'interval_months': intervalMonths,
    };
  }

  factory MaintenanceRule.fromMap(Map<String, dynamic> map) {
    return MaintenanceRule(
      id: map['rule_id'] as int?,
      motorcycleId: map['motorcycle_id'] as int?,
      serviceType: map['service_type'] as String,
      intervalKm: map['interval_km'] as int,
      intervalMonths: map['interval_months'] as int,
    );
  }
}

enum ReminderStatus { ok, upcoming, overdue }

/// Computed on the fly (not stored) — this is the result of comparing
/// a motorcycle's last service of a given type against its rule.
class ReminderInfo {
  final String serviceType;
  final int? lastServiceOdometer;
  final String? lastServiceDate;
  final int dueAtOdometer;
  final DateTime? dueByDate;
  final int kmRemaining;
  final int? daysRemaining;
  final ReminderStatus status;

  ReminderInfo({
    required this.serviceType,
    required this.lastServiceOdometer,
    required this.lastServiceDate,
    required this.dueAtOdometer,
    required this.dueByDate,
    required this.kmRemaining,
    required this.daysRemaining,
    required this.status,
  });
}
