// lib/services/user_repository.dart
// Repositório para gerenciar operações de usuários no banco de dados MySQL
import 'package:mysql1/mysql1.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../models/user.dart' as model;

/// Repositório de usuários com operações CRUD robustas
class UserRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  UserRepository(this._db);

  /// Cria um novo usuário no banco de dados
  /// Retorna o usuário criado ou null em caso de erro
  Future<model.User?> createUser({
    required String name,
    required String email,
    required String passwordHash,
    model.UserRole role = model.UserRole.consumer,
    String? phoneNumber,
  }) async {
    return await _db.usingConnection((conn) async {
      try {
        final id = _uuid.v4();
        await conn.query(
          '''
          INSERT INTO users (id, name, email, password, role, phone_number)
          VALUES (?, ?, ?, ?, ?, ?)
          ''',
          [id, name, email, passwordHash, role.name, phoneNumber],
        );

        return await getUserById(id);
      } catch (e) {
        print('❌ Erro ao criar usuário: $e');
        return null;
      }
    });
  }

  /// Busca usuário por ID
  Future<model.User?> getUserById(String id) async {
    return await _db.usingConnection((conn) async {
      try {
        final results = await conn.query(
          'SELECT * FROM users WHERE id = ? AND deleted_at IS NULL',
          [id],
        );

        if (results.isEmpty) return null;
        return _mapToModel(results.first);
      } catch (e) {
        print('❌ Erro ao buscar usuário por ID: $e');
        return null;
      }
    });
  }

  /// Busca usuário por email
  Future<model.User?> getUserByEmail(String email) async {
    return await _db.usingConnection((conn) async {
      try {
        final results = await conn.query(
          'SELECT * FROM users WHERE email = ? AND deleted_at IS NULL',
          [email],
        );

        if (results.isEmpty) return null;
        return _mapToModel(results.first);
      } catch (e) {
        print('❌ Erro ao buscar usuário por email: $e');
        return null;
      }
    });
  }

  /// Lista todos os usuários ativos (não deletados)
  Future<List<model.User>> getAllUsers({
    int? limit,
    int? offset,
  }) async {
    return await _db.usingConnection((conn) async {
      try {
        var query = 'SELECT * FROM users WHERE deleted_at IS NULL ORDER BY name ASC';
        final params = <dynamic>[];

        if (limit != null) {
          query += ' LIMIT ?';
          params.add(limit);

          if (offset != null) {
            query += ' OFFSET ?';
            params.add(offset);
          }
        }

        final results = await conn.query(query, params);
        return results.map(_mapToModel).toList();
      } catch (e) {
        print('❌ Erro ao listar usuários: $e');
        return [];
      }
    });
  }

  /// Atualiza informações do usuário
  Future<model.User?> updateUser(
    String id, {
    String? name,
    String? email,
    String? passwordHash,
    model.UserRole? role,
    model.UserStatus? status,
    String? phoneNumber,
    String? profileImageUrl,
  }) async {
    return await _db.usingConnection((conn) async {
      try {
        final updates = <String>[];
        final params = <dynamic>[];
      if (name != null) {
        updates.add('name = ?');
        params.add(name);
      }
      if (email != null) {
        updates.add('email = ?');
        params.add(email);
      }
      if (passwordHash != null) {
        updates.add('password = ?');
        params.add(passwordHash);
      }
      if (role != null) {
        updates.add('role = ?');
        params.add(role.name);
      }
      if (status != null) {
        updates.add('status = ?');
        params.add(status.name);
      }
      if (phoneNumber != null) {
        updates.add('phone_number = ?');
        params.add(phoneNumber);
      }
      if (profileImageUrl != null) {
        updates.add('profile_image_url = ?');
        params.add(profileImageUrl);
      }

        if (updates.isEmpty) return await getUserById(id);

        params.add(id);

        await conn.query(
          'UPDATE users SET ${updates.join(', ')} WHERE id = ?',
          params,
        );

        return await getUserById(id);
      } catch (e) {
        print('❌ Erro ao atualizar usuário: $e');
        return null;
      }
    });
  }

  /// Soft delete: marca usuário como deletado sem removê-lo fisicamente
  Future<bool> deleteUser(String id) async {
    return await _db.usingConnection((conn) async {
      try {
        await conn.query('UPDATE users SET deleted_at = NOW() WHERE id = ?', [id]);
        return true;
      } catch (e) {
        print('❌ Erro ao deletar usuário: $e');
        return false;
      }
    });
  }

  /// Hard delete: remove usuário permanentemente do banco
  Future<bool> permanentlyDeleteUser(String id) async {
    return await _db.usingConnection((conn) async {
      try {
        await conn.query('DELETE FROM users WHERE id = ?', [id]);
        return true;
      } catch (e) {
        print('❌ Erro ao deletar usuário permanentemente: $e');
        return false;
      }
    });
  }

  /// Registra login bem-sucedido
  Future<void> recordSuccessfulLogin(String id) async {
    await _db.usingConnection((conn) async {
      try {
        await conn.query(
          '''
          UPDATE users 
          SET last_login_at = NOW(), 
              failed_login_attempts = 0, 
              locked_until = NULL 
          WHERE id = ?
          ''',
          [id],
        );
      } catch (e) {
        print('❌ Erro ao registrar login: $e');
      }
      return null;
    });
  }

  /// Registra tentativa de login falhada
  Future<void> recordFailedLogin(String id) async {
    try {
      final user = await getUserById(id);
      if (user == null) return;

      await _db.usingConnection((conn) async {
        final newAttempts = user.failedLoginAttempts + 1;

        // Bloqueia por 15 minutos após 5 tentativas falhadas
        if (newAttempts >= 5) {
          await conn.query(
            '''
            UPDATE users 
            SET failed_login_attempts = ?, 
                locked_until = DATE_ADD(NOW(), INTERVAL 15 MINUTE)
            WHERE id = ?
            ''',
            [newAttempts, id],
          );
        } else {
          await conn.query('UPDATE users SET failed_login_attempts = ? WHERE id = ?', [newAttempts, id]);
        }
        return null;
      });
    } catch (e) {
      print('❌ Erro ao registrar falha no login: $e');
    }
  }

  /// Verifica se email já está em uso
  Future<bool> emailExists(String email, {String? excludeUserId}) async {
    return await _db.usingConnection((conn) async {
      try {
        var query = 'SELECT id FROM users WHERE email = ? AND deleted_at IS NULL';
        final params = [email];

        if (excludeUserId != null) {
          query += ' AND id != ?';
          params.add(excludeUserId);
        }

        final results = await conn.query(query, params);
        return results.isNotEmpty;
      } catch (e) {
        print('❌ Erro ao verificar email: $e');
        return false;
      }
    });
  }

  /// Conta total de usuários ativos
  Future<int> countUsers() async {
    return await _db.usingConnection((conn) async {
      try {
        final results = await conn.query('SELECT COUNT(*) as total FROM users WHERE deleted_at IS NULL');
        return results.first['total'] as int;
      } catch (e) {
        print('❌ Erro ao contar usuários: $e');
        return 0;
      }
    });
  }

  /// Mapeia resultado do banco para modelo de domínio
  model.User _mapToModel(ResultRow row) {
    return model.User(
      id: row['id'] as String,
      name: row['name'] as String,
      email: row['email'] as String,
      password: row['password'] as String,
      role: model.UserRole.fromString(row['role'] as String),
      status: model.UserStatus.fromString(row['status'] as String),
      createdAt: row['created_at'] as DateTime,
      updatedAt: row['updated_at'] as DateTime,
      deletedAt: row['deleted_at'] as DateTime?,
      lastLoginAt: row['last_login_at'] as DateTime?,
      failedLoginAttempts: row['failed_login_attempts'] as int,
      lockedUntil: row['locked_until'] as DateTime?,
      phoneNumber: row['phone_number'] as String?,
      profileImageUrl: row['profile_image_url'] as String?,
    );
  }
}
