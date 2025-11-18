// POST /api/v1/admin/reload-farmacos
// Força a re-inicialização do DatabaseProvider em tempo de execução

import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/providers/database_provider.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final dbProvider = context.read<DatabaseProvider>();
    await dbProvider.initialize();
    final stats = dbProvider.getStats();
    return Response.json(
      body: {
        'success': true,
        'message': 'Provedores recarregados com sucesso',
        'stats': stats,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'success': false,
        'error': 'Falha ao recarregar provedores',
        'message': e.toString(),
      },
    );
  }
}
