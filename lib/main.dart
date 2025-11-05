import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/providers/theme_provider.dart';
import 'core/themes/app_theme.dart';
import 'features/auth/login_page.dart';
import 'features/dose_calculator/dose_calculator_page.dart';
import 'features/explorer/explorer_page.dart';
import 'features/rcp/rcp_page.dart';
import 'features/ficha_anestesica/ficha_anestesica_page.dart';
import 'features/ficha_anestesica/ficha_provider.dart';
import 'features/ficha_anestesica/services/storage_service.dart';
import 'features/drug_guide/drug_guide_page.dart';
import 'features/admin/admin_dashboard.dart';
import 'features/profile/profile_page.dart';
import 'services/auth_service.dart';
import 'services/medication_service.dart';
import 'services/api_service.dart';

/// Ponto de entrada do aplicativo GDAV
/// Aplicativo desenvolvido para auxiliar anestesiologistas veterinários
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar serviços
  await StorageService.init();
  
  // Inicializar autenticação
  final authService = AuthService();
  await authService.init();
  
  // Tentar carregar medicamentos do backend (não bloqueia a inicialização)
  _loadMedicationsInBackground();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FichaProvider()),
        ChangeNotifierProvider<AuthService>.value(value: authService),
      ],
      child: const GdavApp(),
    ),
  );
}

/// Carrega medicamentos em background
void _loadMedicationsInBackground() {
  Future.microtask(() async {
    try {
      // Testa conexão primeiro
      final isConnected = await ApiService.testConnection();
      if (isConnected) {
        await MedicationService.loadMedicationsFromBackend();
        print('✓ Medicamentos carregados do backend');
      } else {
        print('⚠ Backend não disponível - usando modo offline');
      }
    } catch (e) {
      print('⚠ Erro ao carregar medicamentos: $e');
    }
  });
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
          
          // Tela inicial baseada no estado de autenticação
          home: Consumer<AuthService>(
            builder: (context, authService, _) {
              return authService.isAuthenticated 
                  ? const MainNavigationScreen()
                  : const LoginPage();
            },
          ),
          
          // Rotas nomeadas
          routes: {
            '/home': (context) => const MainNavigationScreen(),
            '/login': (context) => const LoginPage(),
            '/admin': (context) => const AdminDashboard(),
          },
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
    const DrugGuidePage(), // Bulário
    const FichaAnestesicaPage(),
    const ProfilePage(), // Perfil
  ];

  // Lista de títulos para a AppBar
  final List<String> _titles = const [
    'Início',
    'RCP',
    'Calculadora de Doses',
    'Guia de Fármacos',
    'Ficha Anestésica',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          // Botão Admin (apenas para administradores)
          if (authService.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: 'Painel Administrativo',
              onPressed: () {
                Navigator.of(context).pushNamed('/admin');
              },
            ),
          // Botão de tema (esconder na página de perfil)
          if (_currentIndex != 5)
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
            tooltip: 'Perfil do Usuário',
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
