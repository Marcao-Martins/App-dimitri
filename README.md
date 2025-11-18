
# GDVet - Guia de Desenvolvimento Veterinário

Aplicativo mobile completo para auxiliar profissionais veterinários, com backend API integrado.

## 🚀 Início Rápido

```powershell
# Inicie o aplicativo (backend + frontend automaticamente)
.\quick-start.ps1

# Em outro terminal, crie um usuário admin (opcional para recursos avançados)
.\create-admin.ps1
```

**Pronto!** O script configura e inicia tudo automaticamente.

📖 **Documentação completa**: [SETUPGUIDE.md](SETUPGUIDE.md) | [SCRIPTS.md](SCRIPTS.md)

---

## 📱 Sobre o Aplicativo

O Vet Anesthesia Helper é um aplicativo móvel completo, desenvolvido em Flutter, para auxiliar médicos veterinários e estudantes de veterinária em diversas tarefas relacionadas à anestesiologia. O aplicativo oferece um conjunto de ferramentas para cálculos de doses, guias de medicamentos, checklists pré-operatórios, e módulos especializados para RCP, fluidoterapia e transfusão.

Este projeto agora inclui um **backend API completo** desenvolvido em Dart Frog para gerenciamento centralizado de dados de medicamentos.

---

## 📚 Arquitetura do Projeto

### Frontend (Flutter)

Aplicativo móvel multiplataforma com interface intuitiva para médicos veterinários.

### Backend (Dart Frog API)

API RESTful completa para gerenciamento de dados e autenticação:

#### 🔐 Segurança
- **Autenticação JWT:** Tokens com expiração de 24 horas
- **Hash de Senhas:** bcrypt com 12 rounds de salt
- **Autorização por Roles:** Dois níveis de acesso (consumer e administrator)
- **Validação Rigorosa de Senhas:**
  - Mínimo 8 caracteres (máximo 128)
  - Pelo menos uma letra maiúscula
  - Pelo menos uma letra minúscula
  - Pelo menos um número
  - Pelo menos um caractere especial
  - Proteção contra senhas comuns

#### 📡 Endpoints da API

**Rotas Públicas:**
- `GET /` - Informações da API
- `GET /api/v1/farmacos` - Lista completa de fármacos
- `GET /api/v1/farmacos?search=nome` - Busca por nome
- `GET /api/v1/farmacos?classe=classe` - Filtro por classe farmacológica
- `POST /api/v1/auth/register` - Registro de novo usuário
- `POST /api/v1/auth/login` - Login e obtenção de token JWT

**Rotas Protegidas (requer autenticação):**
- `GET /api/v1/profile` - Perfil do usuário logado

**Rotas Administrativas (requer role de administrator):**
- `POST /api/v1/farmacos` - Adicionar novo fármaco

#### 🗄️ Armazenamento (Desenvolvimento)

⚠️ **Nota:** A versão atual usa armazenamento em arquivos para facilitar o desenvolvimento:
- **Fármacos:** CSV carregado em memória
- **Usuários:** JSON com persistência

Para produção, é necessário migrar para um banco de dados real (PostgreSQL recomendado).

#### 🛠️ Tecnologias do Backend

- **Framework:** Dart Frog 2.0
- **JWT:** dart_jsonwebtoken 2.14.0
- **Hash de Senhas:** bcrypt 1.1.3
- **Parse CSV:** csv 6.0.0

---

## 🌟 Funcionalidades Principais

- **Calculadora de Doses:** Calcule rapidamente as doses de medicamentos com base no peso do animal.
- **Guia de Medicamentos (Bulário):** Um guia de referência rápida para diversos fármacos utilizados na anestesia veterinária.
- **Checklist Pré-Operatório:** Um checklist para garantir que todos os passos pré-operatórios foram seguidos.
- **Ficha Anestésica:** Gere e salve fichas anestésicas em formato PDF.
- **RCP Coach:** Um assistente para manobras de ressuscitação cardiopulmonar.
- **Calculadora de Fluidoterapia:** Calcule taxas de fluidoterapia de manutenção e reidratação.
- **Calculadora de Transfusão:** Calcule o volume de sangue necessário para transfusões.

---

## 🚀 Módulos em Destaque

### 🫀 RCP Coach

Módulo de auxílio para Ressuscitação Cardiopulmonar (RCP) com timer de 2 minutos, metrônomo de compressões e alertas sonoros.

- **Timer de Ciclos (2 minutos):** Contagem regressiva de 120 segundos com reinício automático.
- **Metrônomo de Compressões:** Beep a cada 500ms (120 BPM) para guiar o ritmo das compressões.
- **Sistema de Áudio:** Sons distintos para o metrônomo e para o final de cada ciclo.
- **Controles Interativos:** Botões para iniciar, pausar, reiniciar, mutar o som e manter a tela ativa (wake lock).
- **Contador de Ciclos:** Acompanhe o número de ciclos de 2 minutos completados.
- **Mensagens de Status:** Orientações em tempo real sobre o que fazer.

### 💧 Calculadora de Fluidoterapia

Módulo para cálculo de fluidoterapia para cães e gatos, incluindo volumes de manutenção e reidratação.

- **Cálculo de Manutenção:**
  - **Cães:** 60 mL/kg/dia
  - **Gatos:** 40 mL/kg/dia
- **Cálculo de Reidratação:** Calcula o volume necessário para corrigir a desidratação em 12 ou 24 horas.
- **Taxas de Infusão:** Fornece a taxa em mL/hora, gotas/minuto e o intervalo em segundos entre as gotas.

