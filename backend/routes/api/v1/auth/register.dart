// routes/api/v1/auth/register.dart
// Rota para registro de novos usuários
// POST /api/v1/auth/register - Rota pública

import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import '../../../../lib/providers/user_provider.dart';
import '../../../../lib/models/user.dart';

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
    final name = data['name']?.toString().trim();
    final email = data['email']?.toString().trim();
    final password = data['password']?.toString();

    if (name == null || name.isEmpty) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Dados inválidos',
          'message': 'Campo "name" é obrigatório',
        },
      );
    }

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

    // Validação básica de email
    if (!email.contains('@')) {
      return Response.json(
        statusCode: 400,
        body: {
          'error': 'Dados inválidos',
          'message': 'Email inválido',
        },
      );
    }

    // Obtém o provider de usuários
    final userProvider = context.read<UserProvider>();

    // Verifica se o email já existe
    if (userProvider.emailExists(email)) {
      return Response.json(
        statusCode: 409,
        body: {
          'error': 'Conflito',
          'message': 'Email já está em uso',
        },
      );
    }

    // Cria o usuário (a senha é hasheada dentro do método)
    // Role padrão é 'consumer'
    final user = await userProvider.createUser(
      name: name,
      email: email,
      password: password,
      role: UserRole.consumer,
    );

    // Retorna sucesso (sem a senha)
    return Response.json(
      statusCode: 201,
      body: {
        'success': true,
        'message': 'Usuário criado com sucesso',
        'user': user.toJsonSafe(),
      },
    );
  } on Exception catch (e) {
    // Erros de validação ou duplicidade
    return Response.json(
      statusCode: 400,
      body: {
        'error': 'Erro ao criar usuário',
        'message': e.toString().replaceAll('Exception: ', ''),
      },
    );
  } catch (e) {
    // Erros inesperados
    return Response.json(
      statusCode: 500,
      body: {
        'error': 'Erro interno do servidor',
        'message': e.toString(),
      },
    );
  }
}
