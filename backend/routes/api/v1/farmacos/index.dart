// routes/api/v1/farmacos/index.dart
// Rota para adicionar novos fármacos (apenas admin)
// POST /api/v1/farmacos - Rota protegida (admin)

import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/providers/database_provider.dart';
import '../../../../lib/models/farmaco.dart';
import '../_middleware.dart';

Future<Response> onRequest(RequestContext context) async {
  // Apenas POST é permitido nesta rota específica
  // (GET é tratado em farmacos.dart no nível acima)
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Método não permitido'},
    );
  }

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
