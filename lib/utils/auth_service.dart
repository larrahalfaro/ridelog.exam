import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../models/user.dart';

/// Handles registration, login, and "who's currently logged in" session
/// state. Passwords are hashed with SHA-256 + a static salt before storage —
/// good enough to demonstrate the concept in a student project. A real
/// production app should use bcrypt/argon2 with a per-user salt instead.
class AuthService {
  static const _sessionKey = 'ridelog_session_user_id';
  static const _salt = 'ridelog_static_salt_v1';

  static String _hashPassword(String plainPassword) {
    final bytes = utf8.encode(_salt + plainPassword);
    return sha256.convert(bytes).toString();
  }

  static Future<AppUser?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final db = DatabaseHelper.instance;
    final existing = await db.getUserByEmail(email.trim().toLowerCase());
    if (existing != null) {
      throw Exception('An account with this email already exists.');
    }

    final user = AppUser(
      name: name.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now().toIso8601String(),
    );
    final id = await db.createUser(user);
    final created = await db.getUserById(id);
    if (created != null) await _saveSession(created.id!);
    return created;
  }

  static Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final db = DatabaseHelper.instance;
    final user = await db.getUserByEmail(email.trim().toLowerCase());
    if (user == null) {
      throw Exception('No account found with this email.');
    }
    if (user.passwordHash != _hashPassword(password)) {
      throw Exception('Incorrect password.');
    }
    await _saveSession(user.id!);
    return user;
  }

  static Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_sessionKey, userId);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  /// Returns the currently logged-in user, or null if no session exists.
  static Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_sessionKey);
    if (id == null) return null;
    return DatabaseHelper.instance.getUserById(id);
  }
}
