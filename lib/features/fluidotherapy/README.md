# Calculadora de Fluidoterapia

## 📋 Descrição

Módulo de cálculo de fluidoterapia para cães e gatos, incluindo volumes de manutenção e reidratação.

## 🎯 Funcionalidades

### 1. Cálculo de Manutenção
- **Cães**: 60 mL/kg/dia
- **Gatos**: 40 mL/kg/dia

### 2. Cálculo de Reidratação
- Volume de reidratação = Peso (kg) × % desidratação × 1000 mL
- Distribuído ao longo de 12h ou 24h
- Somado ao volume de manutenção

### 3. Taxas de Infusão
- **mL/hora**: Taxa horária para bomba de infusão
- **Gotas/minuto**: Para gotejamento gravitacional (macrogotas = 20 gotas/mL)
- **Segundos entre gotas**: Auxílio visual para contagem

## 📊 Fórmulas

### Manutenção
```
Volume_manutenção = Peso × Taxa_espécie
```

### Reidratação
```
Volume_reidratação = Peso × (% desidratação / 100) × 1000
Volume_total_dia = Volume_manutenção + (Volume_reidratação / (Tempo_h / 24))
```

### Infusão
```
Taxa_mL/h = Volume_total_dia / 24
Gotas/min = (Taxa_mL/h × 20) / 60
Segundos_entre_gotas = 60 / Gotas_por_minuto
```

## 🏗️ Arquitetura

```
lib/features/fluidotherapy/
├── fluidotherapy_page.dart          # Página principal
├── models/
│   └── fluid_calculation.dart       # Modelo de dados e cálculos
└── widgets/
    ├── dehydration_section.dart     # Seção condicional de desidratação
    └── results_display.dart         # Exibição de resultados
```

## 🎨 Interface

### Formulário
- **Espécie**: Dropdown (Cão/Gato)
- **Peso**: Campo numérico (kg)
- **Desidratação**: Dropdown (Sim/Não)
- **Campos condicionais** (se desidratado):
  - Tempo de reidratação (12h/24h)
  - Percentual de desidratação (0-20%)

### Resultados
Card com 4 informações principais:
1. Taxa de infusão (mL/h)
2. Gotas por minuto
3. Intervalo entre gotas (segundos)
4. Volume diário total

### Informações Adicionais (se desidratado)
- Percentual de desidratação
- Volume de reidratação
- Tempo de reidratação
- Volume de manutenção

## 🔢 Validações

### Peso
- Obrigatório
- Deve ser maior que 0
- Máximo de 200 kg

### Desidratação (se aplicável)
- Tempo de reidratação obrigatório
- Percentual obrigatório
- Percentual deve estar entre 0% e 20%

## 🎯 Casos de Uso

### Exemplo 1: Cão de 20kg sem desidratação
```
Entrada:
- Espécie: Cão
- Peso: 20 kg
- Desidratação: Não

Resultado:
- Volume diário: 1200 mL/dia (60 mL/kg × 20 kg)
- Taxa: 50 mL/h
- Gotas: 17 gotas/min
- Intervalo: 3.5 segundos
```

### Exemplo 2: Gato de 4kg com 8% de desidratação (24h)
```
Entrada:
- Espécie: Gato
- Peso: 4 kg
- Desidratação: Sim
- Tempo: 24 horas
- Percentual: 8%

Cálculo:
- Manutenção: 4 × 40 = 160 mL/dia
- Reidratação: 4 × 0.08 × 1000 = 320 mL (em 24h)
- Total: 160 + 320 = 480 mL/dia

Resultado:
- Taxa: 20 mL/h
- Gotas: 7 gotas/min
- Intervalo: 8.6 segundos
```

### Exemplo 3: Cão de 30kg com 5% de desidratação (12h)
```
Entrada:
- Espécie: Cão
- Peso: 30 kg
- Desidratação: Sim
- Tempo: 12 horas
- Percentual: 5%

Cálculo:
- Manutenção: 30 × 60 = 1800 mL/dia
- Reidratação: 30 × 0.05 × 1000 = 1500 mL (em 12h = 3000 mL/dia equivalente)
- Total: 1800 + 3000 = 4800 mL/dia

Resultado:
- Taxa: 200 mL/h
- Gotas: 67 gotas/min
- Intervalo: 0.9 segundos
```

## 🎨 Design

### Cores
- **Header**: Gradiente teal-blue
- **Taxa de infusão**: Laranja (#FF4600)
- **Gotas/minuto**: Azul
- **Intervalo**: Roxo
- **Volume total**: Verde
- **Aviso de desidratação**: Amarelo/warning

### Ícones
- 💧 `water_drop` - Tema principal
- 🏥 `local_hospital` - Taxa de infusão
- 💧 `opacity` - Gotas
- ⏱️ `timer` - Intervalo
- 💦 `water` - Volume
- ⚠️ `warning_amber` - Desidratação
- 🐾 `pets` - Espécie
- ⚖️ `monitor_weight` - Peso

## 🔗 Integração

A calculadora está integrada à página Início (Explorer) como um LibraryIconButton:

```dart
LibraryIconButton(
  icon: Icons.water_drop_outlined,
  label: 'Fluidoterapia',
  color: AppColors.categoryBlue,
  onTap: () => _navigateTo(const FluidotherapyPage()),
),
```

## ⚠️ Observações Clínicas

1. **Estes cálculos são estimativas iniciais**
2. **Ajustar conforme**:
   - Condição clínica do paciente
   - Perdas contínuas (vômitos, diarreia)
   - Monitoramento de parâmetros vitais
   - Débito urinário
   - Estado de hidratação

3. **Considerações especiais**:
   - Pacientes cardiopatas: reduzir taxa
   - Pacientes renais: ajustar conforme função renal
   - Filhotes: necessidades podem ser maiores
   - Choque hipovolêmico: bolus inicial antes da manutenção

## 📱 Responsividade

- Layout adaptável para diferentes tamanhos de tela
- `SingleChildScrollView` para rolagem suave
- Cards com bordas arredondadas
- Espaçamento consistente

## 🔄 Estado

- Gerenciado com `StatefulWidget`
- Controllers para campos de texto
- Validação em tempo real
- Limpeza de formulário com botão "Limpar"

## ✅ Status

**Implementação completa** ✓
- ✅ Modelo de dados
- ✅ Cálculos precisos
- ✅ Interface responsiva
- ✅ Validações
- ✅ Integração com app
- ✅ Documentação

## 📚 Referências

- Taxa de manutenção baseada em literatura veterinária padrão
- Cálculo de reidratação segundo protocolos de emergência veterinária
- Conversão de macrogotas (20 gotas/mL) padrão internacional
