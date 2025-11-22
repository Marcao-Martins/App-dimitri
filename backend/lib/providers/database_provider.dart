// lib/providers/database_provider.dart
// Provedor de dados para fármacos (PLACEHOLDER - leitura de CSV)
// Em produção, substitua por conexão com banco de dados real (PostgreSQL, MongoDB, etc)

import 'dart:io';
// CSV parsing removed — backend agora exige conexão com DB remoto
import '../models/farmaco.dart';
import '../database/database.dart';

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
      // Try to load DB config from AWS Secrets Manager if requested
      final env = Platform.environment;
      final secretId = env['AWS_SECRET_ID'] ?? 'prod';
      final region = env['AWS_REGION'] ?? 'us-east-1';

      DatabaseConfig? config;
      try {
        config = await loadConfigFromAwsSecret(secretId: secretId, region: region);
      } catch (_) {
        config = null;
      }

      if (config == null) {
        // Fallback to environment variables
        final dbHost = env['DB_HOST'] ?? env['DB_HOSTNAME'];
        if (dbHost != null && dbHost.isNotEmpty) {
          config = DatabaseConfig.fromEnvironment();
        }
      }

      if (config != null) {
        try {
          final appDb = AppDatabase(config);

          print('🔌 Tentando conectar ao banco em ${config.host}...');

          // Use pooled connection to load farmacos
          await appDb.usingConnection((conn) async {
            final results = await conn.query('''
              SELECT
                COALESCE(post_id, id) AS post_id,
                titulo,
                farmaco,
                classe_farmacologica,
                nome_comercial,
                mecanismo_de_acao,
                posologia_caes,
                posologia_gatos,
                ivc,
                comentarios,
                referencia,
                IFNULL(post_date, '') AS post_date,
                IFNULL(link, '') AS link
              FROM farmacos
              WHERE deleted_at IS NULL
            ''');

            _farmacos = results.map((row) {
              final map = <String, dynamic>{
                'post_id': row['post_id']?.toString() ?? '',
                'titulo': row['titulo']?.toString() ?? '',
                'farmaco': row['farmaco']?.toString() ?? '',
                'classe_farmacologica': row['classe_farmacologica']?.toString() ?? '',
                'nome_comercial': row['nome_comercial']?.toString() ?? '',
                'mecanismo_de_acao': row['mecanismo_de_acao']?.toString() ?? '',
                'posologia_caes': row['posologia_caes']?.toString() ?? '',
                'posologia_gatos': row['posologia_gatos']?.toString() ?? '',
                'ivc': row['ivc']?.toString() ?? '',
                'comentarios': row['comentarios']?.toString() ?? '',
                'referencia': row['referencia']?.toString() ?? '',
                'post_date': row['post_date']?.toString() ?? '',
                'link': row['link']?.toString() ?? '',
              };
              return Farmaco.fromJson(map);
            }).toList();
          });

          print('✅ ${_farmacos.length} fármacos carregados do banco de dados');
          return;
        } catch (e) {
          print('⚠️ Falha ao carregar do DB: $e — fallback para arquivo local');
        }
      }

      // A partir desta alteração, o backend NÃO usa mais arquivos CSV/JSON locais.
      // É necessário configurar variáveis de ambiente de conexão ao banco (DB_HOST, DB_USER, DB_PASSWORD, DB_NAME).
      // Se a conexão falhar ou não estiver configurada, lançamos uma exceção para forçar a correção do ambiente.
      throw Exception('Conexão ao banco de dados não configurada ou falhou. Configure variáveis de ambiente DB_HOST/DB_USER/DB_PASSWORD/DB_NAME.');
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
