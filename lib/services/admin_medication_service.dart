import 'dart:convert';
import '../models/medication.dart';
import '../core/config/api_config.dart';
import 'api_service.dart';

/// Serviço administrativo para gerenciar medicamentos
/// Requer autenticação de administrador
class AdminMedicationService {
  /// Cria um novo medicamento
  static Future<Medication> createMedication(Map<String, dynamic> data) async {
    try {
      final response = await ApiService.post(
        ApiConfig.adminFarmacosEndpoint,
        body: data,
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final medicationData = responseData['data'] as Map<String, dynamic>;
        return _parseMedication(medicationData);
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado. Faça login novamente.');
      } else if (response.statusCode == 403) {
        throw Exception('Acesso negado. Apenas administradores podem criar medicamentos.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao criar medicamento');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao criar medicamento: $e');
    }
  }

  /// Atualiza um medicamento existente
  static Future<Medication> updateMedication(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiService.put(
        '${ApiConfig.adminFarmacosEndpoint}/$id',
        body: data,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final medicationData = responseData['data'] as Map<String, dynamic>;
        return _parseMedication(medicationData);
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado. Faça login novamente.');
      } else if (response.statusCode == 403) {
        throw Exception('Acesso negado. Apenas administradores podem atualizar medicamentos.');
      } else if (response.statusCode == 404) {
        throw Exception('Medicamento não encontrado.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao atualizar medicamento');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao atualizar medicamento: $e');
    }
  }

  /// Deleta um medicamento
  static Future<void> deleteMedication(String id) async {
    try {
      final response = await ApiService.delete(
        '${ApiConfig.adminFarmacosEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado. Faça login novamente.');
      } else if (response.statusCode == 403) {
        throw Exception('Acesso negado. Apenas administradores podem deletar medicamentos.');
      } else if (response.statusCode == 404) {
        throw Exception('Medicamento não encontrado.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao deletar medicamento');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao deletar medicamento: $e');
    }
  }

  /// Busca um medicamento específico por ID
  static Future<Medication> getMedicationById(String id) async {
    try {
      final response = await ApiService.get(
        '${ApiConfig.adminFarmacosEndpoint}/$id',
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final medicationData = responseData['data'] as Map<String, dynamic>;
        return _parseMedication(medicationData);
      } else if (response.statusCode == 404) {
        throw Exception('Medicamento não encontrado.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao buscar medicamento');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao buscar medicamento: $e');
    }
  }

  /// Converte dados do backend para Medication
  static Medication _parseMedication(Map<String, dynamic> json) {
    // Extrai doses do formato "X-Y mg/kg" ou usa valores padrão
    double minDose = 0.0;
    double maxDose = 0.0;
    String unit = 'mg/kg';

    // Tenta extrair das posologias se disponível
    final dogDosage = json['posologia_caes']?.toString() ?? '';
    if (dogDosage.isNotEmpty) {
      final doseMatch = RegExp(r'(\d+\.?\d*)\s*-\s*(\d+\.?\d*)\s*([\w/]+)')
          .firstMatch(dogDosage);
      if (doseMatch != null) {
        minDose = double.tryParse(doseMatch.group(1) ?? '0') ?? 0.0;
        maxDose = double.tryParse(doseMatch.group(2) ?? '0') ?? 0.0;
        unit = doseMatch.group(3) ?? 'mg/kg';
      }
    }

    return Medication(
      id: json['post_id']?.toString() ?? '',
      name: json['farmaco']?.toString() ?? 'Sem nome',
      minDose: minDose,
      maxDose: maxDose,
      unit: unit,
      species: _parseSpecies(dogDosage, json['posologia_gatos']?.toString() ?? ''),
      category: json['classe_farmacologica']?.toString() ?? 'Não especificada',
      tradeName: json['nome_comercial']?.toString(),
      mechanismOfAction: json['mecanismo_de_acao']?.toString(),
      dogDosage: dogDosage.isNotEmpty ? dogDosage : null,
      catDosage: json['posologia_gatos']?.toString(),
      cri: json['ivc']?.toString(),
      comments: json['comentarios']?.toString(),
      references: json['referencia']?.toString(),
      link: json['link']?.toString(),
      description: json['titulo']?.toString(),
      indications: null,
      contraindications: null,
      precautions: null,
    );
  }

  /// Extrai espécies das posologias
  static List<String> _parseSpecies(String dogDosage, String catDosage) {
    final species = <String>[];
    if (dogDosage.isNotEmpty) species.add('Cão');
    if (catDosage.isNotEmpty) species.add('Gato');
    if (species.isEmpty) species.add('Não especificado');
    return species;
  }
}
