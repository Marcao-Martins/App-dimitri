// routes/api/v1/auth/login.dart
// Rota para autenticação de usuários
// POST /api/v1/auth/login - Rota pública

import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/providers/user_provider.dart';
import '../../../../lib/services/jwt_service.dart';

Future<Response> onRequest(RequestContext context) async {
  // Apenas POST é permitido
  if (context.request.method != HttpMethod.post) {
    return Response.json(
      statusCode: 405,
      body: {'error': 'Método não permitido'},
    );
  }

  try {
    // Lê o corpo da requisição
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    // Validação dos campos obrigatórios
    final email = data['email']?.toString().trim();
    final password = data['password']?.toString();

    if (email == null || email.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Dados inválidos',
          'message': 'Campo "email" é obrigatório',
        },
      );
    }

    if (password == null || password.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Dados inválidos',
          'message': 'Campo "password" é obrigatório',
        },
      );
    }

    // Obtém o provider de usuários
    final userProvider = context.read<UserProvider>();

    // Valida as credenciais
    final user = userProvider.validateCredentials(email, password);

    if (user == null) {
      // Credenciais inválidas
      return Response.json(
        statusCode: 401,
        body: {
          'error': 'Não autorizado',
          'message': 'Email ou senha incorretos',
        },
      );
    }

    // Gera o token JWT
    final token = JwtService.generateToken(
      userId: user.id,
      email: user.email,
      role: user.role.name,
    );

    // Retorna o token e dados do usuário (sem a senha)
    return Response.json(
      body: {
        'success': true,
        'message': 'Login realizado com sucesso',
        'token': token,
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
