import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/dose_calculator/dose_calculator_page.dart';
import 'features/pre_op_checklist/pre_op_checklist_page.dart';
import 'features/drug_guide/drug_guide_page.dart';

/// Ponto de entrada do aplicativo VetAnesthesia Helper
/// Aplicativo desenvolvido para auxiliar anestesiologistas veterinários
void main() {
  runApp(const VetAnesthesiaApp());
}

/// Widget raiz do aplicativo
class VetAnesthesiaApp extends StatelessWidget {
  const VetAnesthesiaApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      
      // Temas
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Tela inicial
      home: const MainNavigationScreen(),
    );
  }
}

/// Tela principal com navegação entre as funcionalidades
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  // Lista de páginas/telas do aplicativo
  final List<Widget> _pages = const [
    DoseCalculatorPage(),
    PreOpChecklistPage(),
    DrugGuidePage(),
  ];
  
  // Títulos das páginas (para acessibilidade)
  final List<String> _pageTitles = const [
    AppStrings.navCalculator,
    AppStrings.navChecklist,
    AppStrings.navDrugGuide,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: AppStrings.navCalculator,
            tooltip: 'Calculadora de Doses Veterinárias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: AppStrings.navChecklist,
            tooltip: 'Checklist Pré-Operatório',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: AppStrings.navDrugGuide,
            tooltip: 'Guia de Fármacos Anestésicos',
          ),
        ],
      ),
    );
  }
}
