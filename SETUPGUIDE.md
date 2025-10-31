
# Guia de Configuração e Desenvolvimento (SETUPGUIDE.md)

Este guia fornece instruções detalhadas para configurar o ambiente de desenvolvimento, compilar e executar tanto o **Frontend (Flutter)** quanto o **Backend (Dart Frog API)** do projeto **Vet Anesthesia Helper**.

---

## 📋 Índice

1. [Frontend Flutter](#1-frontend-flutter)
   - Pré-requisitos
   - Instalação
   - Execução
   - Build para Produção
2. [Backend Dart Frog API](#2-backend-dart-frog-api)
   - Arquitetura
   - Instalação e Configuração
   - Testando a API
   - Segurança e Validações
   - Integração com Flutter
   - Deploy para Produção
3. [Troubleshooting](#3-troubleshooting)

---

## 1. Frontend Flutter

## 1. Pré-requisitos

### Frontend Flutter

Antes de começar, certifique-se de que você tem as seguintes ferramentas instaladas e configuradas em sua máquina:

- **Git:** Para clonar o repositório. [Download Git](https://git-scm.com/downloads)
- **Flutter SDK:** Versão `>=3.0.0`. O Flutter SDK inclui o Dart SDK. [Instalação do Flutter](https://flutter.dev/docs/get-started/install)
- **Um Editor de Código:**
  - **Visual Studio Code:** Com a extensão [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter).
  - **Android Studio:** Com o plugin [Flutter](https://flutter.dev/docs/get-started/editor?tab=androidstudio).
- **Configuração de Plataforma Específica:**
  - **Android:** Android Studio para instalar o Android SDK e as ferramentas de linha de comando.
  - **iOS (apenas em macOS):** Xcode para compilar para dispositivos iOS.
  - **Web:** Google Chrome para desenvolvimento web.

### Verificando a Instalação do Flutter

Após instalar o Flutter, execute o seguinte comando no seu terminal para verificar se há alguma dependência faltando:

```bash
flutter doctor
```

O `flutter doctor` irá analisar sua configuração e mostrar um relatório do status da sua instalação. Resolva quaisquer problemas (`[!]`) que ele apontar antes de prosseguir.

## 2. Clonando o Repositório

Use o Git para clonar o projeto para sua máquina local:

```bash
git clone https://github.com/Marcao-Martins/App-dimitri.git
cd App-dimitri
```

## 3. Instalando as Dependências

Com o repositório clonado, o próximo passo é instalar todas as dependências do projeto listadas no arquivo `pubspec.yaml`.

Execute o seguinte comando na raiz do projeto:

```bash
flutter pub get
```

Este comando irá baixar todas as bibliotecas necessárias para o projeto.

## 4. Configurando o Ambiente de Execução

### Android
1.  Abra o Android Studio.
2.  Vá para `Tools > AVD Manager` e crie um novo Emulador Android (AVD).
3.  Inicie o emulador.
4.  Alternativamente, conecte um dispositivo Android físico via USB e ative o modo de desenvolvedor e a depuração USB.

### iOS (apenas macOS)
1.  Abra o Xcode.
2.  Conecte um dispositivo iOS físico ou use o Simulador (`Xcode > Open Developer Tool > Simulator`).
3.  Para rodar em um dispositivo físico, pode ser necessário configurar a assinatura de código no Xcode.

### Web
Nenhuma configuração adicional é necessária. O Flutter usará o Google Chrome (se instalado) como o dispositivo padrão para desenvolvimento web.

## 5. Executando o Aplicativo

Com o ambiente configurado e um dispositivo/emulador em execução, você pode iniciar o aplicativo.

1.  **Verifique os dispositivos conectados:**
    ```bash
    flutter devices
    ```
    Este comando listará todos os emuladores, simuladores e dispositivos físicos disponíveis.

2.  **Execute o aplicativo:**
    - Para executar no dispositivo selecionado:
      ```bash
      flutter run
      ```
    - Para selecionar um dispositivo específico (se vários estiverem disponíveis):
      ```bash
      flutter run -d <device_id>
      ```
      (Substitua `<device_id>` pelo ID do dispositivo da lista `flutter devices`).

O aplicativo será compilado e instalado no dispositivo. O modo de depuração inclui o **Hot Reload**, que permite aplicar alterações no código quase instantaneamente sem reiniciar o app.

## 6. Estrutura do Projeto

A estrutura de pastas principal do código-fonte está em `lib/`:

```
lib/
├── main.dart               # Ponto de entrada da aplicação e navegação principal
├── core/                   # Widgets, constantes, temas e utilitários compartilhados
│   ├── constants/
│   ├── providers/
│   ├── themes/
│   ├── utils/
│   └── widgets/
├── features/               # Módulos de funcionalidades principais
│   ├── dose_calculator/
│   ├── drug_guide/
│   ├── explorer/           # Tela inicial
│   ├── ficha_anestesica/
│   ├── fluidotherapy/      # Calculadora de Fluidoterapia
│   ├── pre_op_checklist/
│   ├── rcp/                # Módulo de RCP Coach
│   └── transfusion/        # Calculadora de Transfusão
├── models/                 # Modelos de dados usados em múltiplos features
└── services/               # Serviços (ex: PDF, armazenamento)
```

## 7. Compilando para Produção (Build)

Quando o aplicativo estiver pronto para ser lançado, use os seguintes comandos para gerar os pacotes de produção:

### Android

- **APK (pacote único):**
  ```bash
  flutter build apk --release
  ```
  O arquivo de saída estará em `build/app/outputs/flutter-apk/app-release.apk`.

- **App Bundle (recomendado para a Google Play Store):**
  ```bash
  flutter build appbundle --release
  ```
  O arquivo de saída estará em `build/app/outputs/bundle/release/app-release.aab`.

### iOS (apenas macOS)

1.  Execute o comando de build:
    ```bash
    flutter build ipa --release
    ```
2.  Abra o projeto no Xcode (`ios/Runner.xcworkspace`).
3.  Configure a versão e o build number.
4.  Use o Xcode para arquivar e distribuir o aplicativo para a App Store Connect.

### Web

```bash
flutter build web --release
```
O conteúdo da pasta `build/web` pode ser hospedado em qualquer serviço de hospedagem web (Firebase Hosting, Netlify, etc.).

## 8. Troubleshooting Comum

- **Problemas de dependências ou build:**
  Tente limpar o cache de build do Flutter:
  ```bash
  flutter clean
  flutter pub get
  ```

- **O app não roda ou apresenta erros inesperados:**
  Verifique novamente a sua instalação com `flutter doctor` para garantir que tudo está configurado corretamente.

- **Problemas específicos de plataforma (Android/iOS):**
  - **Android:** Verifique se o `build.gradle` e `local.properties` estão corretos.
  - **iOS:** Abra o projeto no Xcode (`ios/Runner.xcworkspace`) para verificar se há problemas de configuração de pods ou de assinatura de código. Execute `pod install` no diretório `ios/`.

---
**Última atualização:** 31 de Outubro de 2025

---

## 2. Backend Dart Frog API

O backend é uma API RESTful completa desenvolvida com **Dart Frog**, fornecendo autenticação de usuários e gerenciamento centralizado dos dados de fármacos veterinários.

### 2.1. Arquitetura do Backend

#### Visão Geral

```
backend/
├── lib/                    # Lógica de negócio
│   ├── models/             # Modelos de dados
│   ├── services/           # Serviços (JWT, Password)
│   └── providers/          # Camada de acesso a dados
├── routes/                 # Endpoints da API
│   ├── _middleware.dart    # Middleware global
│   └── api/v1/             # API versão 1
├── data/                   # Armazenamento (placeholder)
├── test/                   # Testes unitários
└── tool/                   # Scripts utilitários
```

#### Camadas da Aplicação

**1. Models (Modelos de Dados)**
- `farmaco.dart`: Representa um fármaco veterinário
- `user.dart`: Representa um usuário com enum UserRole (consumer/administrator)
- Todos os modelos possuem serialização JSON (`fromJson`/`toJson`)

**2. Services (Serviços)**
- `jwt_service.dart`: Geração e validação de tokens JWT
- `password_service.dart`: Hash bcrypt, validação e geração de senhas seguras

**3. Providers (Acesso a Dados)**
- `database_provider.dart`: Gerencia fármacos (atualmente CSV em memória)
- `user_provider.dart`: Gerencia usuários (atualmente JSON em arquivo)

⚠️ **Importante:** Os providers atuais são **placeholders para desenvolvimento**. Para produção, devem ser substituídos por conexões com banco de dados real (PostgreSQL, MongoDB, etc).

**4. Routes (Endpoints HTTP)**
- Middleware global: Inicializa providers na primeira requisição
- Middleware de autenticação: Valida tokens JWT em rotas protegidas
- Rotas públicas: Não requerem autenticação
- Rotas protegidas: Requerem token JWT válido
- Rotas admin: Requerem token JWT com role de administrator

#### Fluxo de Autenticação

```
1. Usuário faz POST /api/v1/auth/register
   ↓
2. Backend valida dados e cria usuário (senha hasheada com bcrypt)
   ↓
3. Usuário faz POST /api/v1/auth/login
   ↓
4. Backend valida credenciais e gera token JWT (validade 24h)
   ↓
5. Cliente armazena token e envia em requisições futuras
   ↓
6. Middleware valida token em cada requisição protegida
```

### 2.2. Instalação e Configuração

#### Pré-requisitos

- **Dart SDK** `>=3.0.0` (incluído no Flutter)
- **Dart Frog CLI**

#### Passo 1: Instalar Dart Frog CLI

```bash
dart pub global activate dart_frog_cli
```

Verifique a instalação:
```bash
dart_frog --version
```

#### Passo 2: Navegar para o diretório do backend

```bash
cd backend
```

#### Passo 3: Instalar dependências

```bash
dart pub get
```

As dependências principais são:
- `dart_frog: ^2.0.0` - Framework web
- `dart_jsonwebtoken: ^2.14.0` - Geração/validação JWT
- `bcrypt: ^1.1.3` - Hash de senhas
- `csv: ^6.0.0` - Parse do CSV de fármacos

#### Passo 4: Iniciar o servidor de desenvolvimento

```bash
dart_frog dev
```

O servidor iniciará em `http://localhost:8080` com **hot reload** ativo.

Você verá mensagens como:
```
✅ 42 fármacos carregados do CSV
✅ 0 usuários carregados do JSON
✅ Provedores inicializados com sucesso
```

### 2.3. Endpoints da API

#### Rota Raiz

**GET /**
- Retorna informações sobre a API
- Rota pública

```bash
curl http://localhost:8080/
```

Resposta:
```json
{
  "name": "API Veterinária - Fármacos e Autenticação",
  "version": "1.0.0",
  "status": "online",
  "endpoints": {
    "public": [...],
    "protected": [...],
    "admin": [...]
  }
}
```

#### Autenticação

**POST /api/v1/auth/register**
- Registra novo usuário
- Rota pública
- Role padrão: `consumer`

Corpo da requisição:
```json
{
  "name": "Dr. João Silva",
  "email": "joao@example.com",
  "password": "Senha@123Forte"
}
```

Requisitos de senha:
- ✅ Mínimo 8 caracteres (máximo 128)
- ✅ Pelo menos uma letra maiúscula (A-Z)
- ✅ Pelo menos uma letra minúscula (a-z)
- ✅ Pelo menos um número (0-9)
- ✅ Pelo menos um caractere especial (!@#$%^&*()_+-=[]{}|;:,.<>?)
- ✅ Não pode ser senha comum (password123, Admin123!, etc)

Exemplo com curl (Windows PowerShell):
```bash
curl -X POST http://localhost:8080/api/v1/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Dr. João Silva\",\"email\":\"joao@example.com\",\"password\":\"Senha@123Forte\"}"
```

Resposta (201 Created):
```json
{
  "success": true,
  "message": "Usuário criado com sucesso",
  "user": {
    "id": "1730419200000",
    "name": "Dr. João Silva",
    "email": "joao@example.com",
    "role": "consumer"
  }
}
```

**POST /api/v1/auth/login**
- Autentica usuário e retorna token JWT
- Rota pública

Corpo da requisição:
```json
{
  "email": "joao@example.com",
  "password": "Senha@123Forte"
}
```

Exemplo:
```bash
curl -X POST http://localhost:8080/api/v1/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"joao@example.com\",\"password\":\"Senha@123Forte\"}"
```

Resposta (200 OK):
```json
{
  "success": true,
  "message": "Login realizado com sucesso",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxNzMwNDE5MjAwMDAwIiwiZW1haWwiOiJqb2FvQGV4YW1wbGUuY29tIiwicm9sZSI6ImNvbnN1bWVyIiwiaWF0IjoxNzMwNDE5MjAwLCJleHAiOjE3MzA1MDU2MDB9.signature",
  "user": {
    "id": "1730419200000",
    "name": "Dr. João Silva",
    "email": "joao@example.com",
    "role": "consumer"
  }
}
```

⚠️ **IMPORTANTE**: Copie o token para usar nas requisições protegidas!

#### Fármacos

**GET /api/v1/farmacos**
- Lista todos os fármacos
- Rota pública
- Suporta filtros via query params

Exemplos:
```bash
# Listar todos
curl http://localhost:8080/api/v1/farmacos

# Buscar por nome
curl "http://localhost:8080/api/v1/farmacos?search=cetamina"

# Filtrar por classe
curl "http://localhost:8080/api/v1/farmacos?classe=Opioides"
```

Resposta:
```json
{
  "success": true,
  "count": 42,
  "data": [
    {
      "post_id": "4661",
      "titulo": "Acepromazina",
      "farmaco": "Acepromazina",
      "classe_farmacologica": "Fenotiazínicos",
      "nome_comercial": "Acepran 0,2% (2 mg/mL)",
      "mecanismo_de_acao": "Antagonista D2 com bloqueio α1 e H1",
      "posologia_caes": "0,01-0,05 mg/kg IM q30-90 min",
      "posologia_gatos": "0,025-0,1 mg/kg IM q30-90 min",
      ...
    },
    ...
  ]
}
```

**POST /api/v1/farmacos**
- Adiciona novo fármaco
- Rota protegida (requer autenticação)
- Requer role de `administrator`

Corpo da requisição:
```json
{
  "farmaco": "Nome do Fármaco",
  "titulo": "Título",
  "classe_farmacologica": "Classe",
  "nome_comercial": "Nome Comercial",
  "mecanismo_de_acao": "Mecanismo...",
  "posologia_caes": "Dose para cães",
  "posologia_gatos": "Dose para gatos"
}
```

Exemplo:
```bash
curl -X POST http://localhost:8080/api/v1/farmacos ^
  -H "Authorization: Bearer SEU_TOKEN_AQUI" ^
  -H "Content-Type: application/json" ^
  -d "{\"farmaco\":\"Teste\",\"titulo\":\"Teste\",\"classe_farmacologica\":\"Teste\"}"
```

⚠️ **Nota**: Dados adicionados são salvos apenas em memória e serão perdidos ao reiniciar o servidor (modo desenvolvimento).

#### Perfil do Usuário

**GET /api/v1/profile**
- Retorna perfil do usuário logado
- Rota protegida (requer autenticação)

Exemplo:
```bash
curl http://localhost:8080/api/v1/profile ^
  -H "Authorization: Bearer SEU_TOKEN_AQUI"
```

Resposta:
```json
{
  "success": true,
  "user": {
    "id": "1730419200000",
    "name": "Dr. João Silva",
    "email": "joao@example.com",
    "role": "consumer"
  }
}
```

### 2.4. Segurança e Validações

#### Hash de Senhas

- **Algoritmo**: bcrypt
- **Rounds**: 12 (custo computacional adequado para segurança vs performance)
- **Salt**: Único para cada senha
- **Armazenamento**: Apenas o hash é salvo, nunca a senha em texto plano

Exemplo de hash gerado:
```
$2b$12$KIXx8VfN5q2.Q1QrZvHG7eP8vN5yT9wJ3kL2mR4sX6uY8zW0aB1cD
```

#### JSON Web Tokens (JWT)

- **Secret**: Definido em `lib/services/jwt_service.dart` (⚠️ deve ser variável de ambiente em produção)
- **Algoritmo**: HS256 (HMAC SHA-256)
- **Validade**: 24 horas
- **Payload**:
  ```json
  {
    "userId": "123",
    "email": "user@example.com",
    "role": "consumer",
    "iat": 1730419200,
    "exp": 1730505600
  }
  ```

#### Validação de Senhas

O `PasswordService` implementa validações rigorosas:

1. **Comprimento**: 8-128 caracteres
2. **Complexidade**:
   - Pelo menos uma maiúscula
   - Pelo menos uma minúscula
   - Pelo menos um número
   - Pelo menos um caractere especial
3. **Lista negra**: Rejeita senhas comuns (password123, Admin123!, etc)
4. **Força da senha**: Método `getPasswordStrength()` retorna score 0-4
5. **Gerador**: Método `generateStrongPassword()` cria senhas seguras

Exemplo de uso no código:
```dart
// Validar senha
final error = PasswordService.validatePassword('minhasenha');
if (error != null) {
  print('Senha inválida: $error');
}

// Verificar força
final strength = PasswordService.getPasswordStrength('Abc123!@#');
// Retorna: 0=muito fraca, 1=fraca, 2=moderada, 3=forte, 4=muito forte

// Gerar senha forte
final senha = PasswordService.generateStrongPassword(length: 16);
print(senha); // Ex: "Kx7@mP2#Qw9!Zb4R"
```

#### Autorização por Roles

Dois níveis de acesso:

1. **consumer** (padrão)
   - Acesso a rotas públicas
   - Acesso a rotas protegidas (perfil)
   - Não pode adicionar/editar fármacos

2. **administrator**
   - Todos os acessos do consumer
   - Pode adicionar/editar/remover fármacos
   - Pode gerenciar usuários

### 2.5. Criar Usuário Administrador

Para criar um usuário com permissões administrativas:

```bash
cd backend
dart run tool/create_admin.dart
```

O script solicitará:
1. Nome do administrador
2. Email
3. Senha (mínimo 8 caracteres com os requisitos de segurança)

O usuário será salvo em `data/users.json` com role `administrator`.

### 2.6. Integração com Flutter

#### Dependências Necessárias no Flutter

Adicione ao `pubspec.yaml` do app Flutter:

```yaml
dependencies:
  http: ^1.1.0  # Para requisições HTTP
  flutter_secure_storage: ^9.0.0  # Armazenamento seguro de token
```

#### Service de API no Flutter

Crie `lib/services/api_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  // Configure conforme seu ambiente
  static const String baseUrl = 'http://localhost:8080';
  
  final _storage = const FlutterSecureStorage();
  
  // Headers padrão
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };
  
  // Headers com autenticação
  Future<Map<String, String>> get _authHeaders async {
    final token = await _storage.read(key: 'auth_token');
    return {
      ..._headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Registro
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro ao registrar');
    }
  }
  
  // Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Salva o token
      await _storage.write(key: 'auth_token', value: data['token']);
      return data;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro ao fazer login');
    }
  }
  
  // Obter fármacos
  Future<List<dynamic>> getFarmacos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/farmacos'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] as List<dynamic>;
    } else {
      throw Exception('Erro ao carregar fármacos');
    }
  }
  
  // Obter perfil
  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/profile'),
      headers: await _authHeaders,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token inválido - fazer logout
      await _storage.delete(key: 'auth_token');
      throw Exception('Sessão expirada');
    } else {
      throw Exception('Erro ao obter perfil');
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

#### Exemplo de Uso no Flutter

```dart
// Tela de login
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _apiService = ApiService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  Future<void> _login() async {
    setState(() => _isLoading = true);
    
    try {
      final result = await _apiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bem-vindo, ${result['user']['name']}!')),
      );
      
      Navigator.pushReplacementNamed(context, '/home');
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Entrar'),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Configuração de URL por Ambiente

Para diferentes ambientes (desenvolvimento/produção):

```dart
abstract class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8080',
  );
}

// Usar no ApiService
static String get baseUrl => Environment.apiUrl;
```

Executar com URL customizada:
```bash
flutter run --dart-define=API_URL=https://api.production.com
```

### 2.7. Testando o Backend

#### Testes Unitários

O backend inclui testes unitários para models e services:

```bash
cd backend
dart test
```

Os testes cobrem:
- ✅ Hash e verificação de senhas
- ✅ Geração e validação de JWT
- ✅ Validação de força de senha
- ✅ Serialização de modelos
- ✅ Verificação de roles

#### Testes Manuais com curl

Exemplo de fluxo completo:

```bash
# 1. Ver status da API
curl http://localhost:8080/

# 2. Registrar usuário
curl -X POST http://localhost:8080/api/v1/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Test User\",\"email\":\"test@example.com\",\"password\":\"Senha@123\"}"

# 3. Fazer login (copie o token)
curl -X POST http://localhost:8080/api/v1/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"test@example.com\",\"password\":\"Senha@123\"}"

# 4. Ver perfil (substitua TOKEN)
curl http://localhost:8080/api/v1/profile ^
  -H "Authorization: Bearer TOKEN"

# 5. Listar fármacos
curl http://localhost:8080/api/v1/farmacos

# 6. Buscar fármaco
curl "http://localhost:8080/api/v1/farmacos?search=cetamina"
```

### 2.8. Deploy para Produção

⚠️ **CRÍTICO**: O backend atual é um **PLACEHOLDER PARA DESENVOLVIMENTO** e não está pronto para produção!

#### Antes de fazer deploy, você DEVE:

**1. Migrar para Banco de Dados Real**

Substitua `database_provider.dart` e `user_provider.dart` por conexões com:
- PostgreSQL (recomendado)
- MongoDB
- MySQL/MariaDB

Exemplo com PostgreSQL:
```yaml
# pubspec.yaml
dependencies:
  postgres: ^3.0.0
```

```dart
// Criar pool de conexões
final connection = PostgreSQLConnection(
  'host',
  5432,
  'database',
  username: 'user',
  password: 'password',
  allowReuse: true,
);

await connection.open();
```

**2. Usar Variáveis de Ambiente**

Nunca deixe secrets hardcoded!

```dart
// lib/services/jwt_service.dart
import 'dart:io';

static final String _secret = Platform.environment['JWT_SECRET'] 
    ?? throw Exception('JWT_SECRET não configurado');
```

Criar arquivo `.env`:
```
JWT_SECRET=seu-secret-super-seguro-aqui-minimo-32-caracteres
DATABASE_URL=postgresql://user:pass@host:5432/dbname
```

**3. Adicionar Recursos Essenciais**

- [ ] Rate limiting (proteção contra brute force)
- [ ] CORS configurável
- [ ] Logs estruturados (package `logging`)
- [ ] Monitoramento (Sentry, DataDog)
- [ ] Health check endpoint
- [ ] Paginação em todas as listas
- [ ] Cache (Redis)
- [ ] Backup automático do banco
- [ ] SSL/TLS obrigatório
- [ ] Documentação OpenAPI/Swagger

**4. Docker**

Criar `Dockerfile`:
```dockerfile
FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
RUN dart pub global activate dart_frog_cli
RUN dart_frog build

FROM scratch
COPY --from=build /app/build/ /app/
EXPOSE 8080
CMD ["/app/bin/server"]
```

Criar `docker-compose.yml`:
```yaml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=${DATABASE_URL}
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - db
  
  db:
    image: postgres:15
    environment:
      - POSTGRES_DB=vetdb
      - POSTGRES_USER=vetuser
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

**5. CI/CD**

Exemplo de GitHub Actions:
```yaml
name: Deploy Backend
on:
  push:
    branches: [main]
    paths:
      - 'backend/**'

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: dart-lang/setup-dart@v1
      - name: Install dependencies
        run: |
          cd backend
          dart pub get
      - name: Run tests
        run: |
          cd backend
          dart test
      - name: Build
        run: |
          cd backend
          dart pub global activate dart_frog_cli
          dart_frog build
      # Adicione steps de deploy aqui
```

#### Checklist de Segurança para Produção

- [ ] Secret JWT em variável de ambiente
- [ ] Banco de dados com backup automático
- [ ] Rate limiting implementado
- [ ] CORS configurado corretamente
- [ ] HTTPS obrigatório
- [ ] Logs não contêm dados sensíveis
- [ ] Validação rigorosa de input
- [ ] Refresh tokens implementados
- [ ] Auditoria de ações administrativas
- [ ] Monitoramento e alertas configurados

---

## 3. Troubleshooting

### 3.1. Problemas Comuns do Backend

#### Erro: "Cannot find file: farmacos_veterinarios.csv"
**Causa**: O arquivo CSV de dados não está no local esperado.
**Solução**:
```bash
# Verifique se o arquivo existe
ls backend/data/farmacos_veterinarios.csv

# Se não existir, copie do diretório raiz
cp farmacos_veterinarios.csv backend/data/
```

#### Erro: "Invalid token" ou "Token expired"
**Causa**: Token JWT expirado (24h de validade) ou inválido.
**Solução**:
1. Faça login novamente para obter novo token
2. Verifique se o secret JWT está correto
3. No desenvolvimento, use o token recém-gerado

```dart
// No Flutter, implemente refresh automático
if (response.statusCode == 401) {
  await _authService.refreshToken();
  // Tente a requisição novamente
}
```

#### Erro: "Email already exists"
**Causa**: Tentativa de criar usuário com email já cadastrado.
**Solução**:
- Verifique o arquivo `backend/data/users.json`
- Use email diferente ou exclua o usuário existente

```bash
# Ver usuários cadastrados
cat backend/data/users.json | ConvertFrom-Json
```

#### Erro: "Password does not meet security requirements"
**Causa**: Senha não atende aos requisitos de segurança.
**Solução**:
A senha deve ter:
- Entre 8 e 128 caracteres
- Pelo menos uma letra maiúscula
- Pelo menos uma letra minúscula
- Pelo menos um número
- Pelo menos um caractere especial (@$!%*?&)
- Não pode ser senha comum (password123, etc.)

```dart
// Exemplo de senha válida
final validPassword = 'VetApp@2024';
```

#### Erro: "Failed to start server on port 8080"
**Causa**: Porta 8080 já está em uso.
**Solução**:

**Windows PowerShell**:
```powershell
# Encontrar processo usando a porta 8080
netstat -ano | findstr :8080

# Matar o processo (substitua PID pelo número encontrado)
taskkill /PID <PID> /F

# Ou mudar a porta do servidor
# Em backend/routes/index.dart, use porta diferente
```

**Alterar porta** (se necessário):
```dart
// backend/main.dart
import 'dart:io';

Future<HttpServer> run(Handler handler, InterceptorMiddleware middleware) {
  return serve(
    handler.use(middleware),
    InternetAddress.anyIPv4,
    int.fromEnvironment('PORT', defaultValue: 3000), // Porta 3000
  );
}
```

#### Erro ao executar testes
**Causa**: Dependências não instaladas ou arquivo de dados ausente.
**Solução**:

```powershell
cd backend

# Reinstalar dependências
dart pub get

# Garantir que arquivo CSV existe
cp ../farmacos_veterinarios.csv data/

# Executar testes com verbose
dart test --reporter=expanded

# Testar arquivo específico
dart test test/services/password_service_test.dart
```

#### Desempenho lento na busca de medicamentos
**Causa**: Carregamento do CSV acontece a cada requisição.
**Solução implementada**: O serviço já usa cache em memória.

Para melhorar ainda mais:
```dart
// backend/lib/services/medication_service.dart
// Já implementado - o cache persiste durante execução do servidor
// Para cache mais agressivo, considere Redis em produção
```

#### Erro de conexão do Flutter com backend
**Causa**: URL incorreta ou servidor não está rodando.
**Solução**:

```dart
// Para teste em dispositivo físico, use IP da máquina
final baseUrl = 'http://192.168.1.100:8080'; // IP da sua máquina

// Para emulador Android
final baseUrl = 'http://10.0.2.2:8080';

// Para emulador iOS/Simulador
final baseUrl = 'http://localhost:8080';

// Testar conectividade
void testConnection() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/api/health'));
    print('Status: ${response.statusCode}');
  } catch (e) {
    print('Erro de conexão: $e');
  }
}
```

#### Erro CORS em navegador (web)
**Causa**: Política CORS não permite requisições do navegador.
**Solução**:

```dart
// backend/routes/index.dart
import 'package:shelf/shelf.dart';

Middleware corsMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: _corsHeaders);
      }
      
      final response = await handler(request);
      return response.change(headers: _corsHeaders);
    };
  };
}

const _corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
};

// Aplicar no middleware
Handler router = const Pipeline()
    .addMiddleware(corsMiddleware())
    .addMiddleware(loggingMiddleware())
    .addHandler(_router);
```

### 3.2. Logs e Debugging

#### Habilitar logs detalhados

```dart
// backend/routes/index.dart
import 'package:shelf/shelf.dart';

Middleware loggingMiddleware() {
  return logRequests(logger: (message, isError) {
    if (isError) {
      print('[ERROR] $message');
    } else {
      print('[INFO] $message');
    }
  });
}
```

#### Verificar estado do servidor

```powershell
# Testar endpoint de health (criar se não existir)
curl http://localhost:8080/api/health

# Ver logs do servidor
# Os logs aparecem no terminal onde você executou dart_frog dev
```

### 3.3. Problemas de Produção

#### Servidor cai após algum tempo
**Possíveis causas**:
1. Memory leak
2. Exceções não tratadas
3. Limite de recursos do servidor

**Soluções**:
- Implementar health checks
- Usar PM2 ou Docker com restart automático
- Adicionar tratamento de exceções global
- Monitorar uso de memória

```dart
// Tratamento global de exceções
Future<Response> safeHandler(Future<Response> Function() handler) async {
  try {
    return await handler();
  } catch (e, stackTrace) {
    print('Error: $e');
    print('Stack trace: $stackTrace');
    return Response.internalServerError(
      body: json.encode({
        'error': 'Internal server error',
        'message': 'Something went wrong',
      }),
    );
  }
}
```

#### Problema de performance com muitos usuários
**Soluções**:
1. Implementar rate limiting
2. Adicionar cache com Redis
3. Usar load balancer
4. Otimizar queries (quando migrar para banco real)
5. Implementar CDN para assets estáticos

---

## 4. Próximos Passos

Após configurar frontend e backend:

1. **Testar integração completa**
   - Login/logout funcionando
   - Busca de medicamentos retornando dados
   - Cálculo de doses usando API

2. **Implementar features faltantes**
   - Favoritos persistentes (requer backend)
   - Histórico de cálculos (requer backend)
   - Sincronização entre dispositivos

3. **Preparar para produção**
   - Migrar de CSV/JSON para PostgreSQL/MongoDB
   - Implementar CI/CD
   - Configurar monitoramento (Sentry, DataDog)
   - Adicionar analytics
   - Fazer testes de carga

4. **Documentar para equipe**
   - API documentation (Swagger/OpenAPI)
   - Guia de contribuição
   - Arquitetura atualizada
   - Runbooks para operações

---

## 3. Troubleshooting
