# Calculadora de Escore Apgar Veterinário

## 📋 Descrição

Módulo completo para avaliação da vitalidade de neonatos (cães e gatos) através do **Escore Apgar Veterinário**, adaptado do sistema neonatal humano para medicina veterinária. Avalia 5 parâmetros clínicos nos primeiros 5 minutos de vida.

## 🎯 Funcionalidades

### 1. Avaliação de 5 Parâmetros Clínicos
Cada parâmetro recebe pontuação de **0 a 2**, totalizando **0 a 10 pontos**:

1. **Cor das Mucosas**
   - 0: Cianótica (azulada) - Hipoxemia grave
   - 1: Pálida - Anemia/Hipoperfusão
   - 2: Rósea - Normal

2. **Frequência Cardíaca** *(dinâmica por espécie)*
   - **Gatos:**
     - 0: <100 bpm (Bradicardia severa)
     - 1: <180 bpm (Bradicardia)
     - 2: 200-280 bpm (Normal)
   - **Cães:**
     - 0: <180 bpm (Bradicardia severa)
     - 1: 180-220 bpm (Normal baixo)
     - 2: >220 bpm (Normal)

3. **Reflexo de Irritabilidade**
   - 0: Ausente - Sem resposta
   - 1: Fraco - Resposta mínima
   - 2: Forte - Resposta vigorosa

4. **Motilidade (Tônus Muscular)**
   - 0: Ausente (flácido) - Hipotonia
   - 1: Fraco (flexão) - Tônus reduzido
   - 2: Forte (movimentos ativos) - Normal

5. **Esforços Respiratórios** *(dinâmico por espécie)*
   - **Gatos:**
     - 0: Ausente ou <10 mpm (Apneia)
     - 1: Fraco ou <40 mpm (Bradipneia)
     - 2: Regular 40-160 mpm (Normal)
   - **Cães:**
     - 0: Ausente ou <6 mpm (Apneia)
     - 1: Fraco 6-15 mpm (Bradipneia)
     - 2: Forte >15 mpm (Normal)

### 2. Lógica Dinâmica por Espécie
- **Seleção de espécie** (Cão/Gato) altera automaticamente:
  - Ranges de frequência cardíaca
  - Ranges de esforço respiratório
  - Labels e descrições específicas
- **Reset automático** dos campos dependentes ao mudar espécie

### 3. Interpretação Automática do Escore
- **8-10 pontos**: 🟢 Excelente - Neonato vigoroso
- **6-7 pontos**: 🟠 Bom - Atenção moderada necessária
- **4-5 pontos**: 🟠 Regular - Reanimação necessária
- **0-3 pontos**: 🔴 Crítico - Reanimação urgente

### 4. Recomendações Clínicas Automáticas
Baseadas no escore, o sistema fornece condutas recomendadas:

#### Score 8-10 (Verde)
- ✓ Secar e estimular suavemente
- ✓ Monitorar temperatura
- ✓ Permitir amamentação

#### Score 6-7 (Laranja)
- ! Oxigenoterapia por máscara
- ! Estimulação tátil vigorosa
- ! Monitoramento frequente
- ! Manter aquecido

#### Score 4-5 (Laranja escuro)
- !! Oxigenoterapia imediata
- !! Aspirar vias aéreas
- !! Estimulação vigorosa
- !! Considerar doxapram
- !! Monitoramento contínuo

#### Score 0-3 (Vermelho)
- ⚠️ REANIMAÇÃO URGENTE
- ⚠️ Intubação e ventilação
- ⚠️ Massagem cardíaca se FC < 60 bpm
- ⚠️ Adrenalina 0.01-0.02 mg/kg IV
- ⚠️ Acesso vascular umbilical
- ⚠️ Suporte térmico intensivo

## 🏗️ Arquitetura

