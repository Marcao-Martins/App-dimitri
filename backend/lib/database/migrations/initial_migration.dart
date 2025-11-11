// lib/database/migrations/initial_migration.dart
// Migration inicial: cria o banco, tabelas e insere dados seed
import 'package:bcrypt/bcrypt.dart';
import '../database.dart';
import '../../services/user_repository.dart';
import '../../models/user.dart';

/// Executa a migração inicial do banco de dados
Future<void> runInitialMigration(AppDatabase db) async {
  print('🔄 Executando migração inicial...\n');
  
  try {
    // 1. Cria o banco de dados se não existir
    await db.createDatabaseIfNotExists();
    
    // 2. Cria as tabelas
    await db.runMigrations();
    
    // 3. Insere dados seed (usuário admin)
    print('\n📝 Inserindo dados iniciais...');
    final repo = UserRepository(db);
    
    // Verifica se já existe usuário admin
    final existingAdmin = await repo.getUserByEmail('admin@gdav.com');
    
    if (existingAdmin == null) {
      print('👤 Criando usuário administrador padrão...');
      
      // Cria hash da senha "admin123"
      final passwordHash = BCrypt.hashpw('admin123', BCrypt.gensalt());
      
      await repo.createUser(
        name: 'Administrador',
        email: 'admin@gdav.com',
        passwordHash: passwordHash,
        role: UserRole.administrator,
      );
      
      print('✅ Usuário administrador criado com sucesso!');
      print('   Email: admin@gdav.com');
      print('   Senha: admin123');
      print('   ⚠️  IMPORTANTE: Altere esta senha em produção!');
    } else {
      print('ℹ️  Usuário administrador já existe');
    }
    
    print('\n✅ Migração inicial concluída com sucesso!');
  } catch (e, stackTrace) {
    print('\n❌ Erro na migração inicial: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}
