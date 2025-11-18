# 🚀 Backend - GDVet Veterinário

Backend API REST desenvolvido com **Dart Frog** e **MySQL** para o sistema de gestão veterinária.

## 📋 Tecnologias

- **Dart Frog**: Framework para APIs REST em Dart
- **MySQL**: Banco de dados relacional
- **JWT**: Autenticação e autorização
- **Bcrypt**: Hash de senhas
- **UUID**: Identificadores únicos

## 🏗️ Estrutura do Projeto

```
backend/
├── lib/
│   ├── database/
│   │   ├── database.dart           # Configuração MySQL
│   │   ├── migrations/
│   │   │   └── initial_migration.dart
│   │   └── tables/
│   │       └── users_table.dart    # [Removido - SQL direto]
│   ├── models/
│   │   ├── user.dart              # Modelo de usuário robusto
│   │   ├── farmaco.dart
│   │   └── veterinary_parameter.dart
│   ├── services/
│   │   ├── user_repository.dart   # CRUD de usuários
│   │   ├── jwt_service.dart
│   │   └── password_service.dart
│   └── providers/
├── routes/
│   ├── api/
│   │   └── v1/
│   │       ├── auth/
│   │       ├── users/
│   │       └── farmacos/
│   └── _middleware.dart
├── scripts/
│   ├── setup_database.dart        # Setup completo
│   └── test_connection.dart       # Teste de conexão
├── database/
│   └── schema.sql                 # Schema SQL de referência
├── data/
│   └── [arquivos de dados]
├── .env.example                   # Exemplo de configuração
├── DATABASE.md                    # Documentação completa do BD
└── pubspec.yaml

```

## 🚀 Quick Start

### 1. Pré-requisitos

- Dart SDK ^3.0.0
- MySQL 8.0+ instalado e rodando
- (Opcional) Docker para MySQL

### 2. Instalação do MySQL

**Opção A - Docker (Recomendado):**
```powershell
docker run --name mysql-gdvet -e MYSQL_ROOT_PASSWORD=root -p 3306:3306 -d mysql:8.0
```

