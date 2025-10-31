// test/services/password_service_test.dart
// Testes unitários para o PasswordService
// 
// Executar: dart test

import 'package:test/test.dart';
import '../../lib/services/password_service.dart';

void main() {
  group('PasswordService', () {
    test('hashPassword deve gerar hash válido', () {
      final password = 'senha12345';
      final hash = PasswordService.hashPassword(password);
      
      // Hash bcrypt sempre começa com $2b$ ou $2a$
      expect(hash.startsWith(r'$2'), true);
      // Deve ter tamanho de aproximadamente 60 caracteres
      expect(hash.length, greaterThan(50));
    });
    
    test('verifyPassword deve validar senha correta', () {
      final password = 'minhasenha123';
      final hash = PasswordService.hashPassword(password);
      
      final isValid = PasswordService.verifyPassword(password, hash);
      expect(isValid, true);
    });
    
    test('verifyPassword deve rejeitar senha incorreta', () {
      final password = 'minhasenha123';
      final wrongPassword = 'senhaerrada';
      final hash = PasswordService.hashPassword(password);
      
      final isValid = PasswordService.verifyPassword(wrongPassword, hash);
      expect(isValid, false);
    });
    
    test('validatePassword deve aceitar senha válida forte', () {
      final error = PasswordService.validatePassword('Senha@123Forte');
      expect(error, isNull);
    });
    
    test('validatePassword deve rejeitar senha vazia', () {
      final error = PasswordService.validatePassword('');
      expect(error, isNotNull);
      expect(error, contains('vazia'));
    });
    
    test('validatePassword deve rejeitar senha curta', () {
      final error = PasswordService.validatePassword('abc123');
      expect(error, isNotNull);
      expect(error, contains('8 caracteres'));
    });
    
    test('validatePassword deve rejeitar senha sem maiúscula', () {
      final error = PasswordService.validatePassword('senha@123');
      expect(error, isNotNull);
      expect(error, contains('maiúscula'));
    });
    
    test('validatePassword deve rejeitar senha sem minúscula', () {
      final error = PasswordService.validatePassword('SENHA@123');
      expect(error, isNotNull);
      expect(error, contains('minúscula'));
    });
    
    test('validatePassword deve rejeitar senha sem número', () {
      final error = PasswordService.validatePassword('Senha@Forte');
      expect(error, isNotNull);
      expect(error, contains('número'));
    });
    
    test('validatePassword deve rejeitar senha sem caractere especial', () {
      final error = PasswordService.validatePassword('Senha123Forte');
      expect(error, isNotNull);
      expect(error, contains('especial'));
    });
    
    test('validatePassword deve rejeitar senha muito longa', () {
      final longPassword = 'A' * 129 + '1@';
      final error = PasswordService.validatePassword(longPassword);
      expect(error, isNotNull);
      expect(error, contains('128 caracteres'));
    });
    
    test('validatePassword deve rejeitar senhas comuns', () {
      final commonPasswords = ['password123', 'Password1!', 'Admin123!'];
      for (final pass in commonPasswords) {
        final error = PasswordService.validatePassword(pass);
        expect(error, isNotNull);
        expect(error, contains('comum'));
      }
    });
    
    test('hashes diferentes para mesma senha', () {
      final password = 'Senha@123Forte';
      final hash1 = PasswordService.hashPassword(password);
      final hash2 = PasswordService.hashPassword(password);
      
      // Os hashes devem ser diferentes (salt único)
      expect(hash1, isNot(equals(hash2)));
      
      // Mas ambos devem validar a mesma senha
      expect(PasswordService.verifyPassword(password, hash1), true);
      expect(PasswordService.verifyPassword(password, hash2), true);
    });
  });
  
  group('PasswordService - Força da Senha', () {
    test('getPasswordStrength deve retornar 0 para senha vazia', () {
      expect(PasswordService.getPasswordStrength(''), 0);
    });
    
    test('getPasswordStrength deve retornar força baixa para senha fraca', () {
      final strength = PasswordService.getPasswordStrength('abc123');
      expect(strength, lessThan(3));
    });
    
    test('getPasswordStrength deve retornar força alta para senha forte', () {
      final strength = PasswordService.getPasswordStrength('Abc123!@#XyZ');
      expect(strength, greaterThanOrEqualTo(3));
    });
    
    test('getPasswordStrength deve penalizar senhas comuns', () {
      final common = PasswordService.getPasswordStrength('password123');
      final strong = PasswordService.getPasswordStrength('Xyz@789Qwerty');
      expect(common, lessThan(strong));
    });
  });
  
  group('PasswordService - Geração de Senhas', () {
    test('generateStrongPassword deve gerar senha com tamanho correto', () {
      final password = PasswordService.generateStrongPassword(length: 16);
      expect(password.length, 16);
    });
    
    test('generateStrongPassword deve incluir maiúscula', () {
      final password = PasswordService.generateStrongPassword();
      expect(RegExp(r'[A-Z]').hasMatch(password), true);
    });
    
    test('generateStrongPassword deve incluir minúscula', () {
      final password = PasswordService.generateStrongPassword();
      expect(RegExp(r'[a-z]').hasMatch(password), true);
    });
    
    test('generateStrongPassword deve incluir número', () {
      final password = PasswordService.generateStrongPassword();
      expect(RegExp(r'[0-9]').hasMatch(password), true);
    });
    
    test('generateStrongPassword deve incluir caractere especial', () {
      final password = PasswordService.generateStrongPassword();
      expect(RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password), true);
    });
    
    test('generateStrongPassword deve respeitar tamanho mínimo', () {
      final password = PasswordService.generateStrongPassword(length: 4);
      expect(password.length, greaterThanOrEqualTo(8));
    });
    
    test('generateStrongPassword deve respeitar tamanho máximo', () {
      final password = PasswordService.generateStrongPassword(length: 200);
      expect(password.length, lessThanOrEqualTo(128));
    });
  });
}
