class AppUser {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String preferredUnit; // 'km' or 'mi'
  final String preferredCurrency; // e.g. 'PHP'
  final String createdAt;

  AppUser({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.preferredUnit = 'km',
    this.preferredCurrency = 'PHP',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'user_id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'preferred_unit': preferredUnit,
      'preferred_currency': preferredCurrency,
      'created_at': createdAt,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['user_id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      preferredUnit: map['preferred_unit'] as String? ?? 'km',
      preferredCurrency: map['preferred_currency'] as String? ?? 'PHP',
      createdAt: map['created_at'] as String,
    );
  }

  AppUser copyWith({
    String? name,
    String? preferredUnit,
    String? preferredCurrency,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email,
      passwordHash: passwordHash,
      preferredUnit: preferredUnit ?? this.preferredUnit,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      createdAt: createdAt,
    );
  }
}
