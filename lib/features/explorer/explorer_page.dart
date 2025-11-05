import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/modern_widgets.dart';
import '../pre_op_checklist/pre_op_checklist_page.dart';
import '../drug_guide/drug_guide_page.dart';
import '../ficha_anestesica/ficha_anestesica_page.dart';
import 'all_features_page.dart';
import '../dose_calculator/oxygen_autonomy_calculator_page.dart';
import '../fluidotherapy/fluidotherapy_page.dart';
import '../transfusion/transfusion_page.dart';
import '../apgar/apgar_page.dart';
import '../consent_form/consent_form_page.dart';

/// Tela Home - Início
/// Design moderno e minimalista com acesso rápido a todas as funcionalidades
class ExplorerPage extends StatefulWidget {
  const ExplorerPage({super.key});
  
  @override
  State<ExplorerPage> createState() => _ExplorerPageState();
}

class _ExplorerPageState extends State<ExplorerPage> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar com título
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.appName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.appSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Barra de Busca
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ModernSearchBar(
                  controller: _searchController,
                  hintText: 'Buscar medicamentos, protocolos...',
                  onChanged: (value) {
                    // TODO: Implementar busca global
                  },
                  onClear: () {
                    setState(() {
                      _searchController.clear();
                    });
                  },
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            
            // Seção: Ferramentas (Acesso Rápido)
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Ferramentas',
                actionText: 'Ver todas',
                onActionTap: () {
                  _navigateTo(const AllFeaturesPage());
                },
              ),
            ),
            
            // Lista horizontal de ícones de ferramentas
            SliverToBoxAdapter(
              child: Container(
                height: 110,
                padding: const EdgeInsets.only(left: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // Novo ícone para a Calculadora de Autonomia de O2
                    LibraryIconButton(
                      icon: Icons.air,
                      label: 'Autonomia O₂',
                      color: AppColors.categoryIndigo,
                      onTap: () => _navigateTo(const OxygenAutonomyCalculatorPage()),
                    ),
                    LibraryIconButton(
                      icon: Icons.water_drop_outlined,
                      label: 'Fluidoterapia',
                      color: AppColors.categoryBlue,
                      onTap: () => _navigateTo(const FluidotherapyPage()),
                    ),
                    LibraryIconButton(
                      icon: Icons.bloodtype_outlined,
                      label: 'Transfusão',
                      color: AppColors.error,
                      onTap: () => _navigateTo(const TransfusionPage()),
                    ),
                    LibraryIconButton(
                      icon: Icons.pets,
                      label: 'Escore Apgar',
                      color: AppColors.categoryPink,
                      onTap: () => _navigateTo(const ApgarPage()),
                    ),
                    LibraryIconButton(
                      icon: Icons.article_outlined, // Ícone de prancheta/documento
                      label: 'Ficha Anestésica',
                      color: AppColors.primaryTeal, // Cor principal para destaque
                      onTap: () => _navigateTo(const FichaAnestesicaPage()),
                    ),
                    LibraryIconButton(
                      icon: Icons.assignment_outlined, // Ícone de documento/formulário
                      label: 'Termo Consentimento',
                      color: AppColors.categoryPurple, // Cor roxa para destaque
                      onTap: () => _navigateTo(const ConsentFormPage()),
                    ),
                    LibraryIconButton(
                      icon: Icons.checklist_outlined,
                      label: 'Checklists',
                      color: AppColors.categoryGreen,
                      onTap: () => _navigateTo(const PreOpChecklistPage()),
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Seção: Favoritos (Funcionalidades Principais)
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Favoritos',
                actionText: 'Ver todos',
                onActionTap: () => _navigateTo(const DrugGuidePage()),
              ),
            ),
            
            // Grid de cards de Favoritos
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildListDelegate([
                  CategoryCard(
                    icon: Icons.medication_outlined,
                    title: 'Bulário',
                    subtitle: 'Guia de fármacos',
                    iconColor: AppColors.primaryTeal,
                    onTap: () => _navigateTo(const DrugGuidePage()),
                  ),
                  CategoryCard(
                    icon: Icons.water_drop_outlined,
                    title: 'Fluidoterapia',
                    subtitle: 'Calculadora',
                    iconColor: AppColors.categoryBlue,
                    onTap: () => _navigateTo(const FluidotherapyPage()),
                  ),
                  CategoryCard(
                    icon: Icons.bloodtype_outlined,
                    title: 'Transfusão',
                    subtitle: 'Cálculos',
                    iconColor: AppColors.error,
                    onTap: () => _navigateTo(const TransfusionPage()),
                  ),
                  CategoryCard(
                    icon: Icons.pets,
                    title: 'Escore Apgar',
                    subtitle: 'Neonatos',
                    iconColor: AppColors.categoryPurple,
                    onTap: () => _navigateTo(const ApgarPage()),
                  ),
                ]),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Seção: Recentes
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recentes',
                actionText: 'Limpar',
                onActionTap: () {
                  // TODO: Limpar histórico
                },
              ),
            ),
            
            // Lista de itens recentes
            SliverToBoxAdapter(
                child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    MedicationListItem(
                      icon: Icons.medication,
                      iconColor: AppColors.primaryTeal,
                      title: 'Propofol',
                      subtitle: 'Anestésico intravenoso',
                      tag: 'VET',
                      tagColor: AppColors.tagVet,
                      onTap: () {
                        // TODO: Abrir detalhes do medicamento
                      },
                    ),
                    MedicationListItem(
                      icon: Icons.medication,
                      iconColor: AppColors.categoryOrange,
                      title: 'Tramadol',
                      subtitle: 'Cloridrato - Analgésico opioide',
                      tag: 'PA',
                      tagColor: AppColors.tagPA,
                      onTap: () {
                        // TODO: Abrir detalhes do medicamento
                      },
                    ),
                    MedicationListItem(
                      icon: Icons.medication,
                      iconColor: AppColors.categoryPurple,
                      title: 'Lidocaína',
                      subtitle: 'Anestésico local',
                      tag: 'HUM',
                      tagColor: AppColors.tagHuman,
                      onTap: () {
                        // TODO: Abrir detalhes do medicamento
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // Disclaimer Section
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                margin: const EdgeInsets.only(top: 16, bottom: 24),
                child: Text(
                  'Disclaimer / Aviso importante\n\n'
                  'Este aplicativo destina-se exclusivamente a médicos-veterinários habilitados, com CRMV ativo, e capazes de interpretar resultados e identificar inconsistências decorrentes de entradas incorretas, limitações do algoritmo ou mau funcionamento da tecnologia.\n\n'
                  'Ao continuar, você declara compreender estas limitações e concorda em verificar e validar todos os valores antes de aplicá-los no paciente.',
                  style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                        height: 1.5, // Melhora a legibilidade
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
