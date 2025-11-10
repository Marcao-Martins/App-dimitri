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
      // DISPOSITIVO FÍSICO Android - usando IP da rede local
      // Certifique-se que:
      // 1. Seu celular e computador estão na mesma rede Wi-Fi
      // 2. O backend está rodando em http://localhost:8080
      // 3. O firewall do Windows permite conexões na porta 8080
      return 'http://172.20.10.4:8080'; // <-- IP LOCAL CORRETO (Wi-Fi)
      
      // Para EMULADOR Android, use esta linha:
      // return 'http://10.0.2.2:8080';
    } else if (Platform.isIOS) {
      // iOS Simulator: localhost funciona
      // 
      // IMPORTANTE: Para dispositivo físico iOS:
      // 1. Encontre o IP da sua máquina na rede local
      // 2. Substitua abaixo por: 'http://SEU_IP_LOCAL:8080'
      // 3. Certifique-se que o backend está rodando e acessível na rede
      // 4. Ambos (dispositivo e Mac) devem estar na mesma rede Wi-Fi
      // Exemplo: return 'http://192.168.1.100:8080';
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
  
  /// Timeout padrão para requisições (aumentado para dispositivos físicos)
  static const Duration requestTimeout = Duration(seconds: 60);
  
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
