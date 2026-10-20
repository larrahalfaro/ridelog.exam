class FuelLog {
  final int? id;
  final int motorcycleId;
  final String fillDate; // ISO 8601 date string
  final double liters;
  final double cost;
  final int odometerAtFill;
  final bool isFullTank;
  final String createdAt;

  FuelLog({
    this.id,
    required this.motorcycleId,
    required this.fillDate,
    required this.liters,
    required this.cost,
    required this.odometerAtFill,
    required this.isFullTank,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'fuel_id': id,
      'motorcycle_id': motorcycleId,
      'fill_date': fillDate,
      'liters': liters,
      'cost': cost,
      'odometer_at_fill': odometerAtFill,
      'is_full_tank': isFullTank ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory FuelLog.fromMap(Map<String, dynamic> map) {
    return FuelLog(
      id: map['fuel_id'] as int?,
      motorcycleId: map['motorcycle_id'] as int,
      fillDate: map['fill_date'] as String,
      liters: (map['liters'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
      odometerAtFill: map['odometer_at_fill'] as int,
      isFullTank: (map['is_full_tank'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }
}
