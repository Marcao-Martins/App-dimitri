# 🎨 Design System - VetAnesthesia Helper

## 📋 Visão Geral

Este documento descreve o Design System moderno e minimalista implementado no aplicativo VetAnesthesia Helper, seguindo princípios de design limpo, funcional e altamente profissional para anestesiologistas veterinários.

---

## 🎨 Paleta de Cores

### Cor Principal de Acento
**Verde-azulado (Teal)** - Profissional e moderno
- **Primary Teal**: `#00ACC1` - Cor de destaque principal
- **Teal Dark**: `#00838F` - Variação escura
- **Teal Light**: `#4DD0E1` - Variação clara

### Cores Categoriais
Para ícones de biblioteca e categorias de funcionalidades:
- **Laranja**: `#FF9800` - Calculadoras
- **Azul**: `#2196F3` - Protocolos
- **Roxo**: `#9C27B0` - Estudos
- **Verde**: `#4CAF50` - Checklists
- **Rosa**: `#E91E63` - Prontuários
- **Índigo**: `#3F51B5` - Comunidade

### Cores de Status
- **Success**: `#4CAF50` (Verde)
- **Warning**: `#FF9800` (Laranja)
- **Error**: `#F44336` (Vermelho)
- **Info**: `#00ACC1` (Teal)

### Cores de Fundo
- **Background Primary**: `#FFFFFF` (Branco puro)
- **Background Secondary**: `#FAFAFA` (Branco levemente off)
- **Surface White**: `#FFFFFF` (Cards e componentes)
- **Surface Grey**: `#F5F5F5` (Cinza muito claro)

### Cores de Texto
Hierarquia clara de informação:
- **Text Primary**: `#212121` (Cinza escuro/preto)
- **Text Secondary**: `#757575` (Cinza médio)
- **Text Tertiary**: `#9E9E9E` (Cinza claro)
- **Text On Primary**: `#FFFFFF` (Branco sobre teal)

### Cores de Navegação
- **Nav Active**: `#00ACC1` (Teal - aba ativa)
- **Nav Inactive**: `#9E9E9E` (Cinza - aba inativa)
- **Nav Background**: `#FFFFFF` (Branco)

### Cores de Filtros/Chips
- **Chip Active**: `#212121` (Cinza escuro/preto)
- **Chip Inactive**: `#E0E0E0` (Cinza claro)
- **Chip Active Text**: `#FFFFFF` (Branco)
- **Chip Inactive Text**: `#757575` (Cinza médio)

### Cores de Tags/Etiquetas
- **VET**: `#00ACC1` (Teal) - Uso veterinário
- **HUM**: `#2196F3` (Azul) - Uso humano
- **PA**: `#9C27B0` (Roxo) - Princípio Ativo
- **CTRL**: `#FF9800` (Laranja) - Controlado

---

## ✍️ Tipografia

### Fonte
**Roboto** - Sans-Serif moderna e limpa, excelente legibilidade

### Hierarquia de Texto

#### Títulos
- **Headline Large**: 28px, Weight 700 (Bold), -0.5 letter-spacing
- **Headline Medium**: 22px, Weight 600 (Semi-bold), -0.3 letter-spacing
- **Headline Small**: 18px, Weight 600 (Semi-bold)

#### Corpo
- **Body Large**: 16px, Weight 400 (Regular)
- **Body Medium**: 14px, Weight 400 (Regular)
- **Body Small**: 12px, Weight 400 (Regular)

#### Títulos de Componentes
- **Title Large**: 20px, Weight 600 (Semi-bold)
- **Title Medium**: 16px, Weight 600 (Semi-bold)
- **Title Small**: 14px, Weight 500 (Medium)

---

## 🧩 Componentes

