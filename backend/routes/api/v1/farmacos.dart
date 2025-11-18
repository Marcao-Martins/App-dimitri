// routes/api/v1/farmacos.dart
// Rota para gerenciar fármacos
// GET /api/v1/farmacos - Rota pública (listar/buscar)
// POST /api/v1/farmacos - Rota protegida (adicionar - admin)

import 'dart:convert';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import '../../../lib/providers/database_provider.dart';
import '../../../lib/models/farmaco.dart';
import '_middleware.dart';

Future<Response> onRequest(RequestContext context) async {
  final method = context.request.method;

  switch (method) {
    case HttpMethod.get:
      return _handleGet(context);
    case HttpMethod.post:
      return _handlePost(context);
    default:
      return Response.json(
        statusCode: 405,
        body: {'error': 'Método não permitido'},
      );
  }
}

// GET - Lista/busca fármacos (rota pública)
Future<Response> _handleGet(RequestContext context) async {
  try {
    // Prefer reading the prepared JSON cache on disk (deterministic)
    Future<List<Map<String, dynamic>>?> _loadJsonFromDisk() async {
      final candidates = <String>[
        'backend/data/farmacos_veterinarios.json',
        'data/farmacos_veterinarios.json',
        'farmacos_veterinarios.json',
        '../backend/data/farmacos_veterinarios.json',
        './data/farmacos_veterinarios.json',
      ];

      for (final p in candidates) {
        final f = File(p);
        if (await f.exists()) {
          try {
            final content = await f.readAsString();
            final parsed = jsonDecode(content);
            if (parsed is List) {
              return parsed.map((e) => Map<String, dynamic>.from(e)).toList();
            }
          } catch (_) {
            // ignore parse errors and try next candidate
          }
        }
      }
      return null;
    }

    final diskList = await _loadJsonFromDisk();
    final dbProvider = context.read<DatabaseProvider>();
    
    // Suporte a query params para filtros
    final queryParams = context.request.uri.queryParameters;
    final search = queryParams['search'];
    final classFilter = queryParams['classe'];

    List<dynamic> farmacos;

    if (diskList != null) {
      // Use disk JSON as source of truth and apply filters in-memory
      var items = diskList;
      if (search != null && search.isNotEmpty) {
        final q = search.toLowerCase();
        items = items.where((m) {
          final farmaco = (m['farmaco'] ?? '')?.toString() ?? '';
          final titulo = (m['titulo'] ?? '')?.toString() ?? '';
          return (farmaco + ' ' + titulo).toLowerCase().contains(q);
        }).toList();
      } else if (classFilter != null && classFilter.isNotEmpty) {
        final c = classFilter.toLowerCase();
        items = items.where((m) {
          final cls = (m['classe_farmacologica'] ?? '')?.toString() ?? '';
          return cls.toLowerCase().contains(c);
        }).toList();
      }

      farmacos = items;
    } else {
      // Fallback para provider em memória (compatibilidade)
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

// POST - Adiciona novo fármaco (rota protegida - admin)
Future<Response> _handlePost(RequestContext context) async {
  // Verifica se o usuário é administrador
  final adminCheck = requireAdmin(context);
  if (adminCheck != null) {
    return adminCheck; // Retorna 401 ou 403
  }

  try {
    // Lê o corpo da requisição
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    // Validação básica
    if (data['farmaco'] == null || data['farmaco'].toString().isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Dados inválidos',
          'message': 'Campo "farmaco" é obrigatório',
        },
      );
    }

    // Gera ID único para o novo fármaco
    final postId = DateTime.now().millisecondsSinceEpoch.toString();
    data['post_id'] = postId;
    data['post_date'] = DateTime.now().toIso8601String();

    // Cria o objeto Farmaco
    final farmaco = Farmaco.fromJson(data);

    // Adiciona ao provider
    final dbProvider = context.read<DatabaseProvider>();
    dbProvider.addFarmaco(farmaco);

    return Response.json(
      statusCode: 201,
      body: {
        'success': true,
        'message': 'Fármaco adicionado com sucesso',
        'data': farmaco.toJson(),
        'warning': 'Dados salvos apenas em memória (placeholder). '
            'Serão perdidos ao reiniciar o servidor.',
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
