// routes/api/v1/_middleware.dart
// Middleware de autenticação para rotas protegidas
// Valida o token JWT e injeta os dados do usuário no contexto

import 'package:dart_frog/dart_frog.dart';
import '../../../lib/services/jwt_service.dart';

/// Middleware de autenticação
/// 
/// Extrai e valida o token JWT do header Authorization
/// Se válido, injeta o payload no contexto como 'authUser'
/// 
/// Rotas que precisam de autenticação devem acessar via:
/// ```dart
/// final authUser = context.read<Map<String, dynamic>?>();
/// if (authUser == null) {
///   return Response.json(statusCode: 401, body: {'error': 'Não autorizado'});
/// }
/// ```
Handler middleware(Handler handler) {
  return (context) async {
    // Extrai o token do header Authorization
    final authHeader = context.request.headers['authorization'];
    final token = JwtService.extractTokenFromHeader(authHeader);

    Map<String, dynamic>? authUser;

    if (token != null) {
      // Valida o token e extrai o payload
      authUser = JwtService.verifyToken(token);
    }

    // Injeta o usuário autenticado (ou null) no contexto
    // Permite que rotas decidam se autenticação é obrigatória ou opcional
    final contextWithAuth = context.provide<Map<String, dynamic>?>(() => authUser);

    return handler(contextWithAuth);
  };
}

/// Helper function para verificar se o usuário está autenticado
/// Útil para DRY nas rotas protegidas
Response? requireAuth(RequestContext context) {
  final authUser = context.read<Map<String, dynamic>?>();
  
  if (authUser == null) {
    return Response.json(
      statusCode: 401,
      body: {
        'error': 'Não autorizado',
        'message': 'Token inválido ou expirado',
      },
    );
  }
  
  return null; // Autenticado
}

/// Helper function para verificar se o usuário é administrador
Response? requireAdmin(RequestContext context) {
  final authResponse = requireAuth(context);
  if (authResponse != null) {
    return authResponse; // Não autenticado
  }

  final authUser = context.read<Map<String, dynamic>?>()!;
  
  if (!JwtService.hasRole(authUser, 'administrator')) {
    return Response.json(
      statusCode: 403,
      body: {
        'error': 'Acesso negado',
        'message': 'Requer permissões de administrador',
      },
    );
  }
  
  return null; // É admin
}
