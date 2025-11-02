import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

/// Serviço base para comunicação com a API
class ApiService {
  /// Cliente HTTP reutilizável
  static final http.Client _client = http.Client();
  
  /// Token de autenticação atual
  static String? _authToken;
  
  /// Define o token de autenticação
  static void setAuthToken(String? token) {
    _authToken = token;
  }
  
  /// Obtém o token atual
  static String? get authToken => _authToken;
  
  /// Limpa o token (logout)
  static void clearAuthToken() {
    _authToken = null;
  }
  
  /// Verifica se há um token válido
  static bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;
  
  /// Requisição GET
  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      final requestHeaders = _buildHeaders(headers, requiresAuth);
      
      final response = await _client
          .get(Uri.parse(url), headers: requestHeaders)
          .timeout(ApiConfig.requestTimeout);
      
      return response;
    } on SocketException {
      throw Exception('Sem conexão com a internet');
    } on HttpException {
      throw Exception('Erro na comunicação com o servidor');
    } on FormatException {
      throw Exception('Resposta inválida do servidor');
    } catch (e) {
      throw Exception('Erro ao fazer requisição: $e');
    }
  }
  
  /// Requisição POST
  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = false,
  }) async {
    try {
      final requestHeaders = _buildHeaders(headers, requiresAuth);
      final encodedBody = body != null ? json.encode(body) : null;
      
      final response = await _client
          .post(
            Uri.parse(url),
            headers: requestHeaders,
            body: encodedBody,
          )
          .timeout(ApiConfig.requestTimeout);
      
      return response;
    } on SocketException {
      throw Exception('Sem conexão com a internet');
    } on HttpException {
      throw Exception('Erro na comunicação com o servidor');
    } on FormatException {
      throw Exception('Resposta inválida do servidor');
    } catch (e) {
      throw Exception('Erro ao fazer requisição: $e');
    }
  }
  
  /// Requisição PUT
  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = false,
  }) async {
    try {
      final requestHeaders = _buildHeaders(headers, requiresAuth);
      final encodedBody = body != null ? json.encode(body) : null;
      
      final response = await _client
          .put(
            Uri.parse(url),
            headers: requestHeaders,
            body: encodedBody,
          )
          .timeout(ApiConfig.requestTimeout);
      
      return response;
    } on SocketException {
      throw Exception('Sem conexão com a internet');
    } on HttpException {
      throw Exception('Erro na comunicação com o servidor');
    } on FormatException {
      throw Exception('Resposta inválida do servidor');
    } catch (e) {
      throw Exception('Erro ao fazer requisição: $e');
    }
  }
  
  /// Requisição DELETE
  static Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    bool requiresAuth = false,
  }) async {
    try {
      final requestHeaders = _buildHeaders(headers, requiresAuth);
      
      final response = await _client
          .delete(Uri.parse(url), headers: requestHeaders)
          .timeout(ApiConfig.requestTimeout);
      
      return response;
    } on SocketException {
      throw Exception('Sem conexão com a internet');
    } on HttpException {
      throw Exception('Erro na comunicação com o servidor');
    } on FormatException {
      throw Exception('Resposta inválida do servidor');
    } catch (e) {
      throw Exception('Erro ao fazer requisição: $e');
    }
  }
  
  /// Constrói os headers da requisição
  static Map<String, String> _buildHeaders(
    Map<String, String>? customHeaders,
    bool requiresAuth,
  ) {
    final headers = <String, String>{...ApiConfig.defaultHeaders};
    
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    
    if (requiresAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  /// Testa a conexão com o backend
  static Future<bool> testConnection() async {
    try {
      final response = await get(ApiConfig.farmacosEndpoint)
          .timeout(const Duration(seconds: 5));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      return false;
    }
  }
  
  /// Fecha o cliente HTTP
  static void dispose() {
    _client.close();
  }
}
