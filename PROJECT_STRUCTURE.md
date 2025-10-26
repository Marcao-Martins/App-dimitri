# 🌳 Estrutura Visual do Projeto

```
App-dimitri-1/
│
├── 📄 Arquivos de Configuração
│   ├── pubspec.yaml                    # Dependências e metadados
│   ├── analysis_options.yaml           # Regras de lint
│   ├── .gitignore                      # Arquivos ignorados pelo Git
│   └── LICENSE                         # Licença MIT + Disclaimer
│
├── 📚 Documentação
│   ├── README.md                       # Documentação principal
│   ├── SETUP_GUIDE.md                  # Guia de instalação detalhado
│   ├── PROJECT_SUMMARY.md              # Sumário técnico completo
│   ├── QUICK_START.md                  # Início rápido
│   ├── CHANGELOG.md                    # Histórico de versões
│   └── PROJECT_STRUCTURE.md            # Este arquivo
│
├── 🗂️ flutter/                         # Flutter SDK local (pré-instalado)
│
└── 📱 lib/                             # Código-fonte do aplicativo
    │
    ├── 📍 main.dart                    # Ponto de entrada do app
    │
    ├── 🎨 core/                        # Recursos compartilhados
    │   │
    │   ├── constants/                  # Constantes globais
    │   │   ├── app_colors.dart         # Paleta de cores
    │   │   ├── app_strings.dart        # Textos e strings
    │   │   └── app_constants.dart      # Valores numéricos
    │   │
    │   ├── themes/                     # Temas do aplicativo
    │   │   └── app_theme.dart          # Tema claro e escuro
    │   │
    │   ├── utils/                      # Utilitários
    │   │   ├── format_utils.dart       # Formatação de dados
    │   │   └── validation_utils.dart   # Validações
    │   │
    │   └── widgets/                    # Widgets reutilizáveis
    │       └── common_widgets.dart     # CustomCard, PrimaryButton, etc.
    │
    ├── ⚙️ features/                    # Funcionalidades principais
    │   │
    │   ├── dose_calculator/            # Calculadora de Doses
    │   │   └── dose_calculator_page.dart
    │   │
    │   ├── pre_op_checklist/           # Checklist Pré-Operatório
    │   │   └── pre_op_checklist_page.dart
    │   │
    │   └── drug_guide/                 # Guia de Fármacos
    │       └── drug_guide_page.dart
    │
    ├── 📊 models/                      # Modelos de dados
    │   ├── medication.dart             # Modelo de medicamento
    │   ├── dose_calculation.dart       # Modelo de cálculo
    │   ├── checklist.dart              # Modelo de checklist
    │   └── animal_patient.dart         # Modelo de paciente
    │
    └── 🔧 services/                    # Lógica de negócio
        ├── medication_service.dart     # Serviço de medicamentos
        └── checklist_service.dart      # Serviço de checklist
```

---

## 📊 Estatísticas do Projeto

### Arquivos Criados
- **Total:** 24 arquivos
- **Código Dart:** 17 arquivos
- **Documentação:** 6 arquivos
- **Configuração:** 3 arquivos

### Linhas de Código (aproximado)
- **Core:** ~1,200 linhas
- **Features:** ~1,500 linhas
- **Models:** ~400 linhas
- **Services:** ~600 linhas
- **Total:** ~3,700 linhas

### Componentes
- **Telas:** 3 páginas principais + 1 página de detalhes
- **Modelos:** 4 classes de dados
- **Serviços:** 2 serviços
- **Widgets Customizados:** 9 widgets reutilizáveis
- **Medicamentos:** 20 pré-cadastrados
- **Itens de Checklist:** 32 itens

---

## 🎯 Pontos de Entrada

### Para Executar o App
```
lib/main.dart → MainNavigationScreen → [3 páginas]
```

### Para Adicionar Medicamentos
```
lib/services/medication_service.dart → _medications list
```

### Para Customizar Checklist
```
lib/services/checklist_service.dart → getDefaultChecklistItems()
```

### Para Alterar Cores
```
lib/core/constants/app_colors.dart
```

### Para Modificar Temas
```
lib/core/themes/app_theme.dart
```

---

## 🔄 Fluxo de Navegação

```
                    MainNavigationScreen
                            |
            +---------------+---------------+
            |               |               |
      Calculator       Checklist        Drug Guide
            |               |               |
    [Cálculo de Doses] [Organização] [Busca e Info]
```

---

## 🧩 Dependências Entre Arquivos

