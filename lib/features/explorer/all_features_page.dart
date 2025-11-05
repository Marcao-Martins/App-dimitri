import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../pre_op_checklist/pre_op_checklist_page.dart';
import '../../core/widgets/modern_widgets.dart';
import '../dose_calculator/oxygen_autonomy_calculator_page.dart';
import '../unit_converter/unit_converter_page.dart';
import '../fluidotherapy/fluidotherapy_page.dart';
import '../transfusion/transfusion_page.dart';
import '../apgar/apgar_page.dart';
import '../consent_form/consent_form_page.dart';

/// Tela que exibe ferramentas adicionais do app GDAV
/// Exclui as que já estão na navegação inferior para evitar duplicação
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
        title: const Text('Ferramentas Adicionais'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
        children: [
          // === CALCULADORAS ESPECÍFICAS ===
          CategoryCard(
            icon: Icons.water_drop_outlined,
            title: 'Fluidoterapia',
            subtitle: 'Cálculo de fluidos',
            iconColor: AppColors.categoryBlue,
            onTap: () => _navigateTo(context, const FluidotherapyPage()),
          ),
          CategoryCard(
            icon: Icons.bloodtype_outlined,
            title: 'Transfusão',
            subtitle: 'Volume sanguíneo',
            iconColor: AppColors.error,
            onTap: () => _navigateTo(context, const TransfusionPage()),
          ),
          CategoryCard(
            icon: Icons.air,
            title: 'Autonomia de O₂',
            subtitle: 'Cilindro oxigênio',
            iconColor: AppColors.categoryIndigo,
            onTap: () => _navigateTo(context, const OxygenAutonomyCalculatorPage()),
          ),
          CategoryCard(
            icon: Icons.swap_vert,
            title: 'Conversor',
            subtitle: 'Unidades medida',
            iconColor: AppColors.categoryPurple,
            onTap: () => _navigateTo(context, const UnitConverterPage()),
          ),

          // === AVALIAÇÃO ===
          CategoryCard(
            icon: Icons.baby_changing_station,
            title: 'Escore Apgar',
            subtitle: 'Neonatos',
            iconColor: AppColors.categoryPink,
            onTap: () => _navigateTo(context, const ApgarPage()),
          ),

          // === DOCUMENTAÇÃO ===
          CategoryCard(
            icon: Icons.assignment_outlined,
            title: 'Termo Consentimento',
            subtitle: 'Autorização PDF',
            iconColor: AppColors.categoryPurple,
            onTap: () => _navigateTo(context, const ConsentFormPage()),
          ),

          // === CHECKLISTS ===
          CategoryCard(
            icon: Icons.checklist_outlined,
            title: 'Checklist Pré-Op',
            subtitle: 'Pré-operatório',
            iconColor: AppColors.categoryGreen,
            onTap: () => _navigateTo(context, const PreOpChecklistPage()),
          ),
        ],
      ),
    );
  }
}
