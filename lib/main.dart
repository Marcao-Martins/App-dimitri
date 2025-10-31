import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/providers/theme_provider.dart';
import 'core/themes/app_theme.dart';
import 'features/dose_calculator/dose_calculator_page.dart';
import 'features/drug_guide/drug_guide_page.dart';
import 'features/explorer/explorer_page.dart';
import 'features/rcp/rcp_page.dart';
import 'features/ficha_anestesica/ficha_anestesica_page.dart';
import 'features/ficha_anestesica/ficha_provider.dart';
import 'features/ficha_anestesica/services/storage_service.dart';
import 'features/pre_op_checklist/pre_op_checklist_page.dart';

/// Ponto de entrada do aplicativo GDAV
/// Aplicativo desenvolvido para auxiliar anestesiologistas veterinários
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FichaProvider()),
      ],
      child: const GdavApp(),
    ),
  );
}

/// Widget raiz do aplicativo
class GdavApp extends StatelessWidget {
  const GdavApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: '${AppStrings.appName} - ${AppStrings.appSubtitle}',
          debugShowCheckedModeBanner: false,
          
          // Temas modernos
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          
          // Tela inicial
          home: const MainNavigationScreen(),
        );
      },
    );
  }
}

/// Tela principal com navegação entre as funcionalidades
/// Novo design com 5 abas e ícones outline
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  // Lista de páginas/telas do aplicativo (6 abas)
  final List<Widget> _pages = [
    const ExplorerPage(), // Tela Home
    const RcpPage(), // RCP Coach
    const DoseCalculatorPage(),
    const PreOpChecklistPage(),
    const DrugGuidePage(),
    const FichaAnestesicaPage(),
  ];

  // Lista de títulos para a AppBar
  final List<String> _titles = const [
    'Início',
    'RCP',
    'Calculadora de Doses',
    'Checklist Pré-Operatório',
    'Guia de Fármacos',
    'Ficha Anestésica',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
            ),
            tooltip: themeProvider.isDarkMode ? 'Mudar para tema claro' : 'Mudar para tema escuro',
            onPressed: () {
              themeProvider.toggleTheme(!themeProvider.isDarkMode);
            },
          ),
        ],
      ),
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
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Início',
            tooltip: 'Início - Ferramentas e recursos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'RCP',
            tooltip: 'RCP Coach - Ressuscitação Cardiopulmonar',
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
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
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
    super.key,
    required this.title,
  });
  
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
