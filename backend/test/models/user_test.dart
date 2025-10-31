// test/models/user_test.dart
// Testes unitários para o modelo User
// 
// Executar: dart test

import 'package:test/test.dart';
import '../../lib/models/user.dart';

void main() {
  group('UserRole', () {
    test('fromString deve converter strings corretamente', () {
      expect(UserRole.fromString('consumer'), UserRole.consumer);
      expect(UserRole.fromString('administrator'), UserRole.administrator);
      expect(UserRole.fromString('ADMINISTRATOR'), UserRole.administrator);
    });
    
    test('fromString deve retornar consumer para valor desconhecido', () {
      expect(UserRole.fromString('invalido'), UserRole.consumer);
      expect(UserRole.fromString(''), UserRole.consumer);
    });
    
    test('toJson deve retornar nome correto', () {
      expect(UserRole.consumer.toJson(), 'consumer');
      expect(UserRole.administrator.toJson(), 'administrator');
    });
  });
  
  group('User', () {
    test('fromJson deve criar User corretamente', () {
      final json = {
        'id': '123',
        'name': 'João Silva',
        'email': 'joao@example.com',
        'password': 'hash123',
        'role': 'administrator',
      };
      
      final user = User.fromJson(json);
      
      expect(user.id, '123');
      expect(user.name, 'João Silva');
      expect(user.email, 'joao@example.com');
      expect(user.password, 'hash123');
      expect(user.role, UserRole.administrator);
    });
    
    test('toJson deve incluir todos os campos', () {
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@example.com',
        password: 'hash123',
        role: UserRole.administrator,
      );
      
      final json = user.toJson();
      
      expect(json['id'], '123');
      expect(json['name'], 'João Silva');
      expect(json['email'], 'joao@example.com');
      expect(json['password'], 'hash123');
      expect(json['role'], 'administrator');
    });
    
    test('toJsonSafe não deve incluir senha', () {
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@example.com',
        password: 'hash123',
        role: UserRole.consumer,
      );
      
      final json = user.toJsonSafe();
      
      expect(json['id'], '123');
      expect(json['name'], 'João Silva');
      expect(json['email'], 'joao@example.com');
      expect(json.containsKey('password'), false);
      expect(json['role'], 'consumer');
    });
    
    test('isAdmin deve retornar true para administrator', () {
      final admin = User(
        id: '1',
        name: 'Admin',
        email: 'admin@example.com',
        password: 'hash',
        role: UserRole.administrator,
      );
      
      expect(admin.isAdmin, true);
    });
    
    test('isAdmin deve retornar false para consumer', () {
      final user = User(
        id: '1',
        name: 'User',
        email: 'user@example.com',
        password: 'hash',
        role: UserRole.consumer,
      );
      
      expect(user.isAdmin, false);
    });
    
    test('copyWith deve criar nova instância com campos atualizados', () {
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@example.com',
        password: 'hash123',
      );
      
      final updated = user.copyWith(
        name: 'João Santos',
        role: UserRole.administrator,
      );
      
      expect(updated.id, '123'); // Não mudou
      expect(updated.name, 'João Santos'); // Mudou
      expect(updated.email, 'joao@example.com'); // Não mudou
      expect(updated.password, 'hash123'); // Não mudou
      expect(updated.role, UserRole.administrator); // Mudou
    });
    
    test('role padrão deve ser consumer', () {
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@example.com',
        password: 'hash123',
      );
      
      expect(user.role, UserRole.consumer);
    });
  });
}
