// lib/database/database.dart
// Configuração do banco de dados MySQL
import 'dart:async';
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
    return DatabaseConfig(
      host: const String.fromEnvironment('DB_HOST', defaultValue: 'localhost'),
      port: int.fromEnvironment('DB_PORT', defaultValue: 3306),
      database: const String.fromEnvironment('DB_NAME', defaultValue: 'gdav_veterinario'),
      user: const String.fromEnvironment('DB_USER', defaultValue: 'root'),
      password: const String.fromEnvironment('DB_PASSWORD', defaultValue: ''),
      maxConnections: int.fromEnvironment('DB_MAX_CONNECTIONS', defaultValue: 10),
    );
  }
}

/// Gerenciador de conexão com o banco de dados MySQL
class AppDatabase {
  static AppDatabase? _instance;
  MySqlConnection? _connection;
  final DatabaseConfig config;

  AppDatabase._internal(this.config);

  /// Singleton - retorna sempre a mesma instância
  factory AppDatabase([DatabaseConfig? config]) {
    _instance ??= AppDatabase._internal(config ?? DatabaseConfig());
    return _instance!;
  }

  /// Obtém a conexão com o banco (cria se não existir)
  Future<MySqlConnection> get connection async {
    if (_connection == null) {
      print('🔌 Conectando ao MySQL...');
      print('   Host: ${config.host}:${config.port}');
      print('   Database: ${config.database}');
      
      _connection = await MySqlConnection.connect(
        ConnectionSettings(
          host: config.host,
          port: config.port,
          user: config.user,
          password: config.password,
          db: config.database,
          timeout: const Duration(seconds: 10),
        ),
      );
      
      print('✅ Conectado ao MySQL!');
    }
    return _connection!;
  }

  /// Fecha a conexão com o banco
  Future<void> close() async {
    if (_connection != null) {
      await _connection!.close();
      _connection = null;
      print('🔌 Conexão com MySQL fechada');
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
    final conn = await connection;

    print('🔄 Executando migrações...');

    // Cria tabela de usuários
    await _createUsersTable(conn);

    // Cria tabela de fichas
    await _createFichasTable(conn);

    print('✅ Migrações concluídas!');
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