### 1. Barra de Busca (ModernSearchBar)
**Características:**
- Totalmente arredondada (30px border-radius)
- Fundo cinza claro (#F5F5F5)
- Ícone de busca à esquerda
- Botão de limpar à direita (quando há texto)
- Sombra sutil

**Uso:**
```dart
ModernSearchBar(
  controller: _searchController,
  hintText: 'Buscar...',
  onChanged: (value) { },
  onClear: () { },
)
```

### 2. Ícones de Biblioteca (LibraryIconButton)
**Características:**
- Círculo colorido de 64x64px
- Ícone branco de 28px
- Label abaixo (12px, Weight 500)
- Sombra colorida baseada na cor do ícone
- Largura total: 80px

**Uso:**
```dart
LibraryIconButton(
  icon: Icons.calculate_outlined,
  label: 'Calculadoras',
  color: AppColors.categoryOrange,
  onTap: () { },
)
```

### 3. Cards de Categoria (CategoryCard)
**Características:**
- Border-radius: 20px
- Padding: 20px
- Sombra sutil
- Ícone em container arredondado (56x56px)
- Título centralizado (16px, Weight 600)
- Subtítulo opcional (12px, Weight 400)

**Uso:**
```dart
CategoryCard(
  icon: Icons.medication_outlined,
  title: 'Medicamentos',
  subtitle: '20 fármacos',
  iconColor: AppColors.primaryTeal,
  onTap: () { },
)
```

### 4. Chips de Filtro (ModernFilterChip)
**Características:**
- Formato de pílula (20px border-radius)
- Estado ativo: fundo escuro (#212121), texto branco
- Estado inativo: fundo claro (#E0E0E0), texto cinza
- Padding: 20px horizontal, 10px vertical
- Sombra quando ativo

**Uso:**
```dart
ModernFilterChip(
  label: 'Todos',
  isSelected: true,
  onTap: () { },
)
```

### 5. Item de Lista de Medicamento (MedicationListItem)
**Características:**
- Ícone circular (48x48px) à esquerda
- Título (16px, Weight 600)
- Subtítulo (14px, Weight 400)
- Tag à direita com borda
- Divider na parte inferior
- Padding: 20px horizontal, 16px vertical

**Uso:**
```dart
MedicationListItem(
  icon: Icons.medication,
  iconColor: AppColors.primaryTeal,
  title: 'Propofol',
  subtitle: 'Anestésico intravenoso',
  tag: 'VET',
  tagColor: AppColors.tagVet,
  onTap: () { },
)
```

### 6. Cabeçalho de Seção (SectionHeader)
**Características:**
- Título (22px, Weight 700)
- Ação opcional à direita (14px, Weight 600, cor teal)
- Padding: 20px horizontal, 12px vertical

**Uso:**
```dart
SectionHeader(
  title: 'Bibliotecas',
  actionText: 'Ver todas',
  onActionTap: () { },
)
```

---

## 📐 Espaçamentos

### Padding Padrão
- **Pequeno**: 8px
- **Padrão**: 16px
- **Médio**: 20px
- **Grande**: 24px
- **Extra Grande**: 32px

### Border Radius
- **Pequeno**: 12px (tags)
- **Médio**: 16px (botões)
- **Grande**: 20px (cards, chips)
- **Extra Grande**: 30px (barra de busca)
- **Circular**: 50% (ícones)

### Elevações/Sombras
- **Nível 1**: 2px blur, offset (0, 2)
- **Nível 2**: 4px blur, offset (0, 2)
- **Nível 3**: 8px blur, offset (0, 4)

---

## 🧭 Navegação

### Bottom Navigation Bar
**Características:**
- 5 abas fixas
- Ícones outline (vazados) quando inativos
- Ícones preenchidos quando ativos
- Cor ativa: Teal (#00ACC1)
- Cor inativa: Cinza (#9E9E9E)
- Labels sempre visíveis (12px)
- Fundo branco com elevação 8

**Abas:**
1. **Explorar** - `explore_outlined` / `explore`
2. **Calculadoras** - `calculate_outlined` / `calculate`
3. **Checklist** - `checklist_outlined` / `checklist`
4. **Bulário** - `menu_book_outlined` / `menu_book`
5. **Comunidade** - `groups_outlined` / `groups`

---

## 📱 Layout das Telas

### Tela Home (Explorar)
1. **Header**
   - Título: "VetAnesthesia" (28px, Bold)
   - Subtítulo descritivo (14px)
   - Padding: 20px

2. **Barra de Busca**
   - Totalmente arredondada
   - Margin: 20px horizontal, 8px vertical

3. **Seção Bibliotecas**
   - SectionHeader com ação "Ver todas"
   - Lista horizontal de LibraryIconButton
   - 6 categorias visíveis

4. **Seção Bulário**
   - SectionHeader com ação "Ver todos"
   - Grid 2 colunas de CategoryCard
   - 4 cards principais

5. **Seção Recentes**
   - SectionHeader com ação "Limpar"
   - Lista vertical de MedicationListItem
   - Container com border-radius 20px

### Tela de Busca (Bulário)
1. **AppBar**
   - Título: "Bulário"
   - Ação: Limpar filtros (quando aplicados)

2. **Barra de Busca**
   - Padding: 20px horizontal, 16px vertical superior

3. **Filtros Horizontais**
   - Lista de ModernFilterChip
   - Scroll horizontal
   - Height: 50px

4. **Lista de Resultados**
   - MedicationListItem para cada resultado
   - Estado vazio com ícone e mensagem

---

## 🎯 Princípios de Design

### 1. Minimalismo
- Muito espaço em branco
- Componentes limpos sem excesso de bordas
- Foco no conteúdo

### 2. Hierarquia Visual Clara
- Tamanhos de texto bem definidos
- Peso de fonte apropriado para cada nível
- Cores com propósito específico

### 3. Alto Contraste
- Fundo branco predominante
- Texto escuro para máxima legibilidade
- Cores vibrantes apenas para acentos

### 4. Consistência
- Mesmo border-radius em componentes similares
- Padding uniforme
- Espaçamento previsível

### 5. Acessibilidade
- Contraste adequado (WCAG AA)
- Tamanhos de toque mínimos (48x48px)
- Labels descritivos
- Tooltips em ações

### 6. Profissionalismo
- Paleta de cores sóbria e confiável
- Tipografia legível
- Layout organizado
- Iconografia clara

---

## 🔄 Estados Interativos

### Botões e Cards
- **Normal**: Estado padrão
- **Hover**: Leve mudança de opacidade (web)
- **Pressed**: Feedback visual imediato
- **Disabled**: Opacidade reduzida (60%)

### Inputs
- **Normal**: Border transparent ou cinza claro
- **Focused**: Border teal de 2px
- **Error**: Border vermelho de 2px
- **Disabled**: Fundo cinza mais escuro

### Navigation Items
- **Ativo**: Cor teal, ícone preenchido
- **Inativo**: Cor cinza, ícone outline
- **Transição**: Animação suave

---

## 📦 Arquivos do Design System

### Cores
`lib/core/constants/app_colors.dart`

### Tema
`lib/core/themes/app_theme.dart`

### Componentes Modernos
`lib/core/widgets/modern_widgets.dart`

### Tela Exemplo
`lib/features/explorer/explorer_page.dart`

---

## ✅ Checklist de Implementação

- [x] Paleta de cores definida
- [x] Tema claro e escuro atualizados
- [x] Componentes modernos criados
- [x] Tela Home (Explorar) implementada
- [x] Bottom Navigation com 5 abas
- [x] Tela de Busca (Bulário) modernizada
- [ ] Calculadora de doses modernizada
- [ ] Checklist pré-operatório modernizado
- [ ] Tela de detalhes de medicamento modernizada
- [ ] Animações de transição
- [ ] Testes de acessibilidade

---

## 🚀 Próximos Passos

1. **Modernizar páginas restantes** (Calculadora, Checklist)
2. **Implementar animações** suaves entre transições
3. **Adicionar micro-interações** para feedback do usuário
4. **Criar telas de Protocolos, Estudos, Prontuários e Comunidade**
5. **Implementar busca global** funcional
6. **Adicionar dark mode** completo e refinado
7. **Otimizar performance** e carregamento
8. **Testes de usabilidade** com veterinários

---

**Design System v1.0**  
*Desenvolvido para VetAnesthesia Helper*  
*Última atualização: Outubro 2025*