**Opção B - Windows:**
- Baixar [MySQL Community Server](https://dev.mysql.com/downloads/mysql/)
- Ou usar [XAMPP](https://www.apachefriends.org/)

### 3. Configurar Projeto

```powershell
# Entrar na pasta backend
cd backend

# Instalar dependências
dart pub get

# Copiar arquivo de configuração
copy .env.example .env

# Editar .env com suas credenciais
notepad .env
```

**Configurar .env:**
```env
DB_HOST=localhost
DB_PORT=3306
DB_NAME=gdav_veterinario
DB_USER=root
DB_PASSWORD=sua_senha_aqui
JWT_SECRET=seu_secret_key_super_secreto
ENVIRONMENT=development
```

### 4. Testar Conexão

```powershell
dart run scripts/test_connection.dart
```

### 5. Setup do Banco de Dados

```powershell
dart run scripts/setup_database.dart
```

Isso irá:
- ✅ Criar banco `gdav_veterinario`
- ✅ Criar tabela `users` com estrutura completa
- ✅ Inserir usuário admin padrão

### 6. Rodar o Servidor

```powershell
dart_frog dev
```

O servidor estará disponível em: `http://localhost:8080`

## 🔑 Credenciais Padrão

```
Email: admin@gdvet.com
Senha: admin123
```

⚠️ **IMPORTANTE**: Altere essa senha em produção!

## 📊 Banco de Dados

### Tabela de Usuários

A tabela `users` possui estrutura robusta com:
- ✅ UUID como Primary Key
- ✅ Email único
- ✅ Senha com hash bcrypt
- ✅ Roles (consumer, administrator)
- ✅ Status (active, inactive, suspended)
- ✅ Soft delete
- ✅ Auditoria (created_at, updated_at)
- ✅ Proteção contra brute force
- ✅ Bloqueio temporário após 5 tentativas

**Veja documentação completa:** [DATABASE.md](./DATABASE.md)

## 🔐 Segurança

### Autenticação
- JWT tokens com expiração
- Refresh tokens (a implementar)
- Bcrypt para hash de senhas

### Proteção
- Bloqueio automático após 5 tentativas falhadas
- Rate limiting (a implementar)
- CORS configurado
- Prepared statements (SQL injection protection)

## 📡 API Endpoints

### Autenticação
```
POST /api/v1/auth/login
POST /api/v1/auth/register
POST /api/v1/auth/refresh
GET  /api/v1/auth/me
```

### Usuários (Admin)
```
GET    /api/v1/users          # Listar todos
GET    /api/v1/users/:id      # Buscar por ID
POST   /api/v1/users          # Criar novo
PUT    /api/v1/users/:id      # Atualizar
DELETE /api/v1/users/:id      # Deletar (soft)
```

### Fármacos
```
GET    /api/v1/farmacos
GET    /api/v1/farmacos/:id
POST   /api/v1/farmacos
PUT    /api/v1/farmacos/:id
DELETE /api/v1/farmacos/:id
```

## 🧪 Testes

```powershell
# Rodar todos os testes
dart test

# Rodar teste específico
dart test test/models/user_test.dart

# Com coverage
dart test --coverage=coverage
```

## 🛠️ Scripts Úteis

```powershell
# Testar conexão com MySQL
dart run scripts/test_connection.dart

# Setup inicial do banco
dart run scripts/setup_database.dart

# Verificar análise de código
dart analyze

# Formatar código
dart format .
```

## 📝 Uso do Repositório

### Exemplo: Criar Usuário

```dart
import 'package:backend/database/database.dart';
import 'package:backend/services/user_repository.dart';
import 'package:backend/models/user.dart';
import 'package:bcrypt/bcrypt.dart';

Future<void> main() async {
  final db = AppDatabase();
  final repo = UserRepository(db);
  
  final passwordHash = BCrypt.hashpw('senha123', BCrypt.gensalt());
  
  final user = await repo.createUser(
    name: 'João Silva',
    email: 'joao@example.com',
    passwordHash: passwordHash,
    role: UserRole.consumer,
  );
  
  print('Usuário criado: ${user?.id}');
  
  await db.close();
}
```

## 🐛 Troubleshooting

### Erro: "Can't connect to MySQL"
1. Verifique se MySQL está rodando
2. Windows: Services → MySQL → Iniciar
3. Docker: `docker ps` → verificar container

### Erro: "Access denied"
1. Verificar credenciais no `.env`
2. Testar no terminal: `mysql -u root -p`

### Erro: "Database does not exist"
Execute: `dart run scripts/setup_database.dart`

### Porta 8080 em uso
```powershell
# Verificar processo
netstat -ano | findstr :8080

# Matar processo
taskkill /PID <PID> /F

# Ou usar outra porta
dart_frog dev --port 8081
```

## 📦 Dependências Principais

```yaml
dependencies:
  dart_frog: ^1.2.0          # Framework web
  mysql1: ^0.20.0            # Driver MySQL
  dart_jsonwebtoken: ^2.14.0 # JWT
  bcrypt: ^1.1.3             # Hash de senhas
  uuid: ^4.3.3               # Geradores UUID
  csv: ^6.0.0                # Parser CSV
```

## 🔄 Desenvolvimento

### Adicionar Nova Rota

1. Criar arquivo em `routes/api/v1/`
2. Implementar handlers (GET, POST, PUT, DELETE)
3. Adicionar middleware se necessário
4. Documentar endpoint

### Adicionar Nova Coluna

1. Adicionar no modelo em `lib/models/`
2. Criar migration em `lib/database/migrations/`
3. Atualizar repositório em `lib/services/`
4. Rodar migration

### Boas Práticas

- ✅ Use repository pattern
- ✅ Valide inputs
- ✅ Use prepared statements
- ✅ Trate exceções adequadamente
- ✅ Documente código
- ✅ Escreva testes
- ✅ Use soft delete quando apropriado

## 📚 Documentação Adicional

- [DATABASE.md](./DATABASE.md) - Documentação completa do banco
- [Dart Frog Docs](https://dartfrog.vgv.dev/)
- [MySQL Docs](https://dev.mysql.com/doc/)

## 👥 Contribuindo

1. Crie uma branch: `git checkout -b feature/nova-feature`
2. Commit: `git commit -m 'Add nova feature'`
3. Push: `git push origin feature/nova-feature`
4. Abra um Pull Request

## 📄 Licença

Este projeto é privado e proprietário.

## 📧 Contato

Para dúvidas ou suporte, entre em contato com a equipe de desenvolvimento.
