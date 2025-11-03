/// Configuração central da API
class ApiConfig {
  // URL base da API - será configurada automaticamente pelo script
  static String _baseUrl = 'http://localhost:8080';
  
  /// Obtém a URL base atual
  static String get baseUrl => _baseUrl;
  
  /// Define a URL base (útil para diferentes ambientes)
  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }
  
  /// Endpoints da API
  static const String apiVersion = '/api/v1';
  
  // Auth endpoints
  static String get loginEndpoint => '$_baseUrl$apiVersion/auth/login';
  static String get registerEndpoint => '$_baseUrl$apiVersion/auth/register';
  static String get validateTokenEndpoint => '$_baseUrl$apiVersion/auth/validate';
  
  // Farmacos endpoints
  static String get farmacosEndpoint => '$_baseUrl$apiVersion/farmacos';
  static String farmacosSearchEndpoint(String query) => 
      '$_baseUrl$apiVersion/farmacos/search?q=$query';
  static String farmacosBySpeciesEndpoint(String species) => 
      '$_baseUrl$apiVersion/farmacos/species/$species';
  
  // Admin farmacos endpoints
  static String get adminFarmacosEndpoint => '$_baseUrl$apiVersion/admin/farmacos';
  
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
