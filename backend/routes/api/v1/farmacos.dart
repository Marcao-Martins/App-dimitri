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
    // Usa o provider de dados (que carrega do DB — sem fallback a arquivos locais)
    final dbProvider = context.read<DatabaseProvider>();

    // Suporte a query params para filtros
    final queryParams = context.request.uri.queryParameters;
    final search = queryParams['search'];
    final classFilter = queryParams['classe'];

    List<dynamic> farmacos;

    if (search != null && search.isNotEmpty) {
      farmacos = dbProvider.searchByName(search).map((f) => f.toJson()).toList();
    } else if (classFilter != null && classFilter.isNotEmpty) {
      farmacos = dbProvider.filterByClass(classFilter).map((f) => f.toJson()).toList();
    } else {
      farmacos = dbProvider.farmacos.map((f) => f.toJson()).toList();
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
