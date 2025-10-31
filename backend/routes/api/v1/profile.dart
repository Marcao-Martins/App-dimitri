// routes/api/v1/profile.dart
// Rota para obter perfil do usuário autenticado
// GET /api/v1/profile - Rota protegida (requer autenticação)

import 'package:dart_frog/dart_frog.dart';
import '../../../lib/providers/user_provider.dart';
import './_middleware.dart';

Future<Response> onRequest(RequestContext context) async {
  // Apenas GET é permitido
  if (context.request.method != HttpMethod.get) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Método não permitido'},
    );
  }

  // Verifica autenticação
  final authCheck = requireAuth(context);
  if (authCheck != null) {
    return authCheck; // Retorna 401 se não autenticado
  }

  try {
    // Obtém os dados do usuário do token JWT
    final authUser = context.read<Map<String, dynamic>?>()!;
    final userId = authUser['userId']?.toString();

    if (userId == null) {
      return Response.json(
        statusCode: 401,
        body: {
          'error': 'Token inválido',
          'message': 'ID do usuário não encontrado no token',
        },
      );
    }

    // Busca os dados completos do usuário
    final userProvider = context.read<UserProvider>();
    final user = userProvider.findUserById(userId);

    if (user == null) {
      return Response.json(
        statusCode: 404,
        body: {
          'error': 'Não encontrado',
          'message': 'Usuário não encontrado',
        },
      );
    }

    // Retorna o perfil (sem a senha)
    return Response.json(
      body: {
        'success': true,
        'user': user.toJsonSafe(),
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
