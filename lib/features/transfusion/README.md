# Calculadora de Transfusão Sanguínea

## 📋 Descrição

Módulo de cálculo do volume necessário de sangue para transfusão em cães e gatos, baseado em valores de hematócrito.

## 🎯 Funcionalidades

### 1. Cálculo de Volume de Transfusão
Determina o volume exato de sangue necessário baseado em:
- Peso do paciente
- Hematócrito atual (receptor)
- Hematócrito desejado (alvo)
- Hematócrito da bolsa (doador)
- Fator de cálculo específico da espécie

### 2. Fatores por Espécie
- **Cães**: 80 ou 90 (padrão: 90)
- **Gatos**: 40 ou 60 (padrão: 60)

### 3. Recomendações de Taxa de Infusão
- **Cães**: 10-20 mL/kg/h (primeira hora), máx 22 mL/kg/h
- **Gatos**: 5-10 mL/kg/h (primeira hora), máx 11 mL/kg/h

## 📊 Fórmula

```
Volume (mL) = (Peso × Fator × (Ht_desejado - Ht_receptor)) / Ht_bolsa
```

### Parâmetros
- **Peso**: Peso corporal em kg
- **Fator**: Constante específica da espécie (40, 60, 80 ou 90)
- **Ht_desejado**: Hematócrito alvo após transfusão (1-60%)
- **Ht_receptor**: Hematócrito atual do paciente (1-40%)
- **Ht_bolsa**: Hematócrito do sangue doador (1-80%)

### Validações
- Ht_desejado > Ht_receptor (requisito lógico)
- Ht_bolsa > 0 (não pode dividir por zero)
- Peso > 0 e <= 200 kg

## 🏗️ Arquitetura

```
lib/features/transfusion/
├── transfusion_page.dart                # Página principal
├── models/
│   └── transfusion_calculation.dart     # Modelo e lógica de cálculo
└── widgets/
    ├── hematocrit_selector.dart         # Dropdown customizado para Ht
    └── results_display.dart             # Exibição visual de resultados
```

## 🎨 Interface

### Formulário
1. **Espécie** (Dropdown)
   - Cão
   - Gato
   - Atualiza fatores disponíveis automaticamente

2. **Peso** (TextField)
   - Validação: 0 < peso <= 200 kg

3. **Fator de Cálculo** (Dropdown dinâmico)
   - Opções mudam baseadas na espécie
   - Valor padrão selecionado automaticamente

4. **Hematócrito Desejado** (Dropdown 1-60%)
   - Ht alvo após transfusão

5. **Hematócrito do Receptor** (Dropdown 1-40%)
   - Ht atual do paciente

6. **Hematócrito da Bolsa** (Dropdown 1-80%)
   - Ht do sangue doador

### Resultados
Card com:
- **Volume necessário** (destaque principal em mL)
- Resumo dos parâmetros usados
- Recomendações de taxa de infusão
- Avisos de segurança

## 🔢 Exemplos de Cálculo

### Exemplo 1: Cão de 25kg
```
Entrada:
- Espécie: Cão
- Peso: 25 kg
- Fator: 90
- Ht desejado: 35%
- Ht receptor: 20%
- Ht bolsa: 60%

Cálculo:
Volume = (25 × 90 × (35 - 20)) / 60
Volume = (25 × 90 × 15) / 60
Volume = 33750 / 60
Volume = 562.5 mL

Resultado: 562.5 mL
Taxa recomendada: 10-20 mL/kg/h (primeira hora)
```

### Exemplo 2: Gato de 4kg
```
Entrada:
- Espécie: Gato
- Peso: 4 kg
- Fator: 60
- Ht desejado: 30%
- Ht receptor: 12%
- Ht bolsa: 50%

Cálculo:
Volume = (4 × 60 × (30 - 12)) / 50
Volume = (4 × 60 × 18) / 50
Volume = 4320 / 50
Volume = 86.4 mL

Resultado: 86.4 mL
Taxa recomendada: 5-10 mL/kg/h (primeira hora)
```

### Exemplo 3: Cão de 10kg (fator alternativo)
```
Entrada:
- Espécie: Cão
- Peso: 10 kg
- Fator: 80
- Ht desejado: 40%
- Ht receptor: 15%
- Ht bolsa: 70%

Cálculo:
Volume = (10 × 80 × (40 - 15)) / 70
Volume = (10 × 80 × 25) / 70
Volume = 20000 / 70
Volume = 285.7 mL

Resultado: 285.7 mL
```

## 🎯 Casos de Uso

