import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';
import 'api_service.dart';

/// Modelo de usuário autenticado
class AuthUser {
  final String id;
  final String email;
  final String role;
  final String token;
  
  AuthUser({
    required this.id,
    required this.email,
    required this.role,
    required this.token,
  });
  
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['user']['id'] as String,
      email: json['user']['email'] as String,
      role: json['user']['role'] as String,
      token: json['token'] as String,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'role': role,
    'token': token,
  };
  
  bool get isAdmin => role == 'administrator';
}

/// Serviço de autenticação
class AuthService extends ChangeNotifier {
  static const String _storageKey = 'auth_user';
  AuthUser? _currentUser;
  
  /// Usuário atual autenticado
  AuthUser? get currentUser => _currentUser;
  
  /// Verifica se está autenticado
  bool get isAuthenticated => _currentUser != null;
  
  /// Verifica se é administrador
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  
  /// Inicializa o serviço (carrega usuário do storage)
  Future<void> init() async {
    await _loadUserFromStorage();
    if (_currentUser != null) {
      ApiService.setAuthToken(_currentUser!.token);
    }
  }
  
  /// Faz login
  Future<AuthUser> login(String email, String password) async {
    try {
      final response = await ApiService.post(
        ApiConfig.loginEndpoint,
        body: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final user = AuthUser.fromJson(data);
        
        await _saveUser(user);
        _currentUser = user;
        ApiService.setAuthToken(user.token);
        notifyListeners();
        
        return user;
      } else if (response.statusCode == 401) {
        throw Exception('Email ou senha incorretos');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erro ao fazer login');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao fazer login: $e');
    }
  }
  
  /// Registra novo usuário
  Future<AuthUser> register(String email, String password) async {
    try {
      final response = await ApiService.post(
        ApiConfig.registerEndpoint,
        body: {
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final user = AuthUser.fromJson(data);
        
        await _saveUser(user);
        _currentUser = user;
        ApiService.setAuthToken(user.token);
        
        return user;
      } else if (response.statusCode == 409) {
        throw Exception('Este email já está cadastrado');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erro ao registrar');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao registrar: $e');
    }
  }
  
  /// Valida o token atual
  Future<bool> validateToken() async {
    if (_currentUser == null) return false;
    
    try {
      final response = await ApiService.get(
        ApiConfig.validateTokenEndpoint,
        requiresAuth: true,
      );
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  /// Faz logout
  Future<void> logout() async {
    _currentUser = null;
    ApiService.clearAuthToken();
    await _clearStorage();
    notifyListeners();
  }
  
  /// Salva usuário no storage
  Future<void> _saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, json.encode(user.toJson()));
  }
  
  /// Carrega usuário do storage
  Future<void> _loadUserFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_storageKey);
      
      if (userData != null) {
        final userJson = json.decode(userData);
        _currentUser = AuthUser(
          id: userJson['id'],
          email: userJson['email'],
          role: userJson['role'],
          token: userJson['token'],
        );
      }
    } catch (e) {
      // Se houver erro ao carregar, ignora
      _currentUser = null;
    }
  }
  
  /// Limpa storage
  Future<void> _clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
