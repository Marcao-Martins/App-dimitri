// lib/services/ficha_repository.dart
// Repositório para gerenciar operações de fichas veterinárias no banco de dados MySQL
import 'package:mysql1/mysql1.dart';
import 'package:uuid/uuid.dart';
import '../database/database.dart';
import '../models/ficha.dart';

/// Repositório de fichas com operações CRUD robustas
class FichaRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  FichaRepository(this._db);

  /// Cria uma nova ficha no banco de dados
  /// Retorna a ficha criada ou null em caso de erro
  Future<Ficha?> createFicha({
    required String userId,
    required String animalName,
    required AnimalType animalType,
    required String breed,
    required AnimalSex sex,
    required double weight,
    DateTime? birthDate,
    String? microchipNumber,
    String? ownerName,
    String? ownerPhone,
    String? observations,
  }) async {
    try {
      final id = _uuid.v4();
      final conn = await _db.connection;

      await conn.query(
        '''
        INSERT INTO fichas (
          id, user_id, animal_name, animal_type, breed, sex, weight,
          birth_date, microchip_number, owner_name, owner_phone, observations
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          id,
          userId,
          animalName,
          animalType.name,
          breed,
          sex.name,
          weight,
          birthDate,
          microchipNumber,
          ownerName,
          ownerPhone,
          observations,
        ],
      );

      return await getFichaById(id);
    } catch (e) {
      print('❌ Erro ao criar ficha: $e');
      return null;
    }
  }

  /// Busca ficha por ID
  Future<Ficha?> getFichaById(String id) async {
    try {
      final conn = await _db.connection;
      final results = await conn.query(
        'SELECT * FROM fichas WHERE id = ? AND deleted_at IS NULL',
        [id],
      );

      if (results.isEmpty) return null;
      return _mapToModel(results.first);
    } catch (e) {
      print('❌ Erro ao buscar ficha por ID: $e');
      return null;
    }
  }

  /// Busca todas as fichas de um usuário específico
  Future<List<Ficha>> getFichasByUserId(
    String userId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final conn = await _db.connection;

      var query =
          'SELECT * FROM fichas WHERE user_id = ? AND deleted_at IS NULL ORDER BY created_at DESC';
      final params = <dynamic>[userId];

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
      print('❌ Erro ao buscar fichas do usuário: $e');
      return [];
    }
  }

  /// Busca fichas por tipo de animal
  Future<List<Ficha>> getFichasByAnimalType(
    String userId,
    AnimalType animalType, {
    int? limit,
    int? offset,
  }) async {
    try {
      final conn = await _db.connection;

      var query =
          'SELECT * FROM fichas WHERE user_id = ? AND animal_type = ? AND deleted_at IS NULL ORDER BY created_at DESC';
      final params = <dynamic>[userId, animalType.name];

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
      print('❌ Erro ao buscar fichas por tipo de animal: $e');
      return [];
    }
  }

  /// Busca fichas por nome do animal (busca parcial)
  Future<List<Ficha>> searchFichasByAnimalName(
    String userId,
    String searchTerm, {
    int? limit,
    int? offset,
  }) async {
    try {
      final conn = await _db.connection;

      var query =
          'SELECT * FROM fichas WHERE user_id = ? AND animal_name LIKE ? AND deleted_at IS NULL ORDER BY animal_name ASC';
      final params = <dynamic>[userId, '%$searchTerm%'];

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
      print('❌ Erro ao buscar fichas por nome: $e');
      return [];
    }
  }

  /// Lista todas as fichas (admin)
  Future<List<Ficha>> getAllFichas({
    int? limit,
    int? offset,
  }) async {
    try {
      final conn = await _db.connection;

      var query =
          'SELECT * FROM fichas WHERE deleted_at IS NULL ORDER BY created_at DESC';
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
      print('❌ Erro ao listar fichas: $e');
      return [];
    }
  }

  /// Atualiza informações da ficha
  Future<Ficha?> updateFicha(
    String id, {
    String? animalName,
    AnimalType? animalType,
    String? breed,
    AnimalSex? sex,
    double? weight,
    DateTime? birthDate,
    String? microchipNumber,
    String? ownerName,
    String? ownerPhone,
    String? observations,
  }) async {
    try {
      final conn = await _db.connection;
      final updates = <String>[];
      final params = <dynamic>[];

      if (animalName != null) {
        updates.add('animal_name = ?');
        params.add(animalName);
      }
      if (animalType != null) {
        updates.add('animal_type = ?');
        params.add(animalType.name);
      }
      if (breed != null) {
        updates.add('breed = ?');
        params.add(breed);
      }
      if (sex != null) {
        updates.add('sex = ?');
        params.add(sex.name);
      }
      if (weight != null) {
        updates.add('weight = ?');
        params.add(weight);
      }
      if (birthDate != null) {
        updates.add('birth_date = ?');
        params.add(birthDate);
      }
      if (microchipNumber != null) {
        updates.add('microchip_number = ?');
        params.add(microchipNumber);
      }
      if (ownerName != null) {
        updates.add('owner_name = ?');
        params.add(ownerName);
      }
      if (ownerPhone != null) {
        updates.add('owner_phone = ?');
        params.add(ownerPhone);
      }
      if (observations != null) {
        updates.add('observations = ?');
        params.add(observations);
      }

      if (updates.isEmpty) return await getFichaById(id);

      params.add(id);

      await conn.query(
        'UPDATE fichas SET ${updates.join(', ')} WHERE id = ?',
        params,
      );

      return await getFichaById(id);
    } catch (e) {
      print('❌ Erro ao atualizar ficha: $e');
      return null;
    }
  }

  /// Soft delete: marca ficha como deletada sem removê-la fisicamente
  Future<bool> deleteFicha(String id) async {
    try {
      final conn = await _db.connection;
      await conn.query(
        'UPDATE fichas SET deleted_at = NOW() WHERE id = ?',
        [id],
      );
      return true;
    } catch (e) {
      print('❌ Erro ao deletar ficha: $e');
      return false;
    }
  }

  /// Hard delete: remove ficha permanentemente do banco
  Future<bool> permanentlyDeleteFicha(String id) async {
    try {
      final conn = await _db.connection;
      await conn.query('DELETE FROM fichas WHERE id = ?', [id]);
      return true;
    } catch (e) {
      print('❌ Erro ao deletar ficha permanentemente: $e');
      return false;
    }
  }

  /// Conta total de fichas de um usuário
  Future<int> countFichasByUserId(String userId) async {
    try {
      final conn = await _db.connection;
      final results = await conn.query(
        'SELECT COUNT(*) as total FROM fichas WHERE user_id = ? AND deleted_at IS NULL',
        [userId],
      );
      return results.first['total'] as int;
    } catch (e) {
      print('❌ Erro ao contar fichas: $e');
      return 0;
    }
  }

  /// Conta fichas por tipo de animal
  Future<Map<String, int>> countFichasByAnimalType(String userId) async {
    try {
      final conn = await _db.connection;
      final results = await conn.query(
        '''
        SELECT animal_type, COUNT(*) as total 
        FROM fichas 
        WHERE user_id = ? AND deleted_at IS NULL 
        GROUP BY animal_type
        ''',
        [userId],
      );

      final Map<String, int> counts = {};
      for (final row in results) {
        counts[row['animal_type'] as String] = row['total'] as int;
      }

      return counts;
    } catch (e) {
      print('❌ Erro ao contar fichas por tipo: $e');
      return {};
    }
  }

  /// Verifica se a ficha pertence ao usuário
  Future<bool> fichaBelogsToUser(String fichaId, String userId) async {
    try {
      final conn = await _db.connection;
      final results = await conn.query(
        'SELECT id FROM fichas WHERE id = ? AND user_id = ? AND deleted_at IS NULL',
        [fichaId, userId],
      );
      return results.isNotEmpty;
    } catch (e) {
      print('❌ Erro ao verificar propriedade da ficha: $e');
      return false;
    }
  }

  /// Mapeia resultado do banco para modelo de domínio
  Ficha _mapToModel(ResultRow row) {
    return Ficha(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      animalName: row['animal_name'] as String,
      animalType: AnimalType.fromString(row['animal_type'] as String),
      breed: row['breed'] as String,
      sex: AnimalSex.fromString(row['sex'] as String),
      weight: (row['weight'] as num).toDouble(),
      birthDate: row['birth_date'] as DateTime?,
      microchipNumber: row['microchip_number'] as String?,
      ownerName: row['owner_name'] as String?,
      ownerPhone: row['owner_phone'] as String?,
      observations: row['observations'] as String?,
      createdAt: row['created_at'] as DateTime,
      updatedAt: row['updated_at'] as DateTime,
      deletedAt: row['deleted_at'] as DateTime?,
    );
  }
}
