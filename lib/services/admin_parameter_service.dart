import 'package:flutter/services.dart';
import 'dart:convert';
import '../features/parametros_guide/models/parametro.dart';
import '../core/config/api_config.dart';
import 'api_service.dart';

/// Serviço administrativo para gerenciar parâmetros veterinários
class AdminParameterService {
  /// Carrega parâmetros do CSV local
  static Future<List<Parametro>> loadParametersFromCSV() async {
    try {
      final data = await rootBundle.loadString('Tabela_parâmetros.csv');
      
      // Normalizar CSV como no controller
      final lines = data.split('\n');
      final normalizedLines = <String>[];
      var currentLine = '';
      
      for (int idx = 0; idx < lines.length; idx++) {
        final line = lines[idx];
        final isNewLogicalLine = (idx == 0) || 
            (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t'));
        
        if (isNewLogicalLine) {
          if (currentLine.isNotEmpty) {
            final cleanedLine = currentLine.replaceAll('\r\n', ' ').replaceAll('\n', ' ').replaceAll('\r', ' ');
            normalizedLines.add(cleanedLine);
          }
          currentLine = line;
        } else {
          if (line.isNotEmpty) {
            currentLine += ' ' + line.trim();
          }
        }
      }
      if (currentLine.isNotEmpty) {
        final cleanedLine = currentLine.replaceAll('\r\n', ' ').replaceAll('\n', ' ').replaceAll('\r', ' ');
        normalizedLines.add(cleanedLine);
      }
      
      // Parser manual
      final csvTable = _parseCustomCsv(normalizedLines);
      
      // Skip header, processar dados
      final parametros = <Parametro>[];
      for (int i = 1; i < csvTable.length; i++) {
        final row = csvTable[i];
        if (row.length >= 6) {
          final parametro = Parametro.fromCsv(row);
          parametros.add(parametro);
        }
      }
      
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
