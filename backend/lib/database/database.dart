// lib/database/database.dart
// Configuração do banco de dados MySQL
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mysql1/mysql1.dart';

/// Configuração de conexão com MySQL
class DatabaseConfig {
  final String host;
  final int port;
  final String database;
  final String user;
  final String password;
  final int maxConnections;

  const DatabaseConfig({
    this.host = 'localhost',
    this.port = 3306,
    this.database = 'gdav_veterinario',
    this.user = 'root',
    this.password = '',
    this.maxConnections = 10,
  });

  /// Cria configuração a partir de variáveis de ambiente
  factory DatabaseConfig.fromEnvironment() {
    // Use runtime environment variables (Platform.environment) instead of
    // compile-time String.fromEnvironment so values set by scripts or the
    // OS are picked up at runtime.
    final env = Platform.environment;
    final host = env['DB_HOST'] ?? env['HOST'] ?? 'localhost';
    final port = int.tryParse(env['DB_PORT'] ?? '') ?? 3306;
    final database = env['DB_NAME'] ?? env['DB_DATABASE'] ?? 'gdav_veterinario';
    final user = env['DB_USER'] ?? env['DB_USERNAME'] ?? 'root';
    final password = env['DB_PASSWORD'] ?? env['DB_PASS'] ?? '';
    final maxConnections = int.tryParse(env['DB_MAX_CONNECTIONS'] ?? '') ?? 10;

    return DatabaseConfig(
      host: host,
      port: port,
      database: database,
      user: user,
      password: password,
      maxConnections: maxConnections,
    );
  }

  /// Create configuration from a secrets JSON map
  factory DatabaseConfig.fromMap(Map<String, dynamic> map) {
    return DatabaseConfig(
      host: map['host']?.toString() ?? map['hostname']?.toString() ?? 'localhost',
      port: int.tryParse(map['port']?.toString() ?? '') ?? 3306,
      database: map['database']?.toString() ?? map['db']?.toString() ?? map['dbname']?.toString() ?? 'gdav_veterinario',
      user: map['username']?.toString() ?? map['user']?.toString() ?? 'root',
      password: map['password']?.toString() ?? '',
      maxConnections: int.tryParse(map['max_connections']?.toString() ?? '') ?? 10,
    );
  }
}

/// Gerenciador de conexão com o banco de dados MySQL
class AppDatabase {
  static AppDatabase? _instance;
  MySqlPool? _pool;
  MySqlConnection? _sharedConnection;
  final DatabaseConfig config;

  AppDatabase._internal(this.config);

  /// Singleton - retorna sempre a mesma instância
  factory AppDatabase([DatabaseConfig? config]) {
    _instance ??= AppDatabase._internal(config ?? DatabaseConfig.fromEnvironment());
    return _instance!;
  }

  /// Obtém a conexão com o banco (cria se não existir)
  /// Acquire a connection from the pool
  Future<MySqlConnection> acquireConnection() async {
    _pool ??= MySqlPool(
      ConnectionSettings(
        host: config.host,
        port: config.port,
        user: config.user,
        password: config.password,
        db: config.database,
        timeout: const Duration(seconds: 10),
      ),
      maxConnections: config.maxConnections,
    );

    return _pool!.acquire();
  }

  /// Backwards-compatible shared connection (single long-lived connection)
  Future<MySqlConnection> get connection async {
    if (_sharedConnection == null) {
      print('🔌 Conectando ao MySQL (shared)...');
      _sharedConnection = await MySqlConnection.connect(
        ConnectionSettings(
          host: config.host,
          port: config.port,
          user: config.user,
          password: config.password,
          db: config.database,
          timeout: const Duration(seconds: 10),
        ),
      );
      print('✅ Conectado ao MySQL (shared)');
    }
    return _sharedConnection!;
  }

  /// Release a connection back to the pool
  void releaseConnection(MySqlConnection conn) {
    _pool?.release(conn);
  }

