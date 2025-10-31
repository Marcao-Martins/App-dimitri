// lib/models/user.dart
// Modelo de dados para usuários do sistema
// Suporta dois níveis de acesso: consumer e administrator

enum UserRole {
  consumer,
  administrator;

  /// Converte string para UserRole
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'administrator':
        return UserRole.administrator;
      case 'consumer':
      default:
        return UserRole.consumer;
    }
  }

  /// Converte UserRole para string
  String toJson() => name;
}

class User {
  final String id;
  final String name;
  final String email;
  final String password; // Hash da senha (bcrypt)
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.consumer,
  });

  /// Cria uma instância de User a partir de um Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      role: UserRole.fromString(json['role']?.toString() ?? 'consumer'),
    );
  }

  /// Converte a instância de User para Map (JSON)
  /// Inclui a senha hasheada - use toJsonSafe() para resposta da API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'role': role.toJson(),
    };
  }

  /// Converte para JSON sem incluir a senha (para respostas da API)
  Map<String, dynamic> toJsonSafe() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toJson(),
    };
  }

  /// Cria uma cópia da instância com campos atualizados
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }

  /// Verifica se o usuário é administrador
  bool get isAdmin => role == UserRole.administrator;
}