### 🩸 Calculadora de Transfusão Sanguínea

Módulo para cálculo do volume de sangue necessário para transfusão em cães e gatos, baseado em valores de hematócrito.

- **Fórmula:** `Volume (mL) = (Peso × Fator × (Ht_desejado - Ht_receptor)) / Ht_bolsa`
- **Fatores por Espécie:**
  - **Cães:** 80 ou 90
  - **Gatos:** 40 ou 60
- **Recomendações de Taxa de Infusão:** Fornece taxas seguras para a infusão do sangue.

---

## 🛠️ Tecnologias Utilizadas

### Frontend (Flutter)
- **Framework:** Flutter
- **Linguagem:** Dart
- **Gerenciamento de Estado:** Provider
- **Armazenamento Local:** Hive
- **Geração de PDF:** pdf, printing
- **Gráficos:** fl_chart
- **Áudio:** audioplayers
- **Manter Tela Ativa:** wakelock_plus
- **Preferências:** shared_preferences
- **Paths de Arquivos:** path_provider

### Backend (Dart Frog)
- **Framework:** Dart Frog 2.0
- **Autenticação:** JWT (dart_jsonwebtoken)
- **Segurança:** bcrypt para hash de senhas
- **Parse de Dados:** csv
- **Testes:** test, mocktail

---

## ⚙️ Instalação e Configuração

### Instalação do Frontend (Flutter App)

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/Marcao-Martins/App-dimitri.git
    cd App-dimitri
    ```

2.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

### Instalação do Backend (API)

1.  **Instale o Dart Frog CLI:**
    ```bash
    dart pub global activate dart_frog_cli
    ```

2.  **Entre no diretório do backend:**
    ```bash
    cd backend
    ```

3.  **Instale as dependências:**
    ```bash
    dart pub get
    ```

4.  **Inicie o servidor:**
    ```bash
    dart_frog dev
    ```
    
    O servidor estará disponível em `http://localhost:8080`

#### Testando a API

**Registro de usuário:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"name\":\"Dr. João Silva\",\"email\":\"joao@example.com\",\"password\":\"Senha@123Forte\"}"
```

**Login:**
```bash
curl -X POST http://localhost:8080/api/v1/auth/login ^
  -H "Content-Type: application/json" ^
  -d "{\"email\":\"joao@example.com\",\"password\":\"Senha@123Forte\"}"
```

**Listar fármacos:**
```bash
curl http://localhost:8080/api/v1/farmacos
```

#### Criar Usuário Administrador

Para criar um usuário com permissões administrativas:

```bash
cd backend
dart run tool/create_admin.dart
```

Siga as instruções interativas para criar o admin.

### Integração Flutter + Backend

Para conectar o app Flutter com o backend, veja o guia completo de integração na seção de desenvolvimento do SETUPGUIDE.md.

---

## 🏗️ Estrutura do Projeto

### Frontend (Flutter)
```
lib/
├── main.dart               # Ponto de entrada da aplicação
├── core/                   # Widgets, constantes, temas compartilhados
│   ├── constants/
│   ├── providers/
│   ├── themes/
│   ├── utils/
│   └── widgets/
├── features/               # Módulos de funcionalidades
│   ├── dose_calculator/
│   ├── drug_guide/
│   ├── explorer/
│   ├── ficha_anestesica/
│   ├── fluidotherapy/
│   ├── pre_op_checklist/
│   ├── rcp/
│   ├── transfusion/
│   └── unit_converter/
├── models/                 # Modelos de dados
└── services/               # Serviços (PDF, armazenamento)
```

### Backend (Dart Frog)
```
backend/
├── lib/
│   ├── models/
│   │   ├── farmaco.dart          # Modelo de fármacos
│   │   └── user.dart              # Modelo de usuários + roles
│   ├── services/
│   │   ├── jwt_service.dart       # Geração/validação JWT
│   │   └── password_service.dart  # Hash e validação de senhas
│   └── providers/
│       ├── database_provider.dart # Gerenciamento de fármacos
│       └── user_provider.dart     # Gerenciamento de usuários
├── routes/
│   ├── _middleware.dart           # Middleware global
│   ├── index.dart                 # Rota raiz
│   └── api/v1/
│       ├── _middleware.dart       # Middleware de autenticação
│       ├── farmacos.dart          # Endpoints de fármacos
│       ├── profile.dart           # Perfil do usuário
│       └── auth/
│           ├── register.dart      # Registro
│           └── login.dart         # Login
├── data/
│   ├── farmacos_veterinarios.csv  # Dados dos fármacos
│   └── users.json                 # Dados dos usuários
├── test/                           # Testes unitários
└── tool/
    └── create_admin.dart          # Script para criar admin
```

---

## 📜 Licença

Este projeto é licenciado sob a **Licença MIT**.

```
MIT License

Copyright (c) 2025 GDVet

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## ⚠️ Medical Disclaimer

Este aplicativo é uma ferramenta auxiliar para profissionais de anestesia veterinária e não deve substituir o julgamento clínico profissional, a consulta à literatura atualizada ou os protocolos institucionais.

Os desenvolvedores e contribuidores deste software não se responsabilizam por quaisquer decisões clínicas tomadas com base nas informações fornecidas por este aplicativo.

Sempre verifique as dosagens e protocolos de medicamentos com a literatura veterinária atual e consulte especialistas veterinários qualificados em caso de dúvida.

Este software é fornecido apenas para fins educacionais e auxiliares. Use por sua conta e risco profissional.
