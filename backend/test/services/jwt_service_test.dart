// test/services/jwt_service_test.dart
// Testes unitários para o JwtService
// 
// Executar: dart test

import 'package:test/test.dart';
import '../../lib/services/jwt_service.dart';

void main() {
  group('JwtService', () {
    test('generateToken deve criar token válido', () {
      final token = JwtService.generateToken(
        userId: '123',
        email: 'test@example.com',
        role: 'consumer',
      );
      
      // Token JWT tem 3 partes separadas por ponto
      final parts = token.split('.');
      expect(parts.length, 3);
    });
    
    test('verifyToken deve validar token válido', () {
      final token = JwtService.generateToken(
        userId: '123',
        email: 'test@example.com',
        role: 'consumer',
      );
      
      final payload = JwtService.verifyToken(token);
      
      expect(payload, isNotNull);
      expect(payload!['userId'], '123');
      expect(payload['email'], 'test@example.com');
      expect(payload['role'], 'consumer');
    });
    
    test('verifyToken deve rejeitar token inválido', () {
      final invalidToken = 'token.invalido.aqui';
      
      final payload = JwtService.verifyToken(invalidToken);
      expect(payload, isNull);
    });
    
    test('extractTokenFromHeader deve extrair token do Bearer', () {
      final authHeader = 'Bearer meu.token.aqui';
      
      final token = JwtService.extractTokenFromHeader(authHeader);
      expect(token, 'meu.token.aqui');
    });
    
    test('extractTokenFromHeader deve retornar null sem Bearer', () {
      final authHeader = 'meu.token.aqui';
      
      final token = JwtService.extractTokenFromHeader(authHeader);
      expect(token, isNull);
    });
    
    test('extractTokenFromHeader deve retornar null para header null', () {
      final token = JwtService.extractTokenFromHeader(null);
      expect(token, isNull);
    });
    
    test('hasRole deve verificar role corretamente', () {
      final token = JwtService.generateToken(
        userId: '123',
        email: 'admin@example.com',
        role: 'administrator',
      );
      
      final payload = JwtService.verifyToken(token)!;
      
      expect(JwtService.hasRole(payload, 'administrator'), true);
      expect(JwtService.hasRole(payload, 'consumer'), false);
    });
    
    test('token deve conter timestamps iat e exp', () {
      final token = JwtService.generateToken(
        userId: '123',
        email: 'test@example.com',
        role: 'consumer',
      );
      
      final payload = JwtService.verifyToken(token)!;
      
      expect(payload['iat'], isNotNull);
      expect(payload['exp'], isNotNull);
      expect(payload['exp'], greaterThan(payload['iat']));
    });
  });
}
