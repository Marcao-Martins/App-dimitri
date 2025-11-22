import 'dart:convert';
import '../features/parametros_guide/models/parametro.dart';
import '../core/config/api_config.dart';
import 'api_service.dart';

/// Serviço administrativo para gerenciar parâmetros veterinários
class AdminParameterService {
  /// Carrega parâmetros consultando o endpoint `/api/parameters` e
  /// converte o formato em `List<Parametro>` agrupando por nome do parâmetro
  static Future<List<Parametro>> loadParametersFromCSV() async {
    try {
      final response = await ApiService.get(ApiConfig.parametersEndpoint);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception('Falha ao carregar parâmetros: status ${response.statusCode}');
      }

      final data = json.decode(response.body) as List<dynamic>;

      // Agrupar por parâmetro (assumindo que o backend retorna registros por espécie)
      final Map<String, Map<String, String>> grouped = {};
      for (final item in data) {
        final m = Map<String, dynamic>.from(item as Map);
        final name = (m['parameter_name'] ?? m['parameter'] ?? m['name'] ?? '').toString();
        final species = (m['species'] ?? '').toString();
        final value = (m['parameter_value'] ?? m['value'] ?? '').toString();

        grouped.putIfAbsent(name, () => {'dog': '', 'cat': '', 'horse': ''});
        if (species == 'dog') grouped[name]!['dog'] = value;
        if (species == 'cat') grouped[name]!['cat'] = value;
        if (species == 'horse') grouped[name]!['horse'] = value;
      }

      final parametros = <Parametro>[];
      grouped.forEach((nome, map) {
        parametros.add(Parametro(
          nome: nome,
          cao: map['dog'] ?? '',
          gato: map['cat'] ?? '',
          cavalo: map['horse'] ?? '',
          comentarios: '',
          referencias: '',
        ));
      });

      return parametros;
    } catch (e) {
      throw Exception('Erro ao carregar parâmetros: $e');
    }
  }
  
  /// Salva parâmetros de volta no CSV (stub para futura implementação)
  static Future<void> saveParametersToCSV(List<Parametro> parameters) async {
    // TODO: Implementar persistência em banco de dados
    throw UnimplementedError('Salvar parâmetros ainda não implementado');
  }
  
  /// Atualiza um parâmetro existente via API
  static Future<Parametro> updateParameter(
    String nome,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiService.put(
        '${ApiConfig.adminParametrosEndpoint}/$nome',
        body: data,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final parameterData = responseData['data'] as Map<String, dynamic>;
        
        // Criar Parametro a partir dos dados retornados
        return Parametro(
          nome: parameterData['nome'] as String,
          cao: parameterData['cao'] as String,
          gato: parameterData['gato'] as String,
          cavalo: parameterData['cavalo'] as String,
          comentarios: parameterData['comentarios'] as String? ?? '',
          referencias: parameterData['referencias'] as String? ?? '',
        );
      } else if (response.statusCode == 401) {
        throw Exception('Não autorizado. Faça login novamente.');
      } else if (response.statusCode == 403) {
        throw Exception('Acesso negado. Apenas administradores podem atualizar parâmetros.');
      } else if (response.statusCode == 404) {
        throw Exception('Parâmetro não encontrado.');
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Erro ao atualizar parâmetro');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Erro ao atualizar parâmetro: $e');
    }
  }
  
  /// Deleta um parâmetro (stub para futura implementação)
  static Future<void> deleteParameter(String name) async {
    // TODO: Implementar deleção via API
    throw UnimplementedError('Deletar parâmetro ainda não implementado');
  }
  
  /// Parser manual customizado para lidar com o formato do CSV
  static List<List<dynamic>> _parseCustomCsv(List<String> lines) {
    final result = <List<dynamic>>[];
    
    for (final line in lines) {
      final fields = <String>[];
      var currentField = '';
      var insideQuotes = false;
      
      for (int i = 0; i < line.length; i++) {
        final char = line[i];
        final nextChar = i + 1 < line.length ? line[i + 1] : '';
        
        if (char == '"') {
          if (nextChar == '"' && insideQuotes) {
            currentField += '"';
            i++;
          } else {
            insideQuotes = !insideQuotes;
          }
        } else if (char == ',' && !insideQuotes) {
          fields.add(currentField.trim());
          currentField = '';
        } else {
          currentField += char;
        }
      }
      
      fields.add(currentField.trim());
      
      while (fields.isNotEmpty && fields.last.isEmpty) {
        fields.removeLast();
      }
      
      if (fields.isNotEmpty) {
        result.add(fields);
      }
    }
    
    return result;
  }
}

