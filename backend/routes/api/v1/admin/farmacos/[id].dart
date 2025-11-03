// routes/api/v1/admin/farmacos/[id].dart
// Rotas administrativas para gerenciar fármacos individuais
// PUT /api/v1/admin/farmacos/:id - Atualizar fármaco
// DELETE /api/v1/admin/farmacos/:id - Deletar fármaco

import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../../../lib/providers/database_provider.dart';
import '../../../../../lib/models/farmaco.dart';
import '../../_middleware.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  // Verifica se o usuário é administrador
  final adminCheck = requireAdmin(context);
  if (adminCheck != null) {
    return adminCheck; // Retorna 401 ou 403
  }

  final method = context.request.method;

  switch (method) {
    case HttpMethod.get:
      return _handleGet(context, id);
    case HttpMethod.put:
      return _handleUpdate(context, id);
    case HttpMethod.delete:
      return _handleDelete(context, id);
    default:
      return Response.json(
        statusCode: 405,
        body: {'error': 'Método não permitido'},
      );
  }
}

// GET - Busca fármaco específico por ID
Future<Response> _handleGet(RequestContext context, String id) async {
  try {
    final dbProvider = context.read<DatabaseProvider>();
    final farmaco = dbProvider.findById(id);

    if (farmaco == null) {
      return Response.json(
        statusCode: 404,
        body: {
          'error': 'Fármaco não encontrado',
          'message': 'Nenhum fármaco com ID "$id" foi encontrado',
        },
      );
    }

    return Response.json(
      body: {
        'success': true,
        'data': farmaco.toJson(),
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

// PUT - Atualiza fármaco existente
Future<Response> _handleUpdate(RequestContext context, String id) async {
  try {
    final dbProvider = context.read<DatabaseProvider>();
    
    // Verifica se o fármaco existe
    final existingFarmaco = dbProvider.findById(id);
    if (existingFarmaco == null) {
      return Response.json(
        statusCode: 404,
        body: {
          'error': 'Fármaco não encontrado',
          'message': 'Nenhum fármaco com ID "$id" foi encontrado',
        },
      );
    }

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

    // Mantém o ID original
    data['post_id'] = id;
    
    // Atualiza o timestamp
    data['post_date'] = DateTime.now().toIso8601String();

    // Cria o objeto Farmaco atualizado
    final updatedFarmaco = Farmaco.fromJson(data);

    // Atualiza no provider
    dbProvider.updateFarmaco(id, updatedFarmaco);

    return Response.json(
      body: {
        'success': true,
        'message': 'Fármaco atualizado com sucesso',
        'data': updatedFarmaco.toJson(),
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

// DELETE - Remove fármaco
Future<Response> _handleDelete(RequestContext context, String id) async {
  try {
    final dbProvider = context.read<DatabaseProvider>();
    
    // Verifica se o fármaco existe
    final existingFarmaco = dbProvider.findById(id);
    if (existingFarmaco == null) {
      return Response.json(
        statusCode: 404,
        body: {
          'error': 'Fármaco não encontrado',
          'message': 'Nenhum fármaco com ID "$id" foi encontrado',
        },
      );
    }

    // Remove do provider
    dbProvider.deleteFarmaco(id);

    return Response.json(
      body: {
        'success': true,
        'message': 'Fármaco deletado com sucesso',
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
