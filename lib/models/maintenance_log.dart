class MaintenanceLog {
  final int? id;
  final int motorcycleId;
  final String serviceType; // matches ServiceType.key
  final String serviceDate; // ISO 8601 date string
  final int odometerAtService;
  final double cost;
  final String? shopName;
  final String? notes;
  final String createdAt;

  MaintenanceLog({
    this.id,
    required this.motorcycleId,
    required this.serviceType,
    required this.serviceDate,
    required this.odometerAtService,
    required this.cost,
    this.shopName,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'maintenance_id': id,
      'motorcycle_id': motorcycleId,
      'service_type': serviceType,
      'service_date': serviceDate,
      'odometer_at_service': odometerAtService,
      'cost': cost,
      'shop_name': shopName,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory MaintenanceLog.fromMap(Map<String, dynamic> map) {
    return MaintenanceLog(
      id: map['maintenance_id'] as int?,
      motorcycleId: map['motorcycle_id'] as int,
      serviceType: map['service_type'] as String,
      serviceDate: map['service_date'] as String,
      odometerAtService: map['odometer_at_service'] as int,
      cost: (map['cost'] as num).toDouble(),
      shopName: map['shop_name'] as String?,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
