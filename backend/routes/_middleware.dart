// routes/_middleware.dart
// Middleware global que inicializa os provedores de dados
// Executado antes de todas as requisições

import 'package:dart_frog/dart_frog.dart';
import '../lib/providers/database_provider.dart';
import '../lib/providers/user_provider.dart';

// Instâncias globais dos provedores (inicializadas uma vez)
// Em produção, considere usar dependency injection mais sofisticado
DatabaseProvider? _dbProvider;
UserProvider? _userProvider;

Handler middleware(Handler handler) {
  return (context) async {
    // Inicializa os provedores na primeira requisição
    // IMPORTANTE: Apenas para desenvolvimento! Em produção, use pool de conexões
    if (_dbProvider == null || _userProvider == null) {
      print('🔄 Inicializando provedores de dados...');
      
      try {
        _dbProvider = DatabaseProvider();
        await _dbProvider!.initialize();
        
        _userProvider = UserProvider();
        await _userProvider!.initialize();
        
        print('✅ Provedores inicializados com sucesso');
      } catch (e) {
        print('❌ Erro ao inicializar provedores: $e');
        return Response.json(
          statusCode: 500,
          body: {
            'error': 'Erro interno do servidor',
            'message': 'Falha ao inicializar banco de dados',
          },
        );
      }
    }

    // Injeta os provedores no contexto da requisição
    // Estarão disponíveis em todas as rotas via context.read<T>()
    final contextWithProviders = context
        .provide<DatabaseProvider>(() => _dbProvider!)
        .provide<UserProvider>(() => _userProvider!);

    // Continua para o próximo handler/rota
    return handler(contextWithProviders);
  };
}
