// scripts/test_connection.dart
// Script simples para testar a conexão com o MySQL
import 'dart:io';
import '../lib/database/database.dart';

Future<void> main() async {
  print('🔌 Testando conexão com MySQL...\n');
  print('=' * 50);
  
  final db = AppDatabase();
  
  try {
    print('📡 Tentando conectar...');
    final conn = await db.connection;
    
    print('✅ Conexão estabelecida com sucesso!\n');
    
    // Testar query simples
    print('🔍 Testando query...');
    final result = await conn.query('SELECT VERSION() as version, NOW() as now');
    
    if (result.isNotEmpty) {
      final row = result.first;
      print('✅ Query executada com sucesso!');
      print('   MySQL Version: ${row['version']}');
      print('   Server Time: ${row['now']}');
    }
    
    // Verificar se o banco existe
    print('\n🗄️  Verificando banco de dados...');
    final dbExists = await db.databaseExists();
    
    if (dbExists) {
      print('✅ Banco "gdav_veterinario" encontrado!');
      
      // Listar tabelas
      final tables = await conn.query('SHOW TABLES');
      print('   Tabelas: ${tables.length}');
      
      if (tables.isNotEmpty) {
        for (final table in tables) {
          final tableName = table.values?.first;
          print('   - $tableName');
        }
      }
    } else {
      print('⚠️  Banco "gdav_veterinario" não encontrado');
      print('   Execute: dart run scripts/setup_database.dart');
    }
    
    await db.close();
    
    print('\n' + '=' * 50);
    print('🎉 Teste de conexão concluído com sucesso!');
    print('=' * 50);
    exit(0);
    
  } catch (e, stackTrace) {
    print('\n' + '=' * 50);
    print('❌ ERRO NA CONEXÃO');
    print('=' * 50);
    print('\nErro: $e');
    print('\nPossíveis causas:');
    print('   1. MySQL não está rodando');
    print('   2. Credenciais incorretas no .env');
    print('   3. Firewall bloqueando porta 3306');
    print('   4. Host/porta incorretos');
    print('\nSoluções:');
    print('   - Windows: Verificar serviço MySQL nos Serviços');
    print('   - Verificar arquivo .env na pasta backend');
    print('   - Testar: mysql -u root -p');
    print('\nStack trace:');
    print(stackTrace);
    exit(1);
  }
}
