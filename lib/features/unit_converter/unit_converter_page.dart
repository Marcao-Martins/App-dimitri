import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/tool_box.dart';
import '../../core/constants/tool_colors.dart';
import '../../core/widgets/common_widgets.dart';
import 'unit_converter_logic.dart';

enum ConversionCategory { mass, volume, pressure, temperature }

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  ConversionCategory _selectedCategory = ConversionCategory.mass;
  String? _fromUnit;
  String? _toUnit;
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  // TODO: Populate with actual units and conversion logic
  final Map<ConversionCategory, List<String>> _units = {
    ConversionCategory.mass: ['ng', 'mcg (µg)', 'mg', 'g', 'kg', 'lb'],
    ConversionCategory.volume: ['L', 'dL', 'mL', 'µL'],
    ConversionCategory.pressure: ['kPa', 'Pa', 'bar', 'atm', 'mmHg', 'cmH₂O'],
    ConversionCategory.temperature: ['°C', '°F', 'K'],
  };

  @override
  void initState() {
    super.initState();
    _setInitialUnits();
    _inputController.addListener(_convert);
  }

  void _setInitialUnits() {
    final unitsList = _units[_selectedCategory]!;
    _fromUnit = unitsList.first;
    // Ensure 'to' unit is different from 'from' unit if possible
    _toUnit = unitsList.length > 1 ? unitsList[1] : unitsList.first;
  }

  void _convert() {
    final String inputText = _inputController.text;
    if (inputText.isEmpty) {
      _outputController.clear();
      return;
    }

    final double? inputValue = double.tryParse(inputText);
    if (inputValue == null || _fromUnit == null || _toUnit == null) {
      _outputController.text = 'Entrada inválida';
      return;
    }

    double result;
    if (_selectedCategory == ConversionCategory.temperature) {
      result = UnitConverter.convertTemperature(inputValue, _fromUnit!, _toUnit!);
    } else {
      final factors = UnitConverter.getFactors(_selectedCategory.name);
      result = UnitConverter.convert(inputValue, _fromUnit!, _toUnit!, factors);
    }

    // Format result to a reasonable number of decimal places
    _outputController.text = result.toStringAsFixed(6).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  void _clearFields() {
    _inputController.clear();
    _outputController.clear();
  }

  @override
  void dispose() {
    _inputController.removeListener(_convert);
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryUnits = _units[_selectedCategory]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversor de Unidades'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Cabeçalho da ferramenta
            ToolBox(
              title: 'Conversor de Medidas',
              subtitle: 'Conversões rápidas entre unidades comuns',
              icon: Icons.swap_horiz,
              color: ToolColors.converter,
            ),
            const SizedBox(height: 12),
            // Category Selector
            CustomDropdown<ConversionCategory>(
              label: 'Categoria',
              value: _selectedCategory,
              items: ConversionCategory.values,
              itemLabel: (category) {
                // Capitalize first letter and map to Portuguese
                final name = category.toString().split('.').last;
                const names = {
                  'mass': 'Massa',
                  'volume': 'Volume',
                  'pressure': 'Pressão',
                  'temperature': 'Temperatura',
                };
                return names[name] ?? name;
              },
              onChanged: (newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedCategory = newValue;
                    _setInitialUnits();
                    _clearFields();
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // From/To Row
            Row(
              children: [
                Expanded(
                  child: CustomDropdown<String>(
                    label: 'De',
                    value: _fromUnit,
                    items: categoryUnits,
                    itemLabel: (item) => item,
                    onChanged: (newValue) {
                      setState(() {
                        _fromUnit = newValue;
                        _convert();
                      });
                    },
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      final temp = _fromUnit;
                      _fromUnit = _toUnit;
                      _toUnit = temp;
                      _convert();
                    });
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(Icons.swap_horiz, color: AppColors.primaryTeal, size: 28),
                  ),
                ),
                Expanded(
                  child: CustomDropdown<String>(
                    label: 'Para',
                    value: _toUnit,
                    items: categoryUnits,
                    itemLabel: (item) => item,
                    onChanged: (newValue) {
                      setState(() {
                        _toUnit = newValue;
                        _convert();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Input and Output Fields
            TextField(
              controller: _inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Valor a converter',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _outputController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Resultado',
                border: const OutlineInputBorder(),
                fillColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
                filled: true,
              ),
            ),
            const Spacer(),

            // Action Buttons
            ElevatedButton(
              onPressed: _clearFields,
              child: const Text('Limpar'),
            ),
          ],
        ),
      ),
    );
  }
}
