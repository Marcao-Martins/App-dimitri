// lib/services/jwt_service.dart
// Serviço para geração e validação de tokens JWT
// Gerencia autenticação baseada em tokens

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  // IMPORTANTE: Em produção, use uma variável de ambiente para o secret
  // Nunca commite secrets em repositórios!
  // Exemplo: final _secret = Platform.environment['JWT_SECRET'] ?? 'fallback';
  static const String _secret = 'your-secret-key-change-in-production-123';
  
  // Duração de validade do token (24 horas)
  static const Duration _tokenDuration = Duration(hours: 24);

  /// Gera um token JWT para o usuário
  /// 
  /// O payload contém:
  /// - userId: ID do usuário
  /// - email: Email do usuário
  /// - role: Nível de acesso (consumer/administrator)
  /// - iat: Timestamp de emissão
  /// - exp: Timestamp de expiração
  /// 
  /// Exemplo:
  /// ```dart
  /// final token = JwtService.generateToken(
  ///   userId: '123',
  ///   email: 'user@example.com',
  ///   role: 'consumer',
  /// );
  /// ```
  static String generateToken({
    required String userId,
    required String email,
    required String role,
  }) {
    final now = DateTime.now();
    final expiry = now.add(_tokenDuration);

    final jwt = JWT(
      {
        'userId': userId,
        'email': email,
        'role': role,
        'iat': now.millisecondsSinceEpoch ~/ 1000,
        'exp': expiry.millisecondsSinceEpoch ~/ 1000,
      },
    );

    return jwt.sign(SecretKey(_secret));
  }

  /// Valida um token JWT e retorna o payload se válido
  /// 
  /// Retorna null se o token for inválido ou expirado
  /// 
  /// Exemplo:
  /// ```dart
  /// final payload = JwtService.verifyToken(token);
  /// if (payload != null) {
  ///   final userId = payload['userId'];
  ///   final role = payload['role'];
  /// }
  /// ```
  static Map<String, dynamic>? verifyToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(_secret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      // Token expirado
      return null;
    } on JWTException {
      // Token inválido
      return null;
    } catch (e) {
      // Outro erro
      return null;
    }
  }

  /// Extrai o token do header Authorization
  /// 
  /// Formato esperado: "Bearer <token>"
  /// 
  /// Retorna null se o formato for inválido
  static String? extractTokenFromHeader(String? authHeader) {
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    
    return authHeader.substring(7); // Remove "Bearer "
  }

  /// Verifica se o token tem o role especificado
  /// 
  /// Útil para verificar permissões de admin
  static bool hasRole(Map<String, dynamic> payload, String requiredRole) {
    final userRole = payload['role']?.toString() ?? '';
    return userRole == requiredRole;
  }
}
