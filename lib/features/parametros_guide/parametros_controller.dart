import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'models/parametro.dart';

enum Species { cao, gato, cavalo }

class ParametrosController extends ChangeNotifier {
  List<Parametro> _parametros = [];
  List<Parametro> _filteredParametros = [];
  Species _selectedSpecies = Species.cao;
  String _searchTerm = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Parametro> get filteredParametros => _filteredParametros;
  Species get selectedSpecies => _selectedSpecies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ParametrosController() {
    loadParametros();
  }

  Future<void> loadParametros() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      
      final data = await rootBundle.loadString('Tabela_parâmetros.csv');
      
      // Estratégia: Uma linha real é aquela que começa com um caractere não-espaço (OU é a primeira linha)
      // Toda linha que começa com espaço/tab é continuação
      final lines = data.split('\n');
      final normalizedLines = <String>[];
      var currentLine = '';
      
      for (int idx = 0; idx < lines.length; idx++) {
        final line = lines[idx];
        
        // Uma linha é "real" se:
        // 1. É a primeira linha (idx==0), OU
        // 2. Não começa com espaço/tab
        final isNewLogicalLine = (idx == 0) || 
            (line.isNotEmpty && !line.startsWith(' ') && !line.startsWith('\t'));
        
        if (isNewLogicalLine) {
          // Salvar a linha anterior se existir
          if (currentLine.isNotEmpty) {
            // Remover quebras de linha INTERNAS desta linha
            final cleanedLine = currentLine.replaceAll('\r\n', ' ').replaceAll('\n', ' ').replaceAll('\r', ' ');
            normalizedLines.add(cleanedLine);
          }
          // Começar uma nova linha lógica
          currentLine = line;
        } else {
          // Continuação: juntar à linha anterior
          if (line.isNotEmpty) {
            currentLine += ' ' + line.trim();
          }
        }
      }
      // Salvar a última linha
      if (currentLine.isNotEmpty) {
        final cleanedLine = currentLine.replaceAll('\r\n', ' ').replaceAll('\n', ' ').replaceAll('\r', ' ');
        normalizedLines.add(cleanedLine);
      }
      
      // PARSER MANUAL CUSTOMIZADO
      // CsvToListConverter não funciona por causa da formatação estranha (muitos espaços)
      final csvTable = _parseCustomCsv(normalizedLines);
      
      print('DEBUG: Parsed ${csvTable.length} rows');
      if (csvTable.isNotEmpty) {
        print('DEBUG: First row has ${csvTable[0].length} fields');
      }
      if (csvTable.length > 1) {
        print('DEBUG: Second row has ${csvTable[1].length} fields');
      }

      // Skip header (primeira linha)
      _parametros = csvTable.skip(1).map((row) {
        // Verifica se a linha tem dados suficientes
        if (row.length >= 6) {
          return Parametro.fromCsv(row);
        }
        return null;
      }).whereType<Parametro>().toList();
      
      print('DEBUG: Successfully parsed ${_parametros.length} parameters');
      
      _filterParametros();
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      // Handle error
      _isLoading = false;
      _errorMessage = 'Erro ao carregar parâmetros: $e';
      print('ERROR: $e');
      notifyListeners();
    }
  }

  void _filterParametros() {
    List<Parametro> tempParametros = _parametros;

    if (_searchTerm.isNotEmpty) {
      tempParametros = tempParametros
          .where((p) => p.nome.toLowerCase().contains(_searchTerm.toLowerCase()))
          .toList();
    }

    _filteredParametros = tempParametros;
    notifyListeners();
  }

  void setSearchTerm(String term) {
    _searchTerm = term;
    _filterParametros();
  }

  void setSelectedSpecies(Species species) {
    _selectedSpecies = species;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadParametros();
  }

  /// Parser manual customizado para lidar com o formato estranho do CSV
  /// Estratégia: dividir cada linha por `,` mas respeitar campos entre aspas
  List<List<dynamic>> _parseCustomCsv(List<String> lines) {
    final result = <List<dynamic>>[];
    
    for (final line in lines) {
      final fields = <String>[];
      var currentField = '';
      var insideQuotes = false;
      
      for (int i = 0; i < line.length; i++) {
        final char = line[i];
        final nextChar = i + 1 < line.length ? line[i + 1] : '';
        
        if (char == '"') {
          // Toggle quote mode
          // Escapar quotes: "" dentro de um campo quoted se torna uma única "
          if (nextChar == '"' && insideQuotes) {
            currentField += '"';
            i++; // Skip next quote
          } else {
            insideQuotes = !insideQuotes;
          }
        } else if (char == ',' && !insideQuotes) {
          // Fim do campo
          fields.add(currentField.trim());
          currentField = '';
        } else {
          currentField += char;
        }
      }
      
      // Adicionar o último campo
      fields.add(currentField.trim());
      
      // Limpar campos vazios no final (por causa dos muitos espaços no header)
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

