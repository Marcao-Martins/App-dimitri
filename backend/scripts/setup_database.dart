// scripts/setup_database.dart
// Script para configurar o banco de dados MySQL inicial
import 'dart:io';
import '../lib/database/database.dart';
import '../lib/database/migrations/initial_migration.dart';

Future<void> main() async {
  print('🚀 Iniciando setup do banco de dados MySQL...\n');
  print('=' * 50);
  
  try {
    // Cria instância do banco de dados
    final db = AppDatabase();
    
    print('\n📊 Configurando banco de dados MySQL...');
    print('   Host: localhost:3306');
    print('   Database: gdav_veterinario');
    print('   ⚠️  Certifique-se de que o MySQL está rodando!\n');
    
    // Executa migração inicial completa
    await runInitialMigration(db);
    
    // Fecha conexão
    await db.close();
    
    print('\n' + '=' * 50);
    print('🎉 Setup concluído com sucesso!');
    print('=' * 50);
    print('\n💡 Próximos passos:');
    print('   1. Verifique o banco "gdav_veterinario" no MySQL');
    print('   2. Confira a tabela "users"');
    print('   3. Teste o login com as credenciais padrão');
    print('\n');
    exit(0);
  } catch (e, stackTrace) {
    print('\n' + '=' * 50);
    print('❌ ERRO NO SETUP');
    print('=' * 50);
    print('\nErro: $e');
    print('\nPossíveis soluções:');
    print('   1. Verifique se o MySQL está rodando');
    print('   2. Verifique as credenciais de conexão');
    print('   3. Verifique se o usuário tem permissões');
    print('\nStack trace completo:');
    print(stackTrace);
    print('\n');
    exit(1);
  }
}
