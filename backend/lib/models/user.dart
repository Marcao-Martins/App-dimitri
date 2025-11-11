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

enum UserStatus {
  active,
  inactive,
  suspended;

  /// Converte string para UserStatus
  static UserStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'suspended':
        return UserStatus.suspended;
      default:
        return UserStatus.active;
    }
  }

  /// Converte UserStatus para string
  String toJson() => name;
}

class User {
  final String id; // UUID v4
  final String name;
  final String email; // Único
  final String password; // Hash da senha (bcrypt)
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt; // Soft delete
  final DateTime? lastLoginAt;
  final int failedLoginAttempts;
  final DateTime? lockedUntil; // Bloqueio temporário após muitas tentativas
  final String? phoneNumber; // Opcional
  final String? profileImageUrl; // Opcional

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.consumer,
    this.status = UserStatus.active,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.deletedAt,
    this.lastLoginAt,
    this.failedLoginAttempts = 0,
    this.lockedUntil,
    this.phoneNumber,
    this.profileImageUrl,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Cria uma instância de User a partir de um Map (JSON)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      role: UserRole.fromString(json['role']?.toString() ?? 'consumer'),
      status: UserStatus.fromString(json['status']?.toString() ?? 'active'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'].toString())
          : null,
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'].toString())
          : null,
      failedLoginAttempts: json['failedLoginAttempts'] as int? ?? 0,
      lockedUntil: json['lockedUntil'] != null
          ? DateTime.parse(json['lockedUntil'].toString())
          : null,
      phoneNumber: json['phoneNumber']?.toString(),
      profileImageUrl: json['profileImageUrl']?.toString(),
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
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'failedLoginAttempts': failedLoginAttempts,
      'lockedUntil': lockedUntil?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Converte para JSON sem incluir a senha (para respostas da API)
  Map<String, dynamic> toJsonSafe() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toJson(),
      'status': status.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
    };
  }

  /// Cria uma cópia da instância com campos atualizados
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    DateTime? lastLoginAt,
    int? failedLoginAttempts,
    DateTime? lockedUntil,
    String? phoneNumber,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      failedLoginAttempts: failedLoginAttempts ?? this.failedLoginAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }

  /// Verifica se o usuário é administrador
  bool get isAdmin => role == UserRole.administrator;

  /// Verifica se o usuário está ativo
  bool get isActive => status == UserStatus.active && deletedAt == null;

  /// Verifica se o usuário está bloqueado
  bool get isLocked {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  /// Verifica se a conta foi excluída (soft delete)
  bool get isDeleted => deletedAt != null;
}
