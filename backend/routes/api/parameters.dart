import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:mysql1/mysql1.dart';

Future<Response> onRequest(RequestContext context) async {
  // Se houver configuração de DB (ex.: AWS), buscar direto do banco
  final env = Platform.environment;
  final dbHost = env['DB_HOST'] ?? env['DB_HOSTNAME'];
  final species = context.request.uri.queryParameters['species'];
  final category = context.request.uri.queryParameters['category'];

  if (dbHost != null && dbHost.isNotEmpty) {
    try {
      final settings = ConnectionSettings(
        host: dbHost,
        port: int.tryParse(env['DB_PORT'] ?? '3306') ?? 3306,
        user: env['DB_USER'] ?? env['DB_USERNAME'] ?? 'root',
        password: env['DB_PASSWORD'] ?? env['DB_PASS'] ?? '',
        db: env['DB_NAME'] ?? env['DB_DATABASE'] ?? 'gdav_veterinario',
      );
      final conn = await MySqlConnection.connect(settings);

      final whereClauses = <String>[];
      final params = <dynamic>[];
      if (species != null) {
        whereClauses.add('species = ?');
        params.add(species);
      }
      if (category != null) {
        whereClauses.add('category = ?');
        params.add(category);
      }

      final whereSql = whereClauses.isNotEmpty ? 'WHERE ' + whereClauses.join(' AND ') : '';
      final results = await conn.query('SELECT id, species, parameter_name, parameter_value, comments, category FROM parametros_veterinarios $whereSql', params);

      final list = results.map((r) => {
            'id': r['id']?.toString() ?? '',
            'species': r['species']?.toString() ?? '',
            'parameter_name': r['parameter_name']?.toString() ?? '',
            'parameter_value': r['parameter_value']?.toString() ?? '',
            'comments': r['comments']?.toString() ?? '',
            'category': r['category']?.toString() ?? '',
          }).toList();

      await conn.close();
      return Response.json(body: list);
    } catch (e) {
      print('⚠️ Falha ao consultar parametros_veterinarios no DB: $e');
      // fallback para arquivo local
    }
  }

  // Não há fallback para arquivos locais — somente DB remoto.
  return Response.json(
    statusCode: 500,
    body: {'error': 'Parâmetros somente disponíveis via banco de dados. Configure as variáveis DB_*.'},
  );
}
