# Integração Backend-Frontend - Guia Rápido

## ✅ O que foi integrado

### 1. Serviços Criados

#### `lib/core/config/api_config.dart`
Configuração centralizada da API:
- URLs dos endpoints
- Configuração de timeouts
- Headers padrão e autenticados

#### `lib/services/api_service.dart`
Serviço base para comunicação HTTP:
- Métodos GET, POST, PUT, DELETE
- Tratamento de erros
- Gestão de token JWT
- Teste de conexão

#### `lib/services/auth_service.dart`
Serviço de autenticação:
- Login e registro
- Validação de token
- Persistência de sessão (SharedPreferences)
- Logout

#### `lib/services/medication_service.dart` (atualizado)
Serviço de medicamentos integrado:
- Carregamento de dados do backend
- Cache em memória (5 minutos)
- Busca online e fallback offline
- Parse de dados do CSV

### 2. Inicialização Automática

O `lib/main.dart` foi atualizado para:
- Inicializar o AuthService ao iniciar
- Carregar medicamentos do backend em background
- Fornecer AuthService via Provider
- Não bloquear a UI enquanto carrega dados

### 3. Scripts de Automação

#### `quick-start.ps1`
Inicia tudo com um comando.

#### `start.ps1`
Script completo com opções:
- Verifica dependências (Dart, Flutter, Dart Frog)
- Instala pacotes
- Prepara diretórios e arquivos
- Inicia backend
- Aguarda backend estar pronto
- Inicia frontend com hot reload

#### `create-admin.ps1`
Cria usuário administrador:
- Testa se backend está online
- Cria usuário via API
- Valida credenciais
- Testa login

#### `stop.ps1`
Para todos os serviços:
- Encerra jobs do PowerShell
- Mata processos na porta 8080

## 🚀 Como Usar

### Primeira vez

```powershell
# 1. Iniciar
.\quick-start.ps1

# 2. Criar admin (outro terminal)
.\create-admin.ps1

# 3. Login no app
# Email: admin@gdav.com
# Senha: Admin@2024!
```

### Uso diário

```powershell
# Iniciar
.\quick-start.ps1

# Desenvolver com hot reload...

# Parar
.\stop.ps1
```

## 🔌 Endpoints Disponíveis

```
GET    /api/v1/farmacos              - Lista todos (42 fármacos)
GET    /api/v1/farmacos/search?q=    - Busca por nome
GET    /api/v1/farmacos/species/:id  - Busca por espécie
POST   /api/v1/auth/register         - Registrar usuário
POST   /api/v1/auth/login            - Login
GET    /api/v1/auth/validate         - Validar token (requer auth)
```

## 📱 Como Usar no Flutter

### Carregar medicamentos

```dart
import 'package:gdav/services/medication_service.dart';

// Automático no startup (já configurado no main.dart)
// Ou manualmente:
await MedicationService.loadMedicationsFromBackend();

// Obter todos
final medications = MedicationService.getAllMedications();

// Buscar online
final results = await MedicationService.searchMedicationsOnline('dipirona');

// Por espécie
final dogMeds = await MedicationService.getMedicationsBySpecies('cão');
```

### Autenticação

```dart
import 'package:gdav/services/auth_service.dart';
import 'package:provider/provider.dart';

// Obter serviço
final authService = context.read<AuthService>();

// Login
try {
  final user = await authService.login('admin@gdav.com', 'Admin@2024!');
  print('Bem-vindo: ${user.email}');
} catch (e) {
  print('Erro: $e');
}

// Verificar se está logado
if (authService.isAuthenticated) {
  print('Usuário: ${authService.currentUser?.email}');
}

// Logout
await authService.logout();
```

### Requisições autenticadas

```dart
import 'package:gdav/services/api_service.dart';
import 'package:gdav/core/config/api_config.dart';

// O token é automaticamente incluído se o usuário estiver logado
final response = await ApiService.get(
  ApiConfig.validateTokenEndpoint,
  requiresAuth: true,
);
```

## 🎨 Tela de Login (Exemplo)

Uma tela de exemplo foi criada em `lib/features/auth/login_page.dart`.

Para usá-la, adicione rotas no seu app:

```dart
MaterialApp(
  routes: {
    '/login': (context) => const LoginPage(),
    '/home': (context) => const MainNavigationScreen(),
  },
  home: const LoginPage(), // ou MainNavigationScreen()
);
```

## 🔧 Configuração da URL

Por padrão, a API está configurada para `http://localhost:8080`.

Para mudar (ex: dispositivo físico):

```dart
import 'package:gdav/core/config/api_config.dart';

// No início do app
ApiConfig.setBaseUrl('http://192.168.1.100:8080');
```

Ou edite diretamente em `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static String _baseUrl = 'http://10.0.2.2:8080'; // Android emulator
  // static String _baseUrl = 'http://192.168.1.100:8080'; // Dispositivo físico
}
```

## 📊 Fluxo de Dados

```
┌─────────────┐
│  Flutter UI │
└──────┬──────┘
       │
       ▼
┌─────────────────────┐
│ MedicationService   │
│ AuthService         │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│   ApiService        │ ◄── Token JWT
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│  Dart Frog API      │
│  (localhost:8080)   │
└──────┬──────────────┘
       │
       ▼
┌─────────────────────┐
│ CSV/JSON Storage    │
└─────────────────────┘
```

## 🧪 Testar Manualmente

```powershell
# Listar fármacos
curl http://localhost:8080/api/v1/farmacos

# Buscar
curl "http://localhost:8080/api/v1/farmacos/search?q=dipirona"

# Registrar
curl -X POST http://localhost:8080/api/v1/auth/register `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"teste@test.com\",\"password\":\"Teste@123\"}'

# Login
curl -X POST http://localhost:8080/api/v1/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"admin@gdav.com\",\"password\":\"Admin@2024!\"}'
```

## 🐛 Debug

### Backend não responde

```powershell
# Verificar se está rodando
netstat -ano | findstr :8080

# Ver logs
Get-Job | Receive-Job

# Reiniciar
.\stop.ps1
.\start.ps1
```

### Frontend não conecta

1. Verifique a URL em `lib/core/config/api_config.dart`
2. Para emulador Android: use `http://10.0.2.2:8080`
3. Para iOS simulator: use `http://localhost:8080`
4. Para dispositivo físico: use o IP da sua máquina

### Erro de CORS (web)

Adicione middleware CORS no backend (veja SETUPGUIDE.md seção 3.1).

## ✨ Próximos Passos

1. **Adicionar tela de login** ao fluxo principal
2. **Implementar sincronização** de dados offline/online
3. **Adicionar refresh de token** automático
4. **Implementar favoritos** persistentes no backend
5. **Adicionar histórico** de cálculos
6. **Migrar para banco de dados** real (PostgreSQL/MongoDB)

## 📚 Referências

- [SETUPGUIDE.md](SETUPGUIDE.md) - Guia completo de setup
- [SCRIPTS.md](SCRIPTS.md) - Documentação dos scripts
- [README.md](README.md) - Visão geral do projeto
- [Dart Frog Docs](https://dartfrog.vgv.dev/)
- [Flutter HTTP](https://pub.dev/packages/http)
