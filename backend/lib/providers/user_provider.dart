// lib/providers/user_provider.dart
// Provedor de dados para usuários (PLACEHOLDER - arquivo JSON)
// Em produção, substitua por conexão com banco de dados real

import 'dart:io';
import 'package:mysql1/mysql1.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/password_service.dart';

/// Provedor de usuários baseado em banco de dados MySQL.
/// Remove dependência de arquivo local `data/users.json`.
class UserProvider {
  MySqlConnection? _conn;
  List<User> _users = [];

  List<User> get users => List.unmodifiable(_users);

  Future<void> initialize() async {
    try {
      final env = Platform.environment;
      final dbHost = env['DB_HOST'] ?? env['DB_HOSTNAME'];
      if (dbHost == null || dbHost.isEmpty) {
        throw Exception('DB_HOST não configurado. Configure variáveis de ambiente para o banco de dados.');
      }

      final settings = ConnectionSettings(
        host: dbHost,
        port: int.tryParse(env['DB_PORT'] ?? '3306') ?? 3306,
        user: env['DB_USER'] ?? env['DB_USERNAME'] ?? 'root',
        password: env['DB_PASSWORD'] ?? env['DB_PASS'] ?? '',
        db: env['DB_NAME'] ?? env['DB_DATABASE'] ?? 'gdav_veterinario',
      );

      _conn = await MySqlConnection.connect(settings);

      final results = await _conn!.query('SELECT id, name, email, password, role, status, created_at, updated_at, deleted_at, last_login_at, failed_login_attempts, locked_until, phone_number, profile_image_url FROM users WHERE deleted_at IS NULL');

      _users = results.map((r) {
        return User(
          id: r['id']?.toString() ?? '',
          name: r['name']?.toString() ?? '',
          email: r['email']?.toString() ?? '',
          password: r['password']?.toString() ?? '',
          role: UserRole.fromString(r['role']?.toString() ?? 'consumer'),
          status: UserStatus.fromString(r['status']?.toString() ?? 'active'),
          createdAt: r['created_at'] != null ? DateTime.parse(r['created_at'].toString()) : DateTime.now(),
          updatedAt: r['updated_at'] != null ? DateTime.parse(r['updated_at'].toString()) : DateTime.now(),
          deletedAt: r['deleted_at'] != null ? DateTime.parse(r['deleted_at'].toString()) : null,
          lastLoginAt: r['last_login_at'] != null ? DateTime.parse(r['last_login_at'].toString()) : null,
          failedLoginAttempts: r['failed_login_attempts'] as int? ?? 0,
          lockedUntil: r['locked_until'] != null ? DateTime.parse(r['locked_until'].toString()) : null,
          phoneNumber: r['phone_number']?.toString(),
          profileImageUrl: r['profile_image_url']?.toString(),
        );
      }).toList();

      print('✅ ${_users.length} usuários carregados do banco de dados');
    } catch (e) {
      print('❌ Erro ao inicializar UserProvider: $e');
      rethrow;
    }
  }

  Future<User> createUser({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.consumer,
  }) async {
    if (_conn == null) throw Exception('Conexão com DB não inicializada');

    final existing = await _conn!.query('SELECT id FROM users WHERE email = ? AND deleted_at IS NULL', [email]);
    if (existing.isNotEmpty) throw Exception('Email já está em uso');

    final passwordError = PasswordService.validatePassword(password);
    if (passwordError != null) throw Exception(passwordError);

    final id = Uuid().v4();
    final hashedPassword = PasswordService.hashPassword(password);

    await _conn!.query('''
      INSERT INTO users (id, name, email, password, role, status, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW())
    ''', [id, name, email, hashedPassword, role.toJson(), UserStatus.active.toJson()]);

    final user = User(
      id: id,
      name: name,
      email: email,
      password: hashedPassword,
      role: role,
    );

    _users.add(user);
    print('✅ Usuário criado: ${user.email}');
    return user;
  }

  Future<User?> validateCredentials(String email, String password) async {
    if (_conn == null) throw Exception('Conexão com DB não inicializada');

    final results = await _conn!.query('SELECT id, name, email, password, role, status, created_at, updated_at FROM users WHERE email = ? AND deleted_at IS NULL', [email]);
    if (results.isEmpty) return null;
    final r = results.first;

    final hashed = r['password']?.toString() ?? '';
    if (!PasswordService.verifyPassword(password, hashed)) return null;

    return User(
      id: r['id']?.toString() ?? '',
      name: r['name']?.toString() ?? '',
      email: r['email']?.toString() ?? '',
      password: hashed,
      role: UserRole.fromString(r['role']?.toString() ?? 'consumer'),
      createdAt: r['created_at'] != null ? DateTime.parse(r['created_at'].toString()) : DateTime.now(),
      updatedAt: r['updated_at'] != null ? DateTime.parse(r['updated_at'].toString()) : DateTime.now(),
    );
  }

  Future<bool> updateUser(String id, User updatedUser) async {
    if (_conn == null) throw Exception('Conexão com DB não inicializada');

    await _conn!.query('''
      UPDATE users SET name = ?, email = ?, password = ?, role = ?, status = ?, updated_at = NOW() WHERE id = ?
    ''', [updatedUser.name, updatedUser.email, updatedUser.password, updatedUser.role.toJson(), updatedUser.status.toJson(), id]);

    final index = _users.indexWhere((u) => u.id == id);
    if (index != -1) {
      _users[index] = updatedUser;
      return true;
    }
    return false;
  }

  Future<bool> deleteUser(String id) async {
    if (_conn == null) throw Exception('Conexão com DB não inicializada');

    await _conn!.query('UPDATE users SET deleted_at = NOW() WHERE id = ?', [id]);
    final initialLength = _users.length;
    _users.removeWhere((u) => u.id == id);
    return _users.length < initialLength;
  }

  Map<String, dynamic> getStats() {
    final consumerCount = _users.where((u) => !u.isAdmin).length;
    final adminCount = _users.where((u) => u.isAdmin).length;

    return {
      'total': _users.length,
      'consumers': consumerCount,
      'administrators': adminCount,
    };
  }
}
