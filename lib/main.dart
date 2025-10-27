import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/explorer/explorer_page.dart';
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
      
      // Temas modernos
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Tela inicial
      home: const MainNavigationScreen(),
    );
  }
}

/// Tela principal com navegação entre as funcionalidades
/// Novo design com 5 abas e ícones outline
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  // Lista de páginas/telas do aplicativo (5 abas)
  final List<Widget> _pages = const [
    ExplorerPage(), // Nova tela Home
    DoseCalculatorPage(),
    PreOpChecklistPage(),
    DrugGuidePage(),
    PlaceholderPage(title: 'Comunidade'), // Placeholder para futuro desenvolvimento
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
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorar',
            tooltip: 'Explorar ferramentas e recursos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate),
            label: 'Calculadoras',
            tooltip: 'Calculadora de Doses Veterinárias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist),
            label: 'Checklist',
            tooltip: 'Checklist Pré-Operatório',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Bulário',
            tooltip: 'Guia de Fármacos Anestésicos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Comunidade',
            tooltip: 'Comunidade de profissionais',
          ),
        ],
      ),
    );
  }
}

/// Widget placeholder para páginas em desenvolvimento
class PlaceholderPage extends StatelessWidget {
  final String title;
  
  const PlaceholderPage({
    Key? key,
    required this.title,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Em Desenvolvimento',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Esta funcionalidade estará disponível em breve',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
