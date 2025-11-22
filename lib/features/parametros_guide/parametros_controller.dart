// CSV local removed; parameters now loaded from backend API
import 'package:flutter/material.dart';
import 'models/parametro.dart';
import '../../services/admin_parameter_service.dart';

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
      
      // Carrega parâmetros via API (backend serve os parâmetros a partir do DB)
      final parametros = await AdminParameterService.loadParametersFromCSV();
      _parametros = parametros;
      
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

  // CSV parsing removed.
}

