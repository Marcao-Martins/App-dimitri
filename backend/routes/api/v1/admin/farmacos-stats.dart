// GET /api/v1/admin/farmacos-stats
// Rota de diagnóstico: retorna estatísticas e amostra de fármacos carregados

import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/providers/database_provider.dart';

Future<Response> onRequest(RequestContext context) async {
  try {
    final dbProvider = context.read<DatabaseProvider>();
    final stats = dbProvider.getStats();
    final sample = dbProvider.farmacos.take(3).map((f) => f.toJson()).toList();
    return Response.json(
      body: {
        'success': true,
        'stats': stats,
        'sample': sample,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {'success': false, 'error': e.toString()},
    );
  }
}