### main.dart
- Importa: themes, pages

### Pages (features/)
- Importam: models, services, widgets, constants, utils

### Services
- Importam: models

### Models
- Independentes (apenas Dart padrão)

### Widgets
- Importam: constants

### Utils
- Independentes

---

## 🎨 Hierarquia de Widgets

```
MaterialApp
└── MainNavigationScreen
    ├── IndexedStack
    │   ├── DoseCalculatorPage
    │   │   └── Form
    │   │       ├── CustomTextField
    │   │       ├── CustomDropdown
    │   │       ├── PrimaryButton
    │   │       └── CustomCard
    │   │
    │   ├── PreOpChecklistPage
    │   │   └── Column
    │   │       ├── ProgressIndicator
    │   │       ├── FilterChips
    │   │       └── ListView
    │   │           └── CheckboxListTile
    │   │
    │   └── DrugGuidePage
    │       └── Column
    │           ├── SearchBar
    │           ├── FilterChips
    │           └── ListView
    │               └── CustomCard
    │
    └── BottomNavigationBar
```

---

## 📦 Módulos e Responsabilidades

| Módulo | Responsabilidade |
|--------|------------------|
| **core/constants** | Valores fixos, strings, cores |
| **core/themes** | Aparência visual do app |
| **core/utils** | Funções auxiliares |
| **core/widgets** | Componentes UI reutilizáveis |
| **features** | Telas e lógica de apresentação |
| **models** | Estruturas de dados |
| **services** | Lógica de negócio e dados |

---

## 🔐 Padrões de Código

### Nomenclatura
- **Classes:** PascalCase (ex: `DoseCalculatorPage`)
- **Arquivos:** snake_case (ex: `dose_calculator_page.dart`)
- **Variáveis:** camelCase (ex: `selectedSpecies`)
- **Constantes:** camelCase com static (ex: `AppColors.primaryBlue`)

### Organização de Imports
1. Dart SDK
2. Flutter SDK
3. Pacotes externos
4. Arquivos locais (relativos)

### Estrutura de Widget
```dart
class MyWidget extends StatefulWidget {
  // Parâmetros
  final String param;
  
  // Construtor
  const MyWidget({Key? key, required this.param}) : super(key: key);
  
  // State
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // Variáveis de estado
  
  // initState
  
  // dispose
  
  // Métodos privados
  
  // build
  
  // Widgets auxiliares
}
```

---

## 🚀 Como Navegar no Código

### Para Entender o Projeto
1. Comece por `lib/main.dart`
2. Veja as 3 páginas em `lib/features/`
3. Explore os modelos em `lib/models/`
4. Revise os serviços em `lib/services/`

### Para Customizar
1. Cores: `lib/core/constants/app_colors.dart`
2. Textos: `lib/core/constants/app_strings.dart`
3. Dados: `lib/services/*.dart`

### Para Expandir
1. Novo modelo: Adicionar em `lib/models/`
2. Novo serviço: Adicionar em `lib/services/`
3. Nova tela: Adicionar em `lib/features/[nome]/`
4. Novo widget: Adicionar em `lib/core/widgets/`

---

## ✅ Arquivos Críticos

| Arquivo | Importância | Descrição |
|---------|-------------|-----------|
| `main.dart` | ⭐⭐⭐⭐⭐ | Entrada do app |
| `medication_service.dart` | ⭐⭐⭐⭐⭐ | Banco de dados de medicamentos |
| `checklist_service.dart` | ⭐⭐⭐⭐ | Template do checklist |
| `app_theme.dart` | ⭐⭐⭐⭐ | Visual do app |
| `common_widgets.dart` | ⭐⭐⭐⭐ | Componentes reutilizáveis |
| `dose_calculator_page.dart` | ⭐⭐⭐⭐ | Calculadora principal |

---

## 📈 Pontos de Expansão

### Fácil
- [ ] Adicionar novos medicamentos
- [ ] Adicionar itens ao checklist
- [ ] Mudar cores e temas
- [ ] Traduzir strings

### Médio
- [ ] Implementar persistência (Hive)
- [ ] Adicionar histórico de cálculos
- [ ] Exportar PDF
- [ ] Calculadora de fluidos

### Avançado
- [ ] Backend e sincronização
- [ ] Autenticação de usuários
- [ ] Analytics e crashlytics
- [ ] Versão iOS

---

**Última atualização:** 26 de Outubro de 2025  
**Desenvolvido com** ❤️ **e** 🧠