### Anemia Grave
- Ht receptor muito baixo (<12-15%)
- Necessidade de elevação rápida do Ht
- Monitoramento intensivo durante infusão

### Perda Sanguínea Aguda
- Cirurgias com hemorragia
- Trauma
- Coagulopatias

### Anemia Crônica
- Doenças renais
- Neoplasias
- Doenças imunomediadas

## 🎨 Design

### Cores
- **Header**: Gradiente vermelho (AppColors.error)
- **Ícones**: Vermelho para tema de sangue
- **Botão Calcular**: Laranja (#FF4600)
- **Avisos**: Vermelho claro para alertas

### Ícones
- 🩸 `bloodtype` - Tema principal
- 🐾 `pets` - Espécie
- ⚖️ `monitor_weight` - Peso
- 🧮 `calculate` - Fator
- 📈 `trending_up` - Ht desejado
- 👤 `person` - Ht receptor
- ⚡ `speed` - Taxa de infusão

## 📱 Responsividade

- Layout com `SingleChildScrollView`
- Cards com bordas arredondadas (16px)
- Dropdowns com menuMaxHeight para scroll
- Espaçamento consistente (16-24px)

## 🔄 Lógica Dinâmica

### Atualização de Fatores
```dart
void _onSpeciesChanged(String? species) {
  setState(() {
    _selectedSpecies = species;
    if (species != null) {
      _availableFactors = TransfusionCalculation.getFactorsForSpecies(species);
      _selectedFactor = TransfusionCalculation.getDefaultFactor(species);
    }
  });
}
```

### Validação Customizada
- Peso: 0 < peso <= 200
- Ht_desejado > Ht_receptor
- Ht_bolsa != 0
- Todos os campos obrigatórios

## ⚠️ Considerações Clínicas

### Pré-Transfusão
1. **Tipagem sanguínea obrigatória**
2. **Prova cruzada** (especialmente em gatos e cães previamente transfundidos)
3. **Avaliar condição cardiovascular**
4. **Preparar medicações de emergência**

### Durante Transfusão
1. **Monitorar sinais vitais** (FC, FR, temperatura)
2. **Observar reações adversas**:
   - Febre
   - Tremores
   - Vômitos
   - Dispneia
   - Urticária
3. **Taxa de infusão adequada**
4. **Registrar volumes e tempos**

### Pós-Transfusão
1. **Avaliar Ht pós-transfusional** (1-2h após)
2. **Monitorar função renal**
3. **Observar sinais de sobrecarga volêmica**

### Reações Adversas
- **Imediatas**: hemólise aguda, anafilaxia, sobrecarga circulatória
- **Tardias**: hemólise tardia, aloimunização, doenças transmissíveis

## 🔗 Integração

A calculadora está integrada à página Início (Explorer):

```dart
LibraryIconButton(
  icon: Icons.bloodtype_outlined,
  label: 'Transfusão',
  color: AppColors.error,
  onTap: () => _navigateTo(const TransfusionPage()),
),
```

## 📚 Widgets Customizados

### HematocritSelector
Widget reutilizável para seleção de hematócrito com:
- Range customizável (min-max)
- Validação integrada
- Helper text
- Ícone customizável

```dart
HematocritSelector(
  label: 'Hematócrito desejado',
  value: _desiredHematocrit,
  minValue: 1,
  maxValue: 60,
  icon: Icons.trending_up,
  helperText: 'Ht alvo após transfusão',
  onChanged: (value) => setState(() => _desiredHematocrit = value),
  validator: (value) => value == null ? 'Informe o Ht' : null,
)
```

## ✅ Status

**Implementação completa** ✓
- ✅ Modelo de dados com fórmula precisa
- ✅ Widget customizado de hematócrito
- ✅ Interface responsiva e intuitiva
- ✅ Validações robustas
- ✅ Lógica dinâmica de fatores
- ✅ Recomendações clínicas
- ✅ Integração com app
- ✅ Documentação completa

## 🚨 Avisos Importantes

1. **Este cálculo é uma estimativa**
2. **Realizar sempre tipagem e prova cruzada**
3. **Monitorar rigorosamente durante transfusão**
4. **Ajustar volume conforme resposta clínica**
5. **Considerar estado cardiovascular do paciente**

## 📖 Referências

- Fórmula baseada em protocolos veterinários padronizados
- Fatores específicos por espécie validados em literatura
- Taxas de infusão conforme diretrizes de emergência veterinária
- Ranges de hematócrito baseados em valores fisiológicos
