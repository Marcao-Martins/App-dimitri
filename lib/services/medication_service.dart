import 'dart:convert';
import '../models/medication.dart';
import '../core/config/api_config.dart';
import 'api_service.dart';

/// Serviço de dados de medicamentos veterinários
/// Integrado com back-end Dart Frog
class MedicationService {
  /// Lista de medicamentos em cache
  static final List<Medication> _medications = [];
  
  /// Indica se os dados já foram carregados
  static bool _isLoaded = false;
  
  /// Timestamp do último carregamento
  static DateTime? _lastLoadTime;
  
  /// Tempo de cache (5 minutos)
  static const Duration _cacheTimeout = Duration(minutes: 5);
  
  /// Verifica se os medicamentos já foram carregados
  static bool get isLoaded => _isLoaded;
  
  /// Verifica se o cache está válido
  static bool get isCacheValid {
    if (_lastLoadTime == null) return false;
    return DateTime.now().difference(_lastLoadTime!) < _cacheTimeout;
  }
  
  /// Carrega medicamentos do backend
  static Future<void> loadMedicationsFromBackend({bool forceRefresh = false}) async {
    // Se o cache é válido e não é refresh forçado, não recarrega
    if (!forceRefresh && _isLoaded && isCacheValid) {
      return;
    }
    
    try {
      final response = await ApiService.get(ApiConfig.farmacosEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _medications.clear();
        _medications.addAll(
          data.map((json) => _parseMedication(json)).toList(),
        );
        _isLoaded = true;
        _lastLoadTime = DateTime.now();
      } else {
        throw Exception('Falha ao carregar medicamentos: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar medicamentos: $e');
      rethrow;
    }
  }
  
  /// Busca medicamentos por query no backend
  static Future<List<Medication>> searchMedicationsOnline(String query) async {
    try {
      final response = await ApiService.get(
        ApiConfig.farmacosSearchEndpoint(Uri.encodeComponent(query)),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _parseMedication(json)).toList();
      } else {
        throw Exception('Falha ao buscar medicamentos');
      }
    } catch (e) {
      print('Erro ao buscar medicamentos: $e');
      // Se falhar, busca no cache local
      return searchByName(query);
    }
  }
  
  /// Busca medicamentos por espécie no backend
  static Future<List<Medication>> getMedicationsBySpecies(String species) async {
    try {
      final response = await ApiService.get(
        ApiConfig.farmacosBySpeciesEndpoint(Uri.encodeComponent(species)),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => _parseMedication(json)).toList();
      } else {
        throw Exception('Falha ao buscar medicamentos por espécie');
      }
    } catch (e) {
      print('Erro ao buscar medicamentos por espécie: $e');
      // Se falhar, busca no cache local
      return filterBySpecies(species);
    }
  }
  
  /// Converte JSON do backend para Medication
  static Medication _parseMedication(Map<String, dynamic> json) {
    return Medication(
      id: json['id']?.toString() ?? '',
      name: json['farmaco']?.toString() ?? json['name']?.toString() ?? '',
      category: json['categoria']?.toString() ?? json['category']?.toString() ?? '',
      species: _parseSpecies(json['especie']?.toString() ?? json['species']?.toString() ?? ''),
      dosage: json['dose']?.toString() ?? json['dosage']?.toString() ?? '',
      route: json['via']?.toString() ?? json['route']?.toString() ?? '',
      frequency: json['frequencia']?.toString() ?? json['frequency']?.toString() ?? '',
      contraindications: json['contraindicacoes']?.toString() ?? 
                        json['contraindications']?.toString() ?? '',
      sideEffects: json['efeitos_adversos']?.toString() ?? 
                  json['sideEffects']?.toString() ?? '',
      observations: json['observacoes']?.toString() ?? 
                   json['observations']?.toString() ?? '',
    );
  }
  
  /// Parse das espécies do formato CSV
  static List<String> _parseSpecies(String speciesStr) {
    if (speciesStr.isEmpty) return [];
    return speciesStr
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  
  /// Adiciona um medicamento à lista (útil para testes ou adição manual)
  static void addMedication(Medication medication) {
    _medications.add(medication);
  }
  
  /// Remove todos os medicamentos (útil para reset)
  static void clearMedications() {
    _medications.clear();
    _isLoaded = false;
  }
  
  /// Define a lista completa de medicamentos
  static void setMedications(List<Medication> medications) {
    _medications.clear();
    _medications.addAll(medications);
    _isLoaded = true;
  }
  
  /// Retorna todos os medicamentos
  static List<Medication> getAllMedications() {
    return List.unmodifiable(_medications);
  }
  
  /// Busca medicamentos por nome
  static List<Medication> searchByName(String query) {
    if (query.isEmpty) return getAllMedications();
    
    final lowerQuery = query.toLowerCase();
    return _medications
        .where((med) => med.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
  
  /// Filtra medicamentos por espécie
  static List<Medication> filterBySpecies(String species) {
    return _medications
        .where((med) => med.isCompatibleWithSpecies(species))
        .toList();
  }
  
  /// Filtra medicamentos por categoria
  static List<Medication> filterByCategory(String category) {
    return _medications
        .where((med) => med.category == category)
        .toList();
  }
  
  /// Busca medicamento por ID
  static Medication? getMedicationById(String id) {
    try {
      return _medications.firstWhere((med) => med.id == id);
    } catch (e) {
      return null;
    }
  }
  
  /// Retorna todas as categorias disponíveis
  static List<String> getAllCategories() {
    return _medications
        .map((med) => med.category)
        .toSet()
        .toList()
      ..sort();
  }
  
  /// Retorna todas as espécies suportadas
  static List<String> getAllSpecies() {
    final allSpecies = <String>{};
    for (var med in _medications) {
      allSpecies.addAll(med.species);
    }
    return allSpecies.toList()..sort();
  }
}
