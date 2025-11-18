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
      // Tenta localizar arquivos em vários locais possíveis (repo root, backend/, data/)
      // para cobrir diferentes working directories ao iniciar o servidor.
      File? _locate(String relativePath) {
        final candidates = <String>[];

        // Common locations (prefer backend/data and data/)
        candidates.add('backend/$relativePath');
        candidates.add('data/$relativePath');
        candidates.add(relativePath);

        // Relative to parent (in case process cwd is backend/ or repo root)
        candidates.add('../$relativePath');
        candidates.add('./$relativePath');

        // Try explicit backend/data path from repo root
        candidates.add('backend/data/${relativePath.split('/').last}');

        for (final p in candidates) {
          final f = File(p);
          if (f.existsSync()) {
            print('🔎 Localizei arquivo em: $p');
            return f;
          }
        }

        // Fallback: try to search upward a few levels for the file
        var dir = Directory.current;
        for (var i = 0; i < 3; i++) {
          final candidate = File('${dir.path}/$relativePath');
          if (candidate.existsSync()) {
            print('🔎 Localizei arquivo em (busca ascendente): ${candidate.path}');
            return candidate;
          }
          dir = dir.parent;
        }

        return null;
      }

      final jsonFile = _locate('data/farmacos_veterinarios.json');
      if (jsonFile != null) {
        final content = await jsonFile.readAsString();
        final parsed = json.decode(content);
        if (parsed is List) {
          _farmacos = parsed
              .map((e) => Farmaco.fromJson(Map<String, dynamic>.from(e)))
              .toList();
          print('✅ ${_farmacos.length} fármacos carregados de ${jsonFile.path}');
          return;
        }
      }

      final csvFile = _locate('data/farmacos_veterinarios.csv');
      if (csvFile == null) {
        throw Exception('Arquivo farmacos_veterinarios.csv não encontrado em data/ (caminhos verificados)');
      }

      final input = await csvFile.readAsString();
      
      // Parse do CSV (arquivo separado por ';')
      final fields = const CsvToListConverter(
        fieldDelimiter: ';',
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(input);
      
      if (fields.isEmpty) {
        throw Exception('Arquivo CSV está vazio');
      }

      // Primeira linha contém os headers (normalizar para chaves em lowercase)
      final headers = fields.first.map((e) => e.toString().trim().toLowerCase()).toList();
      
      // Converte cada linha (exceto header) em um objeto Farmaco
      _farmacos = fields.skip(1).map((row) {
        final map = <String, dynamic>{};
        for (var i = 0; i < headers.length && i < row.length; i++) {
          map[headers[i]] = row[i];
        }
        return Farmaco.fromJson(map);
      }).toList();

      print('✅ ${_farmacos.length} fármacos carregados do CSV');

      // Escrever JSON cache ao lado do CSV para uso em próximas inicializações
      try {
        final cacheFile = File('${csvFile.parent.path}/farmacos_veterinarios.json');
        final encoder = const JsonEncoder.withIndent('  ');
        final jsonContent = encoder.convert(_farmacos.map((f) => f.toJson()).toList());
        await cacheFile.writeAsString(jsonContent, flush: true);
        print('💾 JSON cache escrito em: ${cacheFile.path}');
      } catch (e) {
        print('⚠️ Falha ao gravar JSON cache: $e');
      }
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
