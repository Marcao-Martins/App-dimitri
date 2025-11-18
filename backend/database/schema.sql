-- schema.sql
-- Script SQL completo para criar a estrutura do banco de dados
-- Este arquivo serve como referência e pode ser executado manualmente

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS gdav_veterinario
DEFAULT CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE gdav_veterinario;

-- Criar tabela de usuários
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

-- Inserir usuário administrador padrão (senha: admin123)
-- IMPORTANTE: Altere esta senha em produção!
INSERT IGNORE INTO users (
    id, 
    name, 
    email, 
    password, 
    role, 
    status,
    created_at,
    updated_at
) VALUES (
    UUID(), 
    'Administrador', 
    'admin@gdvet.com', 
    '$2a$12$0VfROxd.TNzt/YmCcLvzRehpy3pCXca8QLLDrUDKHGp7wtrYX6.Xq',
    'administrator',
    'active',
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP
);

-- Criar tabela de fichas veterinárias
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

-- Queries úteis para administração

-- USUÁRIOS
-- Ver todos os usuários ativos
-- SELECT id, name, email, role, status, created_at, last_login_at FROM users WHERE deleted_at IS NULL;

-- Contar usuários por role
-- SELECT role, COUNT(*) as total FROM users WHERE deleted_at IS NULL GROUP BY role;

-- Ver usuários bloqueados
-- SELECT id, name, email, failed_login_attempts, locked_until FROM users WHERE locked_until > NOW();

-- Usuários que nunca fizeram login
-- SELECT id, name, email, created_at FROM users WHERE last_login_at IS NULL AND deleted_at IS NULL;

-- Usuários criados nos últimos 7 dias
-- SELECT id, name, email, created_at FROM users WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) AND deleted_at IS NULL;

-- FICHAS
-- Ver todas as fichas de um usuário
-- SELECT f.*, u.name as user_name FROM fichas f JOIN users u ON f.user_id = u.id WHERE f.user_id = 'USER_ID' AND f.deleted_at IS NULL;

-- Contar fichas por usuário
-- SELECT u.id, u.name, COUNT(f.id) as total_fichas FROM users u LEFT JOIN fichas f ON u.id = f.user_id AND f.deleted_at IS NULL WHERE u.deleted_at IS NULL GROUP BY u.id, u.name;

-- Fichas por tipo de animal
-- SELECT animal_type, COUNT(*) as total FROM fichas WHERE deleted_at IS NULL GROUP BY animal_type;

-- Fichas com animais de determinado tipo
-- SELECT * FROM fichas WHERE animal_type = 'canino' AND deleted_at IS NULL ORDER BY animal_name;

-- Buscar ficha por nome do animal (parcial)
-- SELECT * FROM fichas WHERE animal_name LIKE '%rex%' AND deleted_at IS NULL;

-- Fichas criadas nos últimos 30 dias
-- SELECT f.*, u.name as user_name FROM fichas f JOIN users u ON f.user_id = u.id WHERE f.created_at >= DATE_SUB(NOW(), INTERVAL 30 DAY) AND f.deleted_at IS NULL;

-- Estatísticas gerais
-- SELECT 
--   (SELECT COUNT(*) FROM users WHERE deleted_at IS NULL) as total_usuarios,
--   (SELECT COUNT(*) FROM fichas WHERE deleted_at IS NULL) as total_fichas,
--   (SELECT AVG(weight) FROM fichas WHERE deleted_at IS NULL) as peso_medio;
