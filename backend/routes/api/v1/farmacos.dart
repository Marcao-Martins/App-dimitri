// routes/api/v1/farmacos.dart
// Rota para listar todos os fármacos
// GET /api/v1/farmacos - Rota pública

import 'package:dart_frog/dart_frog.dart';
import '../../../lib/providers/database_provider.dart';

Future<Response> onRequest(RequestContext context) async {
  // Apenas GET é permitido
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Método não permitido'},
    );
  }

  try {
    // Obtém o provider de dados do contexto
    final dbProvider = context.read<DatabaseProvider>();
    
    // Suporte a query params para filtros (opcional)
    final queryParams = context.request.uri.queryParameters;
    final search = queryParams['search'];
    final classFilter = queryParams['classe'];

    List<dynamic> farmacos;

    if (search != null && search.isNotEmpty) {
      // Busca por nome
      farmacos = dbProvider.searchByName(search)
          .map((f) => f.toJson())
          .toList();
    } else if (classFilter != null && classFilter.isNotEmpty) {
      // Filtro por classe
      farmacos = dbProvider.filterByClass(classFilter)
          .map((f) => f.toJson())
          .toList();
    } else {
      // Retorna todos
      farmacos = dbProvider.farmacos
          .map((f) => f.toJson())
          .toList();
    }

    return Response.json(
      body: {
        'success': true,
        'count': farmacos.length,
        'data': farmacos,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: 500,
      body: {
        'error': 'Erro interno do servidor',
        'message': e.toString(),
      },
    );
  }
}
