import '../models/medication.dart';

/// Serviço de dados de medicamentos veterinários
/// Preparado para integração com back-end
/// Os dados serão carregados de uma API externa
class MedicationService {
  /// Lista de medicamentos (será populada via back-end)
  static final List<Medication> _medications = [];
  
  /// Indica se os dados já foram carregados
  static bool _isLoaded = false;
  
  /// Verifica se os medicamentos já foram carregados
  static bool get isLoaded => _isLoaded;
  
  /// TODO: Implementar método para carregar dados do back-end
  /// Exemplo de implementação:
  /// 
  /// ```dart
  /// static Future<void> loadMedicationsFromBackend() async {
  ///   try {
  ///     final response = await http.get(
  ///       Uri.parse('https://api.example.com/medications'),
  ///       headers: {'Content-Type': 'application/json'},
  ///     );
  ///     
  ///     if (response.statusCode == 200) {
  ///       final List<dynamic> data = json.decode(response.body);
  ///       _medications.clear();
  ///       _medications.addAll(
  ///         data.map((json) => Medication.fromJson(json)).toList()
  ///       );
  ///       _isLoaded = true;
  ///     } else {
  ///       throw Exception('Falha ao carregar medicamentos');
  ///     }
  ///   } catch (e) {
  ///     print('Erro ao carregar medicamentos: $e');
  ///     rethrow;
  ///   }
  /// }
  /// ```
  
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
