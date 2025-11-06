import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'models/parametro.dart';

enum Species { cao, gato, cavalo }

class ParametrosController extends ChangeNotifier {
  List<Parametro> _parametros = [];
  List<Parametro> _filteredParametros = [];
  Species _selectedSpecies = Species.cao;
  String _searchTerm = '';

  List<Parametro> get filteredParametros => _filteredParametros;
  Species get selectedSpecies => _selectedSpecies;

  ParametrosController() {
    loadParametros();
  }

  Future<void> loadParametros() async {
    try {
      final data = await rootBundle.loadString('Tabela_parâmetros.csv');
      final List<List<dynamic>> csvTable =
          const CsvToListConverter(fieldDelimiter: ';').convert(data);

      // Skip header
      _parametros = csvTable.skip(1).map((row) => Parametro.fromCsv(row)).toList();
      _filterParametros();
    } catch (e) {
      // Handle error
      print('Error loading parameters: $e');
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
}
