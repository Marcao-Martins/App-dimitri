import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'features/explorer/explorer_page.dart';
import 'features/dose_calculator/dose_calculator_page.dart';
import 'features/pre_op_checklist/pre_op_checklist_page.dart';
import 'features/drug_guide/drug_guide_page.dart';
import 'features/ficha_anestesica/ficha_anestesica_page.dart';
import 'features/ficha_anestesica/ficha_provider.dart';
import 'features/ficha_anestesica/services/storage_service.dart';
import 'package:provider/provider.dart';

/// Ponto de entrada do aplicativo GDAV
/// Aplicativo desenvolvido para auxiliar anestesiologistas veterinários
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const GdavApp());
}

/// Widget raiz do aplicativo
class GdavApp extends StatelessWidget {
  const GdavApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FichaProvider())],
  child: MaterialApp(
      title: '${AppStrings.appName} - ${AppStrings.appSubtitle}',
      debugShowCheckedModeBanner: false,
      
      // Temas modernos
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // Tela inicial
      home: const MainNavigationScreen(),
      ),
    );
    // MultiProvider closes in the returned widget
    // (Note: the MaterialApp above is wrapped by MultiProvider)
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
    FichaAnestesicaPage(),
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
            label: 'Ficha',
            tooltip: 'Ficha Anestésica',
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
