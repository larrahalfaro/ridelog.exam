import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/user.dart';
import '../models/motorcycle.dart';
import '../models/maintenance_log.dart';
import '../models/fuel_log.dart';
import '../models/reminder.dart';
import '../utils/constants.dart';

/// Singleton wrapper around sqflite. All CRUD for the app goes through here.
/// Schema mirrors the ER design in the project spec:
/// users, motorcycles, maintenance_logs, fuel_logs, maintenance_rules.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;
  Future<Database>? _dbOpening;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _dbOpening ??= _initDb();
    try {
      _db = await _dbOpening!;
    } catch (_) {
      _dbOpening = null;
      rethrow;
    }
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'ridelog.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createSchema,
    );
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        preferred_unit TEXT NOT NULL DEFAULT 'km',
        preferred_currency TEXT NOT NULL DEFAULT 'PHP',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE motorcycles (
        motorcycle_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year INTEGER NOT NULL,
        plate_number TEXT,
        current_odometer INTEGER NOT NULL DEFAULT 0,
        photo_path TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (user_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_logs (
        maintenance_id INTEGER PRIMARY KEY AUTOINCREMENT,
        motorcycle_id INTEGER NOT NULL,
        service_type TEXT NOT NULL,
        service_date TEXT NOT NULL,
        odometer_at_service INTEGER NOT NULL,
        cost REAL NOT NULL DEFAULT 0,
        shop_name TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (motorcycle_id) REFERENCES motorcycles (motorcycle_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE fuel_logs (
        fuel_id INTEGER PRIMARY KEY AUTOINCREMENT,
        motorcycle_id INTEGER NOT NULL,
        fill_date TEXT NOT NULL,
        liters REAL NOT NULL,
        cost REAL NOT NULL,
        odometer_at_fill INTEGER NOT NULL,
        is_full_tank INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        FOREIGN KEY (motorcycle_id) REFERENCES motorcycles (motorcycle_id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE maintenance_rules (
        rule_id INTEGER PRIMARY KEY AUTOINCREMENT,
        motorcycle_id INTEGER,
        service_type TEXT NOT NULL,
        interval_km INTEGER NOT NULL,
        interval_months INTEGER NOT NULL,
        FOREIGN KEY (motorcycle_id) REFERENCES motorcycles (motorcycle_id) ON DELETE CASCADE
      )
    ''');
  }

  // ---------------- USERS ----------------

  Future<int> createUser(AppUser user) async {
    final db = await database;
    return db.insert('users', user.toMap()..remove('user_id'));
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final db = await database;
    final rows =
        await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<AppUser?> getUserById(int id) async {
    final db = await database;
    final rows =
        await db.query('users', where: 'user_id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }

  Future<int> updateUser(AppUser user) async {
    final db = await database;
    return db.update('users', user.toMap(),
        where: 'user_id = ?', whereArgs: [user.id]);
  }

  // ---------------- MOTORCYCLES ----------------

  Future<int> createMotorcycle(Motorcycle m) async {
    final db = await database;
    return db.insert('motorcycles', m.toMap()..remove('motorcycle_id'));
  }

  Future<List<Motorcycle>> getMotorcyclesForUser(int userId) async {
    final db = await database;
    final rows = await db.query('motorcycles',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    return rows.map((r) => Motorcycle.fromMap(r)).toList();
  }

  Future<Motorcycle?> getMotorcycle(int id) async {
    final db = await database;
    final rows = await db
        .query('motorcycles', where: 'motorcycle_id = ?', whereArgs: [id]);
    if (rows.isEmpty) return null;
    return Motorcycle.fromMap(rows.first);
  }

  Future<int> updateMotorcycle(Motorcycle m) async {
    final db = await database;
    return db.update('motorcycles', m.toMap(),
        where: 'motorcycle_id = ?', whereArgs: [m.id]);
  }

  Future<int> deleteMotorcycle(int id) async {
    final db = await database;
    return db.delete('motorcycles',
        where: 'motorcycle_id = ?', whereArgs: [id]);
  }

  /// Updates the bike's odometer only if the new value is higher — keeps
  /// current_odometer as a reliable "latest known reading" across all logs.
  Future<void> bumpOdometerIfHigher(int motorcycleId, int newReading) async {
    final bike = await getMotorcycle(motorcycleId);
    if (bike != null && newReading > bike.currentOdometer) {
      await updateMotorcycle(bike.copyWith(currentOdometer: newReading));
    }
  }

  // ---------------- MAINTENANCE LOGS ----------------

  Future<int> createMaintenanceLog(MaintenanceLog log) async {
    final db = await database;
    final id =
        await db.insert('maintenance_logs', log.toMap()..remove('maintenance_id'));
    await bumpOdometerIfHigher(log.motorcycleId, log.odometerAtService);
    return id;
  }

  Future<List<MaintenanceLog>> getMaintenanceLogs(int motorcycleId) async {
    final db = await database;
    final rows = await db.query('maintenance_logs',
        where: 'motorcycle_id = ?',
        whereArgs: [motorcycleId],
        orderBy: 'service_date DESC');
    return rows.map((r) => MaintenanceLog.fromMap(r)).toList();
  }

  Future<int> updateMaintenanceLog(MaintenanceLog log) async {
    final db = await database;
    await bumpOdometerIfHigher(log.motorcycleId, log.odometerAtService);
    return db.update('maintenance_logs', log.toMap(),
        where: 'maintenance_id = ?', whereArgs: [log.id]);
  }

  Future<int> deleteMaintenanceLog(int id) async {
    final db = await database;
    return db.delete('maintenance_logs',
        where: 'maintenance_id = ?', whereArgs: [id]);
  }

  // ---------------- FUEL LOGS ----------------

  Future<int> createFuelLog(FuelLog log) async {
    final db = await database;
    final id = await db.insert('fuel_logs', log.toMap()..remove('fuel_id'));
    await bumpOdometerIfHigher(log.motorcycleId, log.odometerAtFill);
    return id;
  }

  Future<List<FuelLog>> getFuelLogs(int motorcycleId) async {
    final db = await database;
    final rows = await db.query('fuel_logs',
        where: 'motorcycle_id = ?',
        whereArgs: [motorcycleId],
        orderBy: 'fill_date DESC');
    return rows.map((r) => FuelLog.fromMap(r)).toList();
  }

  Future<int> updateFuelLog(FuelLog log) async {
    final db = await database;
    await bumpOdometerIfHigher(log.motorcycleId, log.odometerAtFill);
    return db.update('fuel_logs', log.toMap(),
        where: 'fuel_id = ?', whereArgs: [log.id]);
  }

  Future<int> deleteFuelLog(int id) async {
    final db = await database;
    return db.delete('fuel_logs', where: 'fuel_id = ?', whereArgs: [id]);
  }

  // ---------------- MAINTENANCE RULES ----------------

  /// Returns the effective interval for a service type on a given bike:
  /// a per-bike override if one exists, otherwise the global ServiceType default.
  Future<MaintenanceRule> getEffectiveRule(
      int motorcycleId, String serviceTypeKey) async {
    final db = await database;
    final rows = await db.query(
      'maintenance_rules',
      where: 'motorcycle_id = ? AND service_type = ?',
      whereArgs: [motorcycleId, serviceTypeKey],
    );
    if (rows.isNotEmpty) return MaintenanceRule.fromMap(rows.first);

    final defaultType = ServiceType.fromKey(serviceTypeKey);
    return MaintenanceRule(
      motorcycleId: null,
      serviceType: serviceTypeKey,
      intervalKm: defaultType.defaultIntervalKm,
      intervalMonths: defaultType.defaultIntervalMonths,
    );
  }

  Future<void> setRuleOverride(MaintenanceRule rule) async {
    final db = await database;
    final existing = await db.query(
      'maintenance_rules',
      where: 'motorcycle_id = ? AND service_type = ?',
      whereArgs: [rule.motorcycleId, rule.serviceType],
    );
    if (existing.isNotEmpty) {
      await db.update(
        'maintenance_rules',
        rule.toMap()..remove('rule_id'),
        where: 'rule_id = ?',
        whereArgs: [existing.first['rule_id']],
      );
    } else {
      await db.insert('maintenance_rules', rule.toMap()..remove('rule_id'));
    }
  }

  // ---------------- AGGREGATES (for Reports) ----------------

  Future<double> totalMaintenanceCost(int motorcycleId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COALESCE(SUM(cost), 0) as total FROM maintenance_logs WHERE motorcycle_id = ?',
        [motorcycleId]);
    return (result.first['total'] as num).toDouble();
  }

  Future<double> totalFuelCost(int motorcycleId) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COALESCE(SUM(cost), 0) as total FROM fuel_logs WHERE motorcycle_id = ?',
        [motorcycleId]);
    return (result.first['total'] as num).toDouble();
  }
}
