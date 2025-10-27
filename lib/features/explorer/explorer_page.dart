import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/modern_widgets.dart';
import '../dose_calculator/dose_calculator_page.dart';
import '../pre_op_checklist/pre_op_checklist_page.dart';
import '../drug_guide/drug_guide_page.dart';

/// Tela Home - Explorar
/// Design moderno e minimalista com acesso rápido a todas as funcionalidades
class ExplorerPage extends StatefulWidget {
  const ExplorerPage({Key? key}) : super(key: key);
  
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
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
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
                    const Text(
                      'VetAnesthesia',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ferramentas para anestesiologia veterinária',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
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
            
            // Seção: Bibliotecas (Acesso Rápido)
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Bibliotecas',
                actionText: 'Ver todas',
                onActionTap: () {
                  // TODO: Navegar para tela de todas as bibliotecas
                },
              ),
            ),
            
            // Lista horizontal de ícones de bibliotecas
            SliverToBoxAdapter(
              child: Container(
                height: 110,
                padding: const EdgeInsets.only(left: 20),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    LibraryIconButton(
                      icon: Icons.calculate_outlined,
                      label: 'Calculadoras',
                      color: AppColors.categoryOrange,
                      onTap: () => _navigateTo(const DoseCalculatorPage()),
                    ),
                    LibraryIconButton(
                      icon: Icons.science_outlined,
                      label: 'Protocolos',
                      color: AppColors.categoryBlue,
                      onTap: () {
                        // TODO: Implementar tela de protocolos
                      },
                    ),
                    LibraryIconButton(
                      icon: Icons.auto_stories_outlined,
                      label: 'Estudos',
                      color: AppColors.categoryPurple,
                      onTap: () {
                        // TODO: Implementar tela de estudos
                      },
                    ),
                    LibraryIconButton(
                      icon: Icons.checklist_outlined,
                      label: 'Checklists',
                      color: AppColors.categoryGreen,
                      onTap: () => _navigateTo(const PreOpChecklistPage()),
                    ),
                    LibraryIconButton(
                      icon: Icons.folder_outlined,
                      label: 'Prontuários',
                      color: AppColors.categoryPink,
                      onTap: () {
                        // TODO: Implementar tela de prontuários
                      },
                    ),
                    LibraryIconButton(
                      icon: Icons.groups_outlined,
                      label: 'Comunidade',
                      color: AppColors.categoryIndigo,
                      onTap: () {
                        // TODO: Implementar tela de comunidade
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
            
            // Seção: Bulário (Funcionalidades Principais)
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Bulário',
                actionText: 'Ver todos',
                onActionTap: () => _navigateTo(const DrugGuidePage()),
              ),
            ),
            
            // Grid de cards do Bulário
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
                    title: 'Medicamentos',
                    subtitle: '20 fármacos',
                    iconColor: AppColors.primaryTeal,
                    onTap: () => _navigateTo(const DrugGuidePage()),
                  ),
                  CategoryCard(
                    icon: Icons.local_hospital_outlined,
                    title: 'Fluidoterapia',
                    subtitle: 'Calculadoras',
                    iconColor: AppColors.categoryBlue,
                    onTap: () {
                      // TODO: Implementar calculadora de fluidoterapia
                    },
                  ),
                  CategoryCard(
                    icon: Icons.monitor_heart_outlined,
                    title: 'CRI',
                    subtitle: 'Infusão contínua',
                    iconColor: AppColors.categoryOrange,
                    onTap: () {
                      // TODO: Implementar calculadora de CRI
                    },
                  ),
                  CategoryCard(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Analgesia',
                    subtitle: 'Protocolos',
                    iconColor: AppColors.categoryPurple,
                    onTap: () {
                      // TODO: Implementar tela de protocolos de analgesia
                    },
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
                  color: AppColors.surfaceWhite,
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
          ],
        ),
      ),
    );
  }
}
