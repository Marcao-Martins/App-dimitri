// lib/services/password_service.dart
// Serviço para hash e validação de senhas usando bcrypt
// Fornece segurança para armazenamento de credenciais

import 'package:bcrypt/bcrypt.dart';

class PasswordService {
  // Custo do bcrypt (número de rounds) - quanto maior, mais seguro mas mais lento
  // 12 é um bom equilíbrio entre segurança e performance
  static const int _saltRounds = 12;

  /// Gera um hash bcrypt para a senha fornecida
  /// 
  /// Exemplo:
  /// ```dart
  /// final hash = PasswordService.hashPassword('minhaSenha123');
  /// // Retorna: $2b$12$KIXx8VfN5q2.Q1Qr...
  /// ```
  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: _saltRounds));
  }

  /// Verifica se a senha fornecida corresponde ao hash armazenado
  /// 
  /// Exemplo:
  /// ```dart
  /// final isValid = PasswordService.verifyPassword(
  ///   'minhaSenha123',
  ///   storedHash,
  /// );
  /// // Retorna: true se a senha está correta
  /// ```
  static bool verifyPassword(String password, String hashedPassword) {
    try {
      return BCrypt.checkpw(password, hashedPassword);
    } catch (e) {
      // Se ocorrer erro na verificação (hash inválido, etc), retorna false
      return false;
    }
  }

  /// Valida se a senha atende aos requisitos mínimos de segurança
  /// 
  /// Requisitos obrigatórios:
  /// - Mínimo de 8 caracteres
  /// - Pelo menos uma letra maiúscula
  /// - Pelo menos uma letra minúscula
  /// - Pelo menos um número
  /// - Pelo menos um caractere especial
  /// 
  /// Retorna uma mensagem de erro ou null se válida
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'A senha não pode estar vazia';
    }
    
    if (password.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    
    // Validação de comprimento máximo (previne ataques de DoS)
    if (password.length > 128) {
      return 'A senha não pode ter mais de 128 caracteres';
    }
    
    // Verifica se tem pelo menos uma letra maiúscula
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }
    
    // Verifica se tem pelo menos uma letra minúscula
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'A senha deve conter pelo menos uma letra minúscula';
    }
    
    // Verifica se tem pelo menos um número
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'A senha deve conter pelo menos um número';
    }
    
    // Verifica se tem pelo menos um caractere especial
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]').hasMatch(password)) {
      return 'A senha deve conter pelo menos um caractere especial (!@#\$%^&*(),.?":{}|<>_-+=[]\\\/~`)';
    }
    
    // Verifica senhas comuns/fracas (lista básica - expandir conforme necessário)
    final weakPasswords = [
      'password', 'password123', '12345678', 'qwerty123',
      'abc12345', 'Password1!', 'Admin123!', 'Welcome1!',
    ];
    
    if (weakPasswords.any((weak) => 
        password.toLowerCase().contains(weak.toLowerCase()))) {
      return 'Esta senha é muito comum. Escolha uma senha mais forte';
    }
    
    return null; // Senha válida
  }
  
  /// Calcula a força da senha (0-4)
  /// 
  /// 0 = Muito fraca
  /// 1 = Fraca
  /// 2 = Moderada
  /// 3 = Forte
  /// 4 = Muito forte
  /// 
  /// Exemplo:
  /// ```dart
  /// final strength = PasswordService.getPasswordStrength('Abc123!@#');
  /// // Retorna: 3 (Forte)
  /// ```
  static int getPasswordStrength(String password) {
    if (password.isEmpty) return 0;
    
    var strength = 0;
    
    // Comprimento
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    
    // Variedade de caracteres
    if (RegExp(r'[a-z]').hasMatch(password) && 
        RegExp(r'[A-Z]').hasMatch(password)) strength++;
    
    if (RegExp(r'[0-9]').hasMatch(password)) strength++;
    
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/~`]').hasMatch(password)) {
      strength++;
    }
    
    // Penaliza senhas comuns
    final weakPasswords = [
      'password', '12345678', 'qwerty', 'abc123',
    ];
    
    if (weakPasswords.any((weak) => 
        password.toLowerCase().contains(weak.toLowerCase()))) {
      strength = (strength - 2).clamp(0, 4);
    }
    
    return strength.clamp(0, 4);
  }
  
  /// Gera uma sugestão de senha forte
  /// 
  /// Exemplo:
  /// ```dart
  /// final suggestion = PasswordService.generateStrongPassword();
  /// // Retorna algo como: "Kx7@mP2#Qw9!"
  /// ```
  static String generateStrongPassword({int length = 16}) {
    if (length < 8) length = 8;
    if (length > 128) length = 128;
    
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const numbers = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';
    
    final random = DateTime.now().millisecondsSinceEpoch;
    var password = '';
    
    // Garante pelo menos um de cada tipo
    password += uppercase[random % uppercase.length];
    password += lowercase[(random * 2) % lowercase.length];
    password += numbers[(random * 3) % numbers.length];
    password += special[(random * 5) % special.length];
    
    // Preenche o resto aleatoriamente
    final allChars = uppercase + lowercase + numbers + special;
    for (var i = password.length; i < length; i++) {
      password += allChars[(random * (i + 7)) % allChars.length];
    }
    
    // Embaralha a senha (shuffle simples)
    final chars = password.split('')..shuffle();
    return chars.join();
  }
}