```
lib/features/apgar/
├── apgar_page.dart                      # Página principal com formulário
├── models/
│   ├── apgar_parameters.dart            # Parâmetros comuns e interpretação
│   └── species_config.dart              # Configurações específicas por espécie
└── widgets/
    ├── parameter_selector.dart          # Dropdown customizado para parâmetros
    ├── species_selector.dart            # Seletor de espécie
    └── score_display.dart               # Exibição visual do resultado
```

## 📊 Fórmula do Escore

```
Escore Total = Mucosas + FC + Irritabilidade + Motilidade + Respiração

Onde cada parâmetro vale 0, 1 ou 2 pontos
Resultado: 0 a 10 pontos
```

## 🎨 Interface

### Design Responsivo
- **Cards destacados** para cada parâmetro
- **Badges coloridos** com pontuação (0/1/2)
- **Dropdown com descrições** detalhadas
- **Resultado visual** com cores por gravidade
- **Scroll automático** para resultado após cálculo

### Cores por Pontuação
- **2 pontos**: 🟢 Verde (Normal)
- **1 ponto**: 🟠 Laranja (Atenção)
- **0 pontos**: 🔴 Vermelho (Crítico)

### Validações
- ✓ Espécie obrigatória
- ✓ Todos os 5 parâmetros obrigatórios
- ✓ Mensagens de erro claras
- ✓ Reset seguro do formulário

## 🎯 Casos de Uso

### Exemplo 1: Cão - Score 9 (Excelente)
```
Entrada:
- Espécie: Cão
- Mucosas: Rósea (2)
- FC: >220 bpm (2)
- Irritabilidade: Forte (2)
- Motilidade: Forte (2)
- Respiração: Forte >15 mpm (1)

Resultado: 9 / 10 🟢
Interpretação: Excelente - Neonato vigoroso
Conduta: Secar, estimular, monitorar temperatura
```

### Exemplo 2: Gato - Score 5 (Regular)
```
Entrada:
- Espécie: Gato
- Mucosas: Pálida (1)
- FC: <180 bpm (1)
- Irritabilidade: Fraco (1)
- Motilidade: Fraco (1)
- Respiração: Fraco <40 mpm (1)

Resultado: 5 / 10 🟠
Interpretação: Regular - Reanimação necessária
Conduta: Oxigenoterapia, aspirar vias aéreas, estimular
```

### Exemplo 3: Cão - Score 2 (Crítico)
```
Entrada:
- Espécie: Cão
- Mucosas: Cianótica (0)
- FC: <180 bpm (0)
- Irritabilidade: Ausente (0)
- Motilidade: Flácido (0)
- Respiração: Ausente (2)

Resultado: 2 / 10 🔴
Interpretação: Crítico - Reanimação urgente
Conduta: Intubação, ventilação, massagem cardíaca, adrenalina
```

## 🔧 Componentes Técnicos

### SpeciesConfig
Gerencia configurações específicas por espécie:
```dart
static const cat = SpeciesConfig(
  species: 'Gato',
  heartRateLabel: 'Frequência Cardíaca (FC)',
  heartRateOptions: [...],  // Ranges específicos
  respiratoryLabel: 'Esforços Respiratórios',
  respiratoryOptions: [...], // Ranges específicos
);
```

### ApgarParameters
Define parâmetros comuns e interpretação:
```dart
static String interpretScore(int score) {
  if (score >= 8) return 'Excelente - Neonato vigoroso';
  if (score >= 6) return 'Bom - Atenção moderada';
  if (score >= 4) return 'Regular - Reanimação necessária';
  return 'Crítico - Reanimação urgente';
}
```

### ParameterSelector Widget
Dropdown customizado com:
- Header com label destacado
- Badge colorido com pontuação
- Label e descrição para cada opção
- Validação integrada

### ScoreDisplay Widget
Resultado visual com:
- Score gigante com fração (X / 10)
- Interpretação textual
- Lista de condutas recomendadas
- Cores dinâmicas por gravidade

## 🔗 Integração

A calculadora está integrada à página Início (Explorer):

