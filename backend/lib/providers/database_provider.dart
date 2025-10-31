// lib/providers/database_provider.dart
// Provedor de dados para fármacos (PLACEHOLDER - leitura de CSV)
// Em produção, substitua por conexão com banco de dados real (PostgreSQL, MongoDB, etc)

import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import '../models/farmaco.dart';

class DatabaseProvider {
  // Lista em memória dos fármacos carregados do CSV
  // IMPORTANTE: Esta abordagem é apenas para desenvolvimento!
  // Em produção, use um banco de dados real e implemente paginação
  List<Farmaco> _farmacos = [];

  /// Retorna a lista de fármacos (somente leitura)
  List<Farmaco> get farmacos => List.unmodifiable(_farmacos);

  /// Inicializa o provider carregando os dados do CSV
  /// 
  /// Deve ser chamado no middleware global antes de processar requisições
  /// 
  /// Exemplo de uso:
  /// ```dart
  /// final dbProvider = DatabaseProvider();
  /// await dbProvider.initialize();
  /// ```
  Future<void> initialize() async {
    try {
      final file = File('data/farmacos_veterinarios.csv');
      
      if (!await file.exists()) {
        throw Exception(
          'Arquivo farmacos_veterinarios.csv não encontrado em data/',
        );
      }

      final input = await file.readAsString();
      
      // Parse do CSV
      final fields = const CsvToListConverter().convert(input);
      
      if (fields.isEmpty) {
        throw Exception('Arquivo CSV está vazio');
      }

      // Primeira linha contém os headers
      final headers = fields.first.map((e) => e.toString()).toList();
      
      // Converte cada linha (exceto header) em um objeto Farmaco
      _farmacos = fields.skip(1).map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < headers.length && i < row.length; i++) {
          map[headers[i]] = row[i];
        }
        return Farmaco.fromJson(map);
      }).toList();

      print('✅ ${_farmacos.length} fármacos carregados do CSV');
    } catch (e) {
      print('❌ Erro ao carregar fármacos: $e');
      rethrow;
    }
  }

  /// Busca um fármaco pelo ID
  Farmaco? findById(String id) {
    try {
      return _farmacos.firstWhere((f) => f.postId == id);
    } catch (e) {
      return null;
    }
  }

  /// Busca fármacos por nome (case-insensitive)
  List<Farmaco> searchByName(String query) {
    final lowerQuery = query.toLowerCase();
    return _farmacos
        .where((f) => 
            f.farmaco.toLowerCase().contains(lowerQuery) ||
            f.titulo.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Busca fármacos por classe farmacológica
  List<Farmaco> filterByClass(String className) {
    final lowerClass = className.toLowerCase();
    return _farmacos
        .where((f) => 
            f.classeFarmacologica.toLowerCase().contains(lowerClass))
        .toList();
  }

  /// Adiciona um novo fármaco
  /// 
  /// NOTA: Em desenvolvimento, apenas adiciona à lista em memória
  /// Os dados não serão persistidos após reiniciar o servidor
  /// Em produção, implemente persistência no banco de dados
  void addFarmaco(Farmaco farmaco) {
    _farmacos.add(farmaco);
    print('ℹ️  Fármaco adicionado (apenas em memória): ${farmaco.titulo}');
    // TODO: Em produção, adicionar ao banco de dados
  }

  /// Atualiza um fármaco existente
  /// 
  /// NOTA: Atualização apenas em memória (não persistida)
  bool updateFarmaco(String id, Farmaco updatedFarmaco) {
    final index = _farmacos.indexWhere((f) => f.postId == id);
    if (index != -1) {
      _farmacos[index] = updatedFarmaco;
      print('ℹ️  Fármaco atualizado (apenas em memória): ${updatedFarmaco.titulo}');
      // TODO: Em produção, atualizar no banco de dados
      return true;
    }
    return false;
  }

  /// Remove um fármaco
  /// 
  /// NOTA: Remoção apenas em memória (não persistida)
  bool deleteFarmaco(String id) {
    final initialLength = _farmacos.length;
    _farmacos.removeWhere((f) => f.postId == id);
    final removed = _farmacos.length < initialLength;
    if (removed) {
      print('ℹ️  Fármaco removido (apenas em memória): $id');
      // TODO: Em produção, remover do banco de dados
    }
    return removed;
  }

  /// Obtém estatísticas dos dados
  Map<String, dynamic> getStats() {
    final classesCounts = <String, int>{};
    for (final farmaco in _farmacos) {
      classesCounts[farmaco.classeFarmacologica] = 
          (classesCounts[farmaco.classeFarmacologica] ?? 0) + 1;
    }

    return {
      'total': _farmacos.length,
      'classes': classesCounts,
    };
  }
}
