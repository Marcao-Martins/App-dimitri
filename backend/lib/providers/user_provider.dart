// lib/providers/user_provider.dart
// Provedor de dados para usuários (PLACEHOLDER - arquivo JSON)
// Em produção, substitua por conexão com banco de dados real

import 'dart:convert';
import 'dart:io';
import '../models/user.dart';
import '../services/password_service.dart';

class UserProvider {
  final String _filePath = 'data/users.json';
  List<User> _users = [];

  /// Retorna a lista de usuários (somente leitura)
  List<User> get users => List.unmodifiable(_users);

  /// Inicializa o provider carregando os dados do JSON
  /// 
  /// Se o arquivo não existir, cria um novo com lista vazia
  /// 
  /// Exemplo de uso:
  /// ```dart
  /// final userProvider = UserProvider();
  /// await userProvider.initialize();
  /// ```
  Future<void> initialize() async {
    try {
      final file = File(_filePath);
      
      if (!await file.exists()) {
        // Cria arquivo JSON vazio se não existir
        await file.create(recursive: true);
        await file.writeAsString('[]');
        print('✅ Arquivo users.json criado');
        return;
      }

      final content = await file.readAsString();
      
      if (content.trim().isEmpty || content.trim() == '[]') {
        print('✅ Nenhum usuário encontrado - banco vazio');
        return;
      }

      final jsonList = jsonDecode(content) as List<dynamic>;
      _users = jsonList
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();

      print('✅ ${_users.length} usuários carregados do JSON');
    } catch (e) {
      print('❌ Erro ao carregar usuários: $e');
      rethrow;
    }
  }

  /// Salva os usuários no arquivo JSON
  /// 
  /// NOTA: Em produção, cada operação deve persistir diretamente no banco
  /// Esta abordagem de salvar toda a lista é ineficiente e não escalável
  Future<void> _saveToFile() async {
    try {
      final file = File(_filePath);
      final jsonList = _users.map((user) => user.toJson()).toList();
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(jsonList),
      );
    } catch (e) {
      print('❌ Erro ao salvar usuários: $e');
      rethrow;
    }
  }

  /// Busca um usuário pelo email
  /// 
  /// Retorna null se o usuário não for encontrado
  User? findUserByEmail(String email) {
    try {
      return _users.firstWhere(
        (user) => user.email.toLowerCase() == email.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Busca um usuário pelo ID
  User? findUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Verifica se um email já está em uso
  bool emailExists(String email) {
    return findUserByEmail(email) != null;
  }

  /// Cria um novo usuário
  /// 
  /// A senha é automaticamente hasheada antes de salvar
  /// 
  /// Retorna o usuário criado (sem a senha)
  /// Lança exceção se o email já existir
  Future<User> createUser({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.consumer,
  }) async {
    // Validações
    if (emailExists(email)) {
      throw Exception('Email já está em uso');
    }

    final passwordError = PasswordService.validatePassword(password);
    if (passwordError != null) {
      throw Exception(passwordError);
    }

    // Gera ID único (em produção, use UUID ou ID do banco de dados)
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // Hash da senha
    final hashedPassword = PasswordService.hashPassword(password);

    // Cria usuário
    final user = User(
      id: id,
      name: name,
      email: email,
      password: hashedPassword,
      role: role,
    );

    // Adiciona à lista e salva
    _users.add(user);
    await _saveToFile();

    print('✅ Usuário criado: ${user.email} (${user.role.name})');
    
    return user;
  }

  /// Valida as credenciais do usuário
  /// 
  /// Retorna o usuário se as credenciais forem válidas, null caso contrário
  User? validateCredentials(String email, String password) {
    final user = findUserByEmail(email);
    
    if (user == null) {
      return null;
    }

    final isValid = PasswordService.verifyPassword(password, user.password);
    
    return isValid ? user : null;
  }

  /// Atualiza um usuário existente
  /// 
  /// NOTA: Se alterar a senha, ela deve ser hasheada antes de chamar este método
  Future<bool> updateUser(String id, User updatedUser) async {
    final index = _users.indexWhere((user) => user.id == id);
    
    if (index == -1) {
      return false;
    }

    _users[index] = updatedUser;
    await _saveToFile();
    
    print('✅ Usuário atualizado: ${updatedUser.email}');
    
    return true;
  }

  /// Remove um usuário
  Future<bool> deleteUser(String id) async {
    final initialLength = _users.length;
    _users.removeWhere((user) => user.id == id);
    
    if (_users.length < initialLength) {
      await _saveToFile();
      print('✅ Usuário removido: $id');
      return true;
    }
    
    return false;
  }

  /// Obtém estatísticas dos usuários
  Map<String, dynamic> getStats() {
    final consumerCount = _users.where((u) => !u.isAdmin).length;
    final adminCount = _users.where((u) => u.isAdmin).length;

    return {
      'total': _users.length,
      'consumers': consumerCount,
      'administrators': adminCount,
    };
  }
}
