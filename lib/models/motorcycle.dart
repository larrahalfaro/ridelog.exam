class Motorcycle {
  final int? id;
  final int userId;
  final String brand;
  final String model;
  final int year;
  final String? plateNumber;
  final int currentOdometer;
  final String? photoPath;
  final String createdAt;

  Motorcycle({
    this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    this.plateNumber,
    required this.currentOdometer,
    this.photoPath,
    required this.createdAt,
  });

  String get displayName => '$brand $model ($year)';

  Map<String, dynamic> toMap() {
    return {
      'motorcycle_id': id,
      'user_id': userId,
      'brand': brand,
      'model': model,
      'year': year,
      'plate_number': plateNumber,
      'current_odometer': currentOdometer,
      'photo_path': photoPath,
      'created_at': createdAt,
    };
  }

  factory Motorcycle.fromMap(Map<String, dynamic> map) {
    return Motorcycle(
      id: map['motorcycle_id'] as int?,
      userId: map['user_id'] as int,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      plateNumber: map['plate_number'] as String?,
      currentOdometer: map['current_odometer'] as int,
      photoPath: map['photo_path'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Motorcycle copyWith({
    String? brand,
    String? model,
    int? year,
    String? plateNumber,
    int? currentOdometer,
    String? photoPath,
  }) {
    return Motorcycle(
      id: id,
      userId: userId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      plateNumber: plateNumber ?? this.plateNumber,
      currentOdometer: currentOdometer ?? this.currentOdometer,
      photoPath: photoPath ?? this.photoPath,
      createdAt: createdAt,
    );
  }
}
