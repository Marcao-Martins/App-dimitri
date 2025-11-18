import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'models/fluid_calculation.dart';
import 'widgets/dehydration_section.dart';
import 'widgets/results_display.dart';

/// Tela da Calculadora de Fluidoterapia
/// Calcula volumes de fluidos de manutenção e reidratação para cães e gatos
class FluidotherapyPage extends StatefulWidget {
  final bool showAppBar;

  const FluidotherapyPage({super.key, this.showAppBar = true});

  @override
  State<FluidotherapyPage> createState() => _FluidotherapyPageState();
}

class _FluidotherapyPageState extends State<FluidotherapyPage> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _dehydrationController = TextEditingController();

  String? _selectedSpecies;
  bool _hasDehydration = false;
  int? _rehydrationTime;
  FluidCalculation? _lastCalculation;

  @override
  void dispose() {
    _weightController.dispose();
    _dehydrationController.dispose();
    super.dispose();
  }

  /// Calcula a fluidoterapia
  void _calculateFluidotherapy() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSpecies == null) {
      _showError('Por favor, selecione a espécie');
      return;
    }

    final weight = double.parse(_weightController.text.replaceAll(',', '.'));
    double? dehydrationPercent;

    if (_hasDehydration) {
      if (_rehydrationTime == null) {
        _showError('Por favor, selecione o tempo de reidratação');
        return;
      }
      dehydrationPercent = double.parse(
        _dehydrationController.text.replaceAll(',', '.'),
      );
    }

    setState(() {
      _lastCalculation = FluidCalculation.calculate(
        species: _selectedSpecies!,
        weight: weight,
        hasDehydration: _hasDehydration,
        rehydrationTime: _rehydrationTime,
        dehydrationPercent: dehydrationPercent,
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
  }

  /// Limpa todos os campos
  void _clearForm() {
    setState(() {
      _weightController.clear();
      _dehydrationController.clear();
      _selectedSpecies = null;
      _hasDehydration = false;
      _rehydrationTime = null;
      _lastCalculation = null;
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
              title: const Text('Calculadora de Fluidoterapia'),
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
                // Cabeçalho com ícone
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
                                color: AppColors.primaryTeal,
                              ),
                        ),
                        const SizedBox(height: 20),

                        // Espécie
                        DropdownButtonFormField<String>(
                          initialValue: _selectedSpecies,
                          isExpanded: true,
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
                          onChanged: (value) {
                            setState(() {
                              _selectedSpecies = value;
                            });
                          },
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

                        // Desidratação
                        DropdownButtonFormField<bool>(
                          initialValue: _hasDehydration,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: 'Desidratação *',
                            prefixIcon: const Icon(Icons.warning_amber),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Theme.of(context).colorScheme.surface,
                          ),
                          items: const [
                            DropdownMenuItem(value: false, child: Text('Não')),
                            DropdownMenuItem(value: true, child: Text('Sim')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _hasDehydration = value ?? false;
                              if (!_hasDehydration) {
                                _rehydrationTime = null;
                                _dehydrationController.clear();
                              }
                            });
                          },
                        ),

                        // Seção condicional de desidratação
                        DehydrationSection(
                          hasDehydration: _hasDehydration,
                          rehydrationTime: _rehydrationTime,
                          dehydrationController: _dehydrationController,
                          onRehydrationTimeChanged: (value) {
                            setState(() {
                              _rehydrationTime = value;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // Botões
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _calculateFluidotherapy,
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
            AppColors.primaryTeal,
            AppColors.categoryBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryTeal.withValues(alpha: 0.3),
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
              Icons.water_drop,
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
                  'Fluidoterapia',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cálculo de manutenção e reidratação',
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
                  color: AppColors.primaryTeal,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Informações',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryTeal,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem('Cães', '60 mL/kg/dia (manutenção)'),
            _buildInfoItem('Gatos', '40 mL/kg/dia (manutenção)'),
            _buildInfoItem('Reidratação', 'Peso × % desidratação × 1000 mL'),
            _buildInfoItem('Macrogotas', '20 gotas/mL'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber,
                    color: AppColors.warning,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este cálculo é uma estimativa. Ajuste conforme necessário.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
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
              color: AppColors.primaryTeal,
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
