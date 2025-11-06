import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Configuração central da API
class ApiConfig {
  // URL base da API - configurada dinamicamente
  static String get baseUrl {
    if (kIsWeb) {
      // Em web, o navegador lida com localhost
      return 'http://localhost:8080';
    } else if (Platform.isAndroid) {
      // Emulador Android: use 10.0.2.2 para acessar localhost da máquina host
      // Dispositivo físico Android: você precisará usar o IP da sua máquina na rede local
      // Ex: 'http://192.168.1.100:8080'
      return 'http://10.0.2.2:8080';
    } else if (Platform.isIOS) {
      // iOS Simulator: localhost funciona
      // Dispositivo físico iOS: você precisará usar o IP da sua máquina na rede local
      return 'http://localhost:8080';
    } else {
      // Para desktop (Windows, Linux, macOS)
      return 'http://localhost:8080';
    }
  }
  
  /// Endpoints da API
  static const String apiVersion = '/api/v1';
  
  // Auth endpoints
  static String get loginEndpoint => '$baseUrl$apiVersion/auth/login';
  static String get registerEndpoint => '$baseUrl$apiVersion/auth/register';
  static String get validateTokenEndpoint => '$baseUrl$apiVersion/auth/validate';
  
  // Farmacos endpoints
  static String get farmacosEndpoint => '$baseUrl$apiVersion/farmacos';
  static String farmacosSearchEndpoint(String query) => 
      '$baseUrl$apiVersion/farmacos/search?q=$query';
  static String farmacosBySpeciesEndpoint(String species) => 
      '$baseUrl$apiVersion/farmacos/species/$species';
  
  // Admin farmacos endpoints
  static String get adminFarmacosEndpoint => '$baseUrl$apiVersion/admin/farmacos';
  
  /// Timeout padrão para requisições
  static const Duration requestTimeout = Duration(seconds: 30);
  
  /// Headers padrão
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  /// Headers com autenticação
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}
