import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'models/transfusion_calculation.dart';
import 'widgets/hematocrit_selector.dart';
import 'widgets/results_display.dart';

/// Tela da Calculadora de Transfusão Sanguínea
/// Calcula o volume necessário de sangue para transfusão baseado em hematócritos
class TransfusionPage extends StatefulWidget {
  final bool showAppBar;

  const TransfusionPage({super.key, this.showAppBar = true});

  @override
  State<TransfusionPage> createState() => _TransfusionPageState();
}

class _TransfusionPageState extends State<TransfusionPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();

  String? _selectedSpecies;
  int? _selectedFactor;
  int? _desiredHematocrit;
  int? _recipientHematocrit;
  int? _bagHematocrit;
  TransfusionCalculation? _lastCalculation;

  List<int> _availableFactors = [90];

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  /// Atualiza os fatores disponíveis quando a espécie muda
  void _onSpeciesChanged(String? species) {
    setState(() {
      _selectedSpecies = species;
      if (species != null) {
        _availableFactors = TransfusionCalculation.getFactorsForSpecies(species);
        _selectedFactor = TransfusionCalculation.getDefaultFactor(species);
      } else {
        _availableFactors = [90];
        _selectedFactor = null;
      }
    });
  }

  /// Calcula o volume de transfusão
  void _calculateTransfusion() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSpecies == null) {
      _showError('Por favor, selecione a espécie');
      return;
    }

    if (_selectedFactor == null) {
      _showError('Por favor, selecione o fator de cálculo');
      return;
    }

    if (_desiredHematocrit == null) {
      _showError('Por favor, selecione o hematócrito desejado');
      return;
    }

    if (_recipientHematocrit == null) {
      _showError('Por favor, selecione o hematócrito do receptor');
      return;
    }

    if (_bagHematocrit == null) {
      _showError('Por favor, selecione o hematócrito da bolsa');
      return;
    }

    // Validação: Ht desejado deve ser maior que Ht receptor
    if (_desiredHematocrit! <= _recipientHematocrit!) {
      _showError('Hematócrito desejado deve ser maior que o do receptor');
      return;
    }

    final weight = double.parse(_weightController.text.replaceAll(',', '.'));

    try {
      setState(() {
        _lastCalculation = TransfusionCalculation.calculate(
          species: _selectedSpecies!,
          weight: weight,
          factor: _selectedFactor!,
          desiredHematocrit: _desiredHematocrit!,
          recipientHematocrit: _recipientHematocrit!,
          bagHematocrit: _bagHematocrit!,
        );
      });

      // Scroll para mostrar resultados
      Future.delayed(const Duration(milliseconds: 300), () {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    } catch (e) {
      _showError('Erro no cálculo: ${e.toString()}');
    }
  }

  /// Limpa todos os campos
  void _clearForm() {
    setState(() {
      _weightController.clear();
      _selectedSpecies = null;
      _selectedFactor = null;
      _desiredHematocrit = null;
      _recipientHematocrit = null;
      _bagHematocrit = null;
      _lastCalculation = null;
      _availableFactors = [90];
    });
    _formKey.currentState?.reset();
  }

  /// Exibe mensagem de erro
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text('Calculadora de Transfusão'),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cabeçalho
                _buildHeader(),

                const SizedBox(height: 24),

                // Card de formulário
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dados do Paciente',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                        ),
                        const SizedBox(height: 20),

                        // Espécie
                        DropdownButtonFormField<String>(
                          value: _selectedSpecies,
                          decoration: InputDecoration(
                            labelText: 'Espécie *',
                            prefixIcon: const Icon(Icons.pets),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Cão', child: Text('Cão')),
                            DropdownMenuItem(value: 'Gato', child: Text('Gato')),
                          ],
                          onChanged: _onSpeciesChanged,
                          validator: (value) {
                            if (value == null) {
                              return 'Selecione a espécie';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Peso
                        TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Peso (kg) *',
                            hintText: 'Ex: 25.5',
                            prefixIcon: const Icon(Icons.monitor_weight),
                            suffixText: 'kg',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o peso';
                            }
                            final weight = double.tryParse(value.replaceAll(',', '.'));
                            if (weight == null || weight <= 0) {
                              return 'Peso inválido';
                            }
                            if (weight > 200) {
                              return 'Peso muito alto';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Fator de cálculo
                        DropdownButtonFormField<int>(
                          value: _selectedFactor,
                          decoration: InputDecoration(
                            labelText: 'Fator de cálculo *',
                            prefixIcon: const Icon(Icons.calculate),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                            helperText: _selectedSpecies == null
                                ? 'Selecione a espécie primeiro'
                                : 'Fator padrão para ${_selectedSpecies!}',
                          ),
                          items: _availableFactors.map((int factor) {
                            return DropdownMenuItem<int>(
                              value: factor,
                              child: Text(factor.toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedFactor = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Selecione o fator';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Título: Hematócritos
                        Text(
                          'Valores de Hematócrito',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                        ),
                        const SizedBox(height: 16),

                        // Hematócrito desejado
                        HematocritSelector(
                          label: 'Hematócrito desejado *',
                          value: _desiredHematocrit,
                          minValue: 1,
                          maxValue: 60,
                          icon: Icons.trending_up,
                          helperText: 'Ht alvo após transfusão',
                          onChanged: (value) {
                            setState(() {
                              _desiredHematocrit = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Informe o Ht desejado';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Hematócrito do receptor
                        HematocritSelector(
                          label: 'Hematócrito do receptor *',
                          value: _recipientHematocrit,
                          minValue: 1,
                          maxValue: 40,
                          icon: Icons.person,
                          helperText: 'Ht atual do paciente',
                          onChanged: (value) {
                            setState(() {
                              _recipientHematocrit = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Informe o Ht do receptor';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Hematócrito da bolsa
                        HematocritSelector(
                          label: 'Hematócrito da bolsa *',
                          value: _bagHematocrit,
                          minValue: 1,
                          maxValue: 80,
                          icon: Icons.bloodtype,
                          helperText: 'Ht do sangue doador',
                          onChanged: (value) {
                            setState(() {
                              _bagHematocrit = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Informe o Ht da bolsa';
                            }
                            if (value == 0) {
                              return 'Ht da bolsa não pode ser zero';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // Botões
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _calculateTransfusion,
                                icon: const Icon(Icons.calculate),
                                label: const Text('Calcular'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warning,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _clearForm,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Limpar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.warning,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: AppColors.warning),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Resultados
                if (_lastCalculation != null) ...[
                  const SizedBox(height: 24),
                  ResultsDisplay(calculation: _lastCalculation!),
                ],

                const SizedBox(height: 24),

                // Informações adicionais
                _buildInfoCard(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.error,
            Colors.red.shade700,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.bloodtype,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transfusão Sanguínea',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cálculo de volume necessário',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Fórmula e Fatores',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Volume (mL) = (Peso × Fator × (Ht desejado - Ht receptor)) / Ht bolsa',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Cães', 'Fatores: 80 ou 90'),
            _buildInfoItem('Gatos', 'Fatores: 40 ou 60'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Realizar tipagem sanguínea e prova cruzada antes da transfusão',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
