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
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = responseData['data'] as List<dynamic>;
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
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = responseData['data'] as List<dynamic>;
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
        final responseData = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = responseData['data'] as List<dynamic>;
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
    // Extrai a posologia de cães para análise de dose
    final dogDosage = json['posologia_caes']?.toString() ?? '';
    final doseParts = _parseDose(dogDosage);
    
    // Define espécies com base na posologia disponível
    final species = <String>[];
    if (json['posologia_caes']?.toString().isNotEmpty ?? false) {
      species.add('Cão');
    }
    if (json['posologia_gatos']?.toString().isNotEmpty ?? false) {
      species.add('Gato');
    }
    if (species.isEmpty) {
      species.add('Não especificado');
    }

    return Medication(
      id: json['post_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['farmaco']?.toString() ?? json['name']?.toString() ?? '',
      category: json['classe_farmacologica']?.toString() ?? json['category']?.toString() ?? '',
      species: species,
      minDose: doseParts['minDose']!,
      maxDose: doseParts['maxDose']!,
      unit: doseParts['unit']!,
      tradeName: json['nome_comercial']?.toString(),
      mechanismOfAction: json['mecanismo_de_acao']?.toString(),
      dogDosage: json['posologia_caes']?.toString(),
      catDosage: json['posologia_gatos']?.toString(),
      cri: json['ivc']?.toString(),
      comments: json['comentarios']?.toString(),
      references: json['referencia']?.toString(),
      link: json['link']?.toString(),
      indications: json['indicacoes']?.toString() ?? json['indications']?.toString(),
      contraindications: json['contraindicacoes']?.toString() ?? json['contraindications']?.toString(),
      precautions: json['observacoes']?.toString() ?? json['precautions']?.toString(),
      description: json['titulo']?.toString() ?? json['description']?.toString(),
    );
  }

  /// Analisa a string de dose para extrair min, max e unidade.
  /// Ex: "0.1-0.2 mg/kg" -> {min: 0.1, max: 0.2, unit: "mg/kg"}
  static Map<String, dynamic> _parseDose(String doseString) {
    doseString = doseString.replaceAll(',', '.');
    final RegExp doseRegex = RegExp(r'([\d\.]+)(?:-([\d\.]+))?\s*(\w+\/\w+)');
    final match = doseRegex.firstMatch(doseString);

    if (match != null) {
      final minDose = double.tryParse(match.group(1)!) ?? 0.0;
      final maxDose = double.tryParse(match.group(2) ?? match.group(1)!) ?? minDose;
      final unit = match.group(3) ?? 'mg/kg';
      return {'minDose': minDose, 'maxDose': maxDose, 'unit': unit};
    }

    return {'minDose': 0.0, 'maxDose': 0.0, 'unit': 'N/A'};
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
  
  /// Retorna todas as categorias disponíveis (alias)
  static List<String> getCategories() => getAllCategories();
  
  /// Retorna todas as espécies suportadas
  static List<String> getAllSpecies() {
    final allSpecies = <String>{};
    for (var med in _medications) {
      allSpecies.addAll(med.species);
    }
    return allSpecies.toList()..sort();
  }
}
