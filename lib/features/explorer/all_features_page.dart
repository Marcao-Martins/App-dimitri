import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../rcp/rcp_page.dart';
import '../dose_calculator/dose_calculator_page.dart';
import '../ficha_anestesica/ficha_anestesica_page.dart';
import '../pre_op_checklist/pre_op_checklist_page.dart';
import '../drug_guide/drug_guide_page.dart';
import '../../core/widgets/modern_widgets.dart';
import '../dose_calculator/oxygen_autonomy_calculator_page.dart';
import '../unit_converter/unit_converter_page.dart';

class AllFeaturesPage extends StatelessWidget {
  const AllFeaturesPage({super.key});

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas as Funcionalidades'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          CategoryCard(
            icon: Icons.monitor_heart,
            title: 'RCP Coach',
            subtitle: 'Assistente de RCP',
            iconColor: AppColors.error,
            onTap: () => _navigateTo(context, const RcpPage()),
          ),
          CategoryCard(
            icon: Icons.calculate,
            title: 'Calculadoras',
            subtitle: 'Doses e fluidos',
            iconColor: AppColors.categoryOrange,
            onTap: () => _navigateTo(context, const DoseCalculatorPage()),
          ),
          CategoryCard(
            icon: Icons.air, // Ícone de ar/fluxo
            title: 'Autonomia de O₂',
            subtitle: 'Cilindro de oxigênio',
            iconColor: AppColors.categoryIndigo,
            onTap: () => _navigateTo(context, const OxygenAutonomyCalculatorPage()),
          ),
          CategoryCard(
            icon: Icons.article,
            title: 'Ficha Anestésica',
            subtitle: 'Registro digital',
            iconColor: AppColors.primaryTeal,
            onTap: () => _navigateTo(context, const FichaAnestesicaPage()),
          ),
          CategoryCard(
            icon: Icons.checklist,
            title: 'Checklists',
            subtitle: 'Pré-operatório',
            iconColor: AppColors.categoryGreen,
            onTap: () => _navigateTo(context, const PreOpChecklistPage()),
          ),
          CategoryCard(
            icon: Icons.medication,
            title: 'Guia de Fármacos',
            subtitle: 'Bulário',
            iconColor: AppColors.categoryBlue,
            onTap: () => _navigateTo(context, const DrugGuidePage()),
          ),
          CategoryCard(
            icon: Icons.swap_vert,
            title: 'Conversor',
            subtitle: 'Unidades de medida',
            iconColor: AppColors.categoryPurple,
            onTap: () => _navigateTo(context, const UnitConverterPage()),
          ),
        ],
      ),
    );
  }
}