  /// Convenience: run function with acquired connection and ensure release/close
  Future<T> usingConnection<T>(Future<T> Function(MySqlConnection) fn) async {
    final conn = await acquireConnection();
    try {
      return await fn(conn);
    } finally {
      // We try to return to the pool instead of closing
      try {
        releaseConnection(conn);
      } catch (_) {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  /// Fecha a conexão com o banco
  Future<void> close() async {
    if (_pool != null) {
      await _pool!.close();
      _pool = null;
      print('🔌 Pool de conexões fechado');
    }
    if (_sharedConnection != null) {
      try {
        await _sharedConnection!.close();
      } catch (_) {}
      _sharedConnection = null;
      print('🔌 Conexão compartilhada fechada');
    }
  }

  /// Verifica se o banco de dados existe
  Future<bool> databaseExists() async {
    try {
      // Conecta sem especificar o banco
      final tempConn = await MySqlConnection.connect(
        ConnectionSettings(
          host: config.host,
          port: config.port,
          user: config.user,
          password: config.password,
          timeout: const Duration(seconds: 5),
        ),
      );

      final result = await tempConn.query(
        "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = ?",
        [config.database],
      );

      await tempConn.close();
      return result.isNotEmpty;
    } catch (e) {
      print('❌ Erro ao verificar banco de dados: $e');
      return false;
    }
  }

  /// Cria o banco de dados se não existir
  Future<void> createDatabaseIfNotExists() async {
    try {
      // Conecta sem especificar o banco
      final tempConn = await MySqlConnection.connect(
        ConnectionSettings(
          host: config.host,
          port: config.port,
          user: config.user,
          password: config.password,
          timeout: const Duration(seconds: 5),
        ),
      );

      print('📊 Criando banco de dados "${config.database}"...');
      await tempConn.query(
        'CREATE DATABASE IF NOT EXISTS `${config.database}` '
        'DEFAULT CHARACTER SET utf8mb4 '
        'COLLATE utf8mb4_unicode_ci',
      );

      await tempConn.close();
      print('✅ Banco de dados criado/verificado!');
    } catch (e) {
      print('❌ Erro ao criar banco de dados: $e');
      rethrow;
    }
  }

  /// Executa a migração inicial - cria tabelas
  Future<void> runMigrations() async {
    print('🔄 Executando migrações...');
    final conn = await acquireConnection();
    try {
      // Cria tabela de usuários
      await _createUsersTable(conn);

      // Cria tabela de fichas
      await _createFichasTable(conn);

      print('✅ Migrações concluídas!');
    } finally {
      await conn.close();
    }
  }

  /// Cria a tabela de usuários com estrutura robusta
  Future<void> _createUsersTable(MySqlConnection conn) async {
    print('📋 Criando tabela users...');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS users (
        id CHAR(36) PRIMARY KEY COMMENT 'UUID v4',
        name VARCHAR(255) NOT NULL COMMENT 'Nome completo do usuário',
        email VARCHAR(255) NOT NULL UNIQUE COMMENT 'Email único (login)',
        password VARCHAR(255) NOT NULL COMMENT 'Hash bcrypt da senha',
        role ENUM('consumer', 'administrator') NOT NULL DEFAULT 'consumer' COMMENT 'Função do usuário',
        status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active' COMMENT 'Status da conta',
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação',
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data de atualização',
        deleted_at TIMESTAMP NULL DEFAULT NULL COMMENT 'Data de exclusão (soft delete)',
        last_login_at TIMESTAMP NULL DEFAULT NULL COMMENT 'Data do último login',
        failed_login_attempts INT NOT NULL DEFAULT 0 COMMENT 'Tentativas de login falhadas',
        locked_until TIMESTAMP NULL DEFAULT NULL COMMENT 'Bloqueado até (segurança)',
        phone_number VARCHAR(20) NULL COMMENT 'Número de telefone',
        profile_image_url VARCHAR(500) NULL COMMENT 'URL da foto de perfil',
        
        INDEX idx_email (email),
        INDEX idx_status (status),
        INDEX idx_deleted_at (deleted_at),
        INDEX idx_created_at (created_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Tabela de usuários do sistema';
    ''');

    print('✅ Tabela users criada!');
  }

  /// Cria a tabela de fichas veterinárias
  Future<void> _createFichasTable(MySqlConnection conn) async {
    print('📋 Criando tabela fichas...');

    await conn.query('''
      CREATE TABLE IF NOT EXISTS fichas (
        id CHAR(36) PRIMARY KEY COMMENT 'UUID v4',
        user_id CHAR(36) NOT NULL COMMENT 'FK para users.id',
        animal_name VARCHAR(255) NOT NULL COMMENT 'Nome do animal',
        animal_type ENUM('canino', 'felino', 'equino', 'bovino', 'suino', 'ovino', 'caprino', 'outro') NOT NULL COMMENT 'Tipo do animal',
        breed VARCHAR(255) NOT NULL COMMENT 'Raça do animal',
        sex ENUM('macho', 'femea') NOT NULL COMMENT 'Sexo do animal',
        weight DECIMAL(10,2) NOT NULL COMMENT 'Peso em kg',
        birth_date DATE NULL COMMENT 'Data de nascimento',
        microchip_number VARCHAR(50) NULL COMMENT 'Número do microchip',
        owner_name VARCHAR(255) NULL COMMENT 'Nome do proprietário',
        owner_phone VARCHAR(20) NULL COMMENT 'Telefone do proprietário',
        observations TEXT NULL COMMENT 'Observações gerais',
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação',
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data de atualização',
        deleted_at TIMESTAMP NULL DEFAULT NULL COMMENT 'Data de exclusão (soft delete)',
        
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE ON UPDATE CASCADE,
        INDEX idx_user_id (user_id),
        INDEX idx_animal_name (animal_name),
        INDEX idx_animal_type (animal_type),
        INDEX idx_deleted_at (deleted_at),
        INDEX idx_created_at (created_at)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Fichas veterinárias dos animais';
    ''');

    print('✅ Tabela fichas criada!');
  }
}

/// Simple MySQL connection pool for `mysql1` package.
class MySqlPool {
  final ConnectionSettings settings;
  final int maxConnections;
  final _available = <MySqlConnection>[];
  int _total = 0;
  final _waiters = <Completer<MySqlConnection>>[];

  MySqlPool(this.settings, {this.maxConnections = 10});

  Future<MySqlConnection> acquire() async {
    // return immediately if available
    if (_available.isNotEmpty) {
      return _available.removeLast();
    }

    // create new if under limit
    if (_total < maxConnections) {
      _total++;
      final conn = await MySqlConnection.connect(settings);
      return conn;
    }

    // otherwise wait
    final completer = Completer<MySqlConnection>();
    _waiters.add(completer);
    return completer.future;
  }

  void release(MySqlConnection conn) {
    if (_waiters.isNotEmpty) {
      final waiter = _waiters.removeAt(0);
      waiter.complete(conn);
      return;
    }

    _available.add(conn);
  }

  Future<void> close() async {
    for (final c in _available) {
      try {
        await c.close();
      } catch (_) {}
    }
    _available.clear();
    _total = 0;
  }
}

/// Helper to obtain DatabaseConfig from AWS Secrets Manager using AWS CLI
/// The secret must be a JSON string containing at least host, username, password, database
Future<DatabaseConfig?> loadConfigFromAwsSecret({String secretId = 'prod', String region = 'us-east-1'}) async {
  try {
    final useAws = Platform.environment['USE_AWS_SECRETS']?.toLowerCase() == 'true';
    if (!useAws) return null;

    final result = await Process.run('aws', [
      'secretsmanager',
      'get-secret-value',
      '--secret-id',
      secretId,
      '--region',
      region,
      '--query',
      'SecretString',
      '--output',
      'text',
    ]);

    if (result.exitCode != 0) {
      print('⚠️ AWS CLI returned error: ${result.stderr}');
      return null;
    }

    final jsonStr = (result.stdout as String).trim();
    if (jsonStr.isEmpty) return null;

    final map = json.decode(jsonStr) as Map<String, dynamic>;
    return DatabaseConfig.fromMap(map);
  } catch (e) {
    print('⚠️ Falha ao obter secret do AWS Secrets Manager: $e');
    return null;
  }
}
