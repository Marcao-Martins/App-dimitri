-- farmacos_parametros_tables.sql
-- Script SQL para criar as tabelas de fármacos e parâmetros veterinários
-- Execute este script após o schema.sql principal

USE gdav_veterinario;

-- ============================================================================
-- TABELA DE FÁRMACOS VETERINÁRIOS
-- ============================================================================

CREATE TABLE IF NOT EXISTS farmacos (
    id CHAR(36) PRIMARY KEY COMMENT 'UUID v4',
    post_id INT NULL COMMENT 'ID do post original (referência)',
    titulo VARCHAR(255) NOT NULL COMMENT 'Título/nome do fármaco',
    farmaco VARCHAR(255) NOT NULL COMMENT 'Nome do fármaco',
    classe_farmacologica VARCHAR(255) NOT NULL COMMENT 'Classe farmacológica',
    nome_comercial TEXT NULL COMMENT 'Nomes comerciais disponíveis',
    mecanismo_de_acao TEXT NULL COMMENT 'Mecanismo de ação do fármaco',
    posologia_caes TEXT NULL COMMENT 'Posologia para cães',
    posologia_gatos TEXT NULL COMMENT 'Posologia para gatos',
    ivc TEXT NULL COMMENT 'Infusão venosa contínua (IVC)',
    comentarios TEXT NULL COMMENT 'Comentários e observações importantes',
    referencia TEXT NULL COMMENT 'Referências bibliográficas',
    post_date TIMESTAMP NULL COMMENT 'Data do post original',
    link VARCHAR(500) NULL COMMENT 'Link para o post original',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação no sistema',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data de atualização',
    deleted_at TIMESTAMP NULL DEFAULT NULL COMMENT 'Data de exclusão (soft delete)',
    
    INDEX idx_farmaco (farmaco),
    INDEX idx_titulo (titulo),
    INDEX idx_classe_farmacologica (classe_farmacologica),
    INDEX idx_deleted_at (deleted_at),
    INDEX idx_created_at (created_at),
    FULLTEXT INDEX ft_search (titulo, farmaco, classe_farmacologica, nome_comercial, comentarios)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Fármacos veterinários com posologias e informações';

-- ============================================================================
-- TABELA DE PARÂMETROS VETERINÁRIOS
-- ============================================================================

CREATE TABLE IF NOT EXISTS parametros_veterinarios (
    id CHAR(36) PRIMARY KEY COMMENT 'UUID v4',
    species ENUM('dog', 'cat', 'horse', 'bovine', 'swine', 'ovine', 'caprine', 'other') NOT NULL COMMENT 'Espécie animal',
    parameter_name VARCHAR(255) NOT NULL COMMENT 'Nome do parâmetro',
    parameter_value TEXT NOT NULL COMMENT 'Valor de referência do parâmetro',
    comments TEXT NULL COMMENT 'Comentários e observações',
    category VARCHAR(100) NOT NULL COMMENT 'Categoria do parâmetro (Cardiovascular, Respiratório, etc)',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação',
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT 'Data de atualização',
    deleted_at TIMESTAMP NULL DEFAULT NULL COMMENT 'Data de exclusão (soft delete)',
    
    INDEX idx_species (species),
    INDEX idx_parameter_name (parameter_name),
    INDEX idx_category (category),
    INDEX idx_deleted_at (deleted_at),
    INDEX idx_species_category (species, category),
    FULLTEXT INDEX ft_search (parameter_name, parameter_value, comments)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Parâmetros fisiológicos veterinários por espécie';

-- ============================================================================
-- TABELA DE REFERÊNCIAS DOS PARÂMETROS (normalização)
-- ============================================================================

CREATE TABLE IF NOT EXISTS parametros_referencias (
    id CHAR(36) PRIMARY KEY COMMENT 'UUID v4',
    parametro_id CHAR(36) NOT NULL COMMENT 'FK para parametros_veterinarios.id',
    referencia TEXT NOT NULL COMMENT 'Referência bibliográfica',
    ordem INT NOT NULL DEFAULT 0 COMMENT 'Ordem de exibição',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Data de criação',
    
    FOREIGN KEY (parametro_id) REFERENCES parametros_veterinarios(id) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_parametro_id (parametro_id),
    INDEX idx_ordem (ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='Referências bibliográficas dos parâmetros';

-- ============================================================================
-- QUERIES ÚTEIS PARA ADMINISTRAÇÃO
-- ============================================================================

-- FÁRMACOS
-- Buscar fármaco por nome
-- SELECT * FROM farmacos WHERE farmaco LIKE '%cetamina%' AND deleted_at IS NULL;

-- Listar fármacos por classe farmacológica
-- SELECT classe_farmacologica, COUNT(*) as total FROM farmacos WHERE deleted_at IS NULL GROUP BY classe_farmacologica ORDER BY total DESC;

-- Buscar fármacos com posologia para cães
-- SELECT farmaco, posologia_caes FROM farmacos WHERE posologia_caes IS NOT NULL AND deleted_at IS NULL;

-- Buscar fármacos com IVC
-- SELECT farmaco, ivc FROM farmacos WHERE ivc IS NOT NULL AND ivc != '' AND deleted_at IS NULL;

-- Busca full-text em fármacos
-- SELECT * FROM farmacos WHERE MATCH(titulo, farmaco, classe_farmacologica, nome_comercial, comentarios) AGAINST('anestesia' IN NATURAL LANGUAGE MODE) AND deleted_at IS NULL;

-- PARÂMETROS
-- Listar todos os parâmetros de uma espécie
-- SELECT * FROM parametros_veterinarios WHERE species = 'dog' AND deleted_at IS NULL ORDER BY category, parameter_name;

-- Parâmetros por categoria
-- SELECT category, COUNT(*) as total FROM parametros_veterinarios WHERE deleted_at IS NULL GROUP BY category ORDER BY total DESC;

-- Buscar parâmetro específico para todas as espécies
-- SELECT species, parameter_name, parameter_value FROM parametros_veterinarios WHERE parameter_name LIKE '%Frequência cardíaca%' AND deleted_at IS NULL;

-- Parâmetros cardiovasculares de cães
-- SELECT parameter_name, parameter_value, comments FROM parametros_veterinarios WHERE species = 'dog' AND category = 'Cardiovascular' AND deleted_at IS NULL;

-- Buscar parâmetros com comentários
-- SELECT species, parameter_name, comments FROM parametros_veterinarios WHERE comments IS NOT NULL AND deleted_at IS NULL;

-- Parâmetros com suas referências
-- SELECT p.species, p.parameter_name, p.parameter_value, r.referencia 
-- FROM parametros_veterinarios p 
-- LEFT JOIN parametros_referencias r ON p.id = r.parametro_id 
-- WHERE p.deleted_at IS NULL 
-- ORDER BY p.species, p.category, p.parameter_name, r.ordem;

-- ESTATÍSTICAS
-- SELECT 
--   (SELECT COUNT(*) FROM farmacos WHERE deleted_at IS NULL) as total_farmacos,
--   (SELECT COUNT(*) FROM parametros_veterinarios WHERE deleted_at IS NULL) as total_parametros,
--   (SELECT COUNT(DISTINCT classe_farmacologica) FROM farmacos WHERE deleted_at IS NULL) as total_classes,
--   (SELECT COUNT(DISTINCT category) FROM parametros_veterinarios WHERE deleted_at IS NULL) as total_categorias;