```dart
LibraryIconButton(
  icon: Icons.baby_changing_station,
  label: 'Escore Apgar',
  color: AppColors.categoryPink,
  onTap: () => _navigateTo(const ApgarPage()),
),
```

## 📱 Responsividade

- ✓ `SingleChildScrollView` para formulários longos
- ✓ Cards adaptáveis ao tamanho da tela
- ✓ Scroll automático para resultado
- ✓ Margins e paddings consistentes
- ✓ Text wrapping automático

## ⚠️ Observações Clínicas

### Momento da Avaliação
- **Primeiro Apgar**: 1 minuto após nascimento
- **Segundo Apgar**: 5 minutos após nascimento
- **Terceiro Apgar** (se necessário): 10 minutos

### Fatores que Afetam o Score
- **Tipo de parto** (cesárea vs natural)
- **Anestesia materna**
- **Tempo de trabalho de parto**
- **Hipóxia intrauterina**
- **Prematuridade**
- **Malformações congênitas**

### Limitações
- ⚠️ **Não substitui avaliação clínica completa**
- ⚠️ **Não prevê prognóstico a longo prazo**
- ⚠️ **Deve ser usado com outros parâmetros**
- ⚠️ **Considerar histórico materno**

### Quando Reavaliar
- Score < 7: reavaliar a cada 5 minutos
- Score em queda: investigar causas
- Sem melhora após reanimação: considerar outras causas

## 🩺 Protocolos de Reanimação

### Suporte Básico (Score 6-7)
1. Secar vigorosamente
2. Remover fluidos das vias aéreas
3. Estimulação tátil
4. Oxigênio por máscara (5 L/min)
5. Manter temperatura (38-39°C)

### Suporte Avançado (Score 4-5)
1. Aspirar boca e narinas
2. Oxigenoterapia com máscara vedada
3. Doxapram sublingual (1-2 gotas)
4. Estimulação vigorosa
5. Posicionar em decúbito esternal

### Suporte de Emergência (Score 0-3)
1. **Via aérea**: Intubação orotraqueal
2. **Ventilação**: 10-20 mpm, pressão 10-15 cmH₂O
3. **Circulação**: Massagem se FC < 60 bpm
4. **Medicação**: Adrenalina 0.01-0.02 mg/kg IV/IO
5. **Acesso**: Cateter umbilical ou intraósseo
6. **Temperatura**: Aquecedor, bolsas térmicas

## ✅ Status

**Implementação completa** ✓
- ✅ Seleção dinâmica por espécie
- ✅ 5 parâmetros com pontuação 0-2
- ✅ Cálculo automático do escore
- ✅ Interpretação e recomendações
- ✅ Interface responsiva e intuitiva
- ✅ Validações robustas
- ✅ Diálogo de ajuda
- ✅ Integração com app
- ✅ Documentação completa

## 📚 Referências

- **Moon PF et al.** (2000). *Peripartum changes in canine fetal heart rate*. Theriogenology.
- **Veronesi MC et al.** (2009). *Assessment of canine neonatal viability by umbilical vein lactate and blood gas analysis*. Reproduction in Domestic Animals.
- **Silva LCG et al.** (2008). *Escore Apgar na avaliação de neonatos caninos*. Brazilian Journal of Veterinary Research.
- **Vannucchi CI et al.** (2012). *Prenatal and neonatal adaptations with a focus on the respiratory system*. Reproduction in Domestic Animals.

## 🆘 Troubleshooting

**Campos não resetam ao mudar espécie:**
- Comportamento esperado: apenas FC e Respiração resetam (são dinâmicos)
- Mucosas, Irritabilidade e Motilidade mantêm valores

**Score não calcula:**
- Verifique se todos os 5 parâmetros foram preenchidos
- Validação exige espécie + 5 parâmetros obrigatórios

**Recomendações não aparecem:**
- `showRecommendations` deve ser `true` no `ScoreDisplay`
- Verifique se `_showResult` está ativo

---

**Última atualização:** 31 de Outubro de 2025  
**Versão:** 1.0  
**Status:** ✅ Completo e funcional
