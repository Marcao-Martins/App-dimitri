# Termo de Consentimento Livre e Esclarecido

## 📋 Descrição

Módulo completo para geração de Termo de Consentimento Livre e Esclarecido para procedimentos anestésicos veterinários, com geração de PDF profissional para uso clínico.

## 🎯 Funcionalidades

### Formulário Completo
- **Dados do Médico Veterinário**: Nome, CRMV, Clínica/Hospital
- **Dados do Animal**: Nome, Espécie (Cão/Gato), Raça, Sexo
- **Dados do Responsável**: Nome, CPF (formatado), Telefone (formatado), Endereço
- **Dados do Procedimento**: Tipo de anestesia, Informações adicionais, Cidade, Data
- **Observações**: Campo opcional para informações extras

### Validações
- ✅ Campos obrigatórios com asterisco
- ✅ Formatação automática de CPF (000.000.000-00)
- ✅ Formatação automática de Telefone ((00) 00000-0000)
- ✅ Validação de comprimento de CPF (11 dígitos)
- ✅ Mensagens de erro específicas por campo
- ✅ Diálogo com lista de campos inválidos

### Geração de PDF
- **Visualização**: Preview do termo antes de gerar
- **Salvar**: Salva PDF no dispositivo (Downloads no Android, Documentos no iOS)
- **Compartilhar**: Compartilha PDF via apps instalados
- **Imprimir**: Envia PDF diretamente para impressora

### Layout do PDF
- ✅ Cabeçalho profissional com dados da clínica
- ✅ Título centralizado e destacado
- ✅ Seções organizadas por categoria
- ✅ 8 cláusulas de consentimento numeradas
- ✅ Espaço para assinaturas (responsável e veterinário)
- ✅ Local e data
- ✅ Campos opcionais tratados adequadamente

## 🏗️ Arquitetura

```
lib/features/consent_form/
├── consent_form_page.dart              # Página principal do formulário
├── consent_form_controller.dart        # Controller com gerenciamento de estado
├── models/
│   └── consent_data.dart               # Modelo de dados com validação
├── widgets/
│   ├── doctor_section.dart             # Seção de dados do médico
│   ├── animal_section.dart             # Seção de dados do animal
│   ├── owner_section.dart              # Seção de dados do responsável
│   └── procedure_section.dart          # Seção de dados do procedimento
└── pdf/
    ├── consent_pdf_template.dart       # Template do PDF profissional
    └── pdf_generator.dart              # Gerador de PDF com múltiplas opções
```

## 🎨 Interface

### Cards Organizados
Cada seção do formulário está em um `Card` separado com:
- Ícone representativo
- Título da seção
- Campos agrupados logicamente
- Validações inline

### Botões de Ação
1. **Visualizar Termo**: Preview do PDF antes de gerar
2. **Gerar PDF**: Abre diálogo com opções:
   - Salvar no dispositivo
   - Compartilhar
   - Imprimir

### Estados Visuais
- Loading ao gerar PDF
- Botões desabilitados durante processamento
- SnackBars com feedback de sucesso/erro
- Diálogos de confirmação

## 📝 Cláusulas do Termo

O PDF gerado inclui 8 cláusulas padrão:

1. Declaração de ciência sobre procedimentos
2. Conhecimento de riscos anestésicos
3. Autorização para medidas de emergência
4. Informação de histórico clínico completo
5. Conhecimento sobre jejum pré-anestésico
6. Compromisso com orientações pós-operatórias
7. Autorização para exames complementares
8. Confirmação de esclarecimento de dúvidas

## 🔢 Formatadores

### CPF Input Formatter
```dart
000.000.000-00
```
- Remove caracteres não numéricos
- Adiciona pontos e hífen automaticamente
- Limita a 11 dígitos

### Telefone Input Formatter
```dart
(00) 00000-0000  // Celular
(00) 0000-0000    // Fixo
```
- Detecta automaticamente formato (celular/fixo)
- Adiciona parênteses, espaço e hífen
- Limita a 11 dígitos

## 💾 Armazenamento

### Android
```dart
/storage/emulated/0/Download/Termo_Consentimento_Nome_Data.pdf
```

### iOS
```dart
~/Documents/Termo_Consentimento_Nome_Data.pdf
```

### Formato do Nome do Arquivo
```
Termo_Consentimento_{Nome_Animal}_{Data}.pdf
Exemplo: Termo_Consentimento_Rex_20251031.pdf
```

## 🎯 Casos de Uso

### 1. Preenchimento Completo
1. Veterinário preenche dados da clínica e dele mesmo
2. Preenche dados do paciente e responsável
3. Informa tipo de procedimento e data
4. Adiciona observações se necessário
5. Visualiza o termo completo
6. Gera e imprime para assinatura

### 2. Uso Rápido
1. Dados da clínica e veterinário podem ser salvos (futuro)
2. Preenche apenas dados variáveis (paciente, procedimento)
3. Gera PDF e compartilha com responsável

### 3. Arquivo Digital
1. Gera PDF com todos os dados
2. Salva no dispositivo
3. Anexa ao prontuário eletrônico do paciente

## 🔗 Integração

O módulo está integrado na ExplorerPage:

```dart
LibraryIconButton(
  icon: Icons.assignment_outlined,
  label: 'Termo Consentimento',
  color: AppColors.categoryPurple,
  onTap: () => _navigateTo(const ConsentFormPage()),
),
```

## 🎨 Design System

### Cores
- **Purple** (`categoryPurple`): Cor principal do módulo
- **Cards**: Elevation 2 para profundidade sutil
- **Icons**: Cores específicas por tipo de seção

### Tipografia
- **Títulos de Seção**: `titleLarge` + Bold
- **Labels**: Material Design padrão
- **PDF**: Hierarquia clara com tamanhos 14pt (título) até 8pt (assinaturas)

## ⚠️ Observações Importantes

### Legais
- O termo é um modelo genérico e deve ser adaptado conforme necessidades específicas
- Recomenda-se revisão jurídica antes do uso clínico
- As cláusulas cobrem os aspectos principais mas não substituem orientação legal

### Técnicas
- PDFs são gerados em memória (não salvos temporariamente)
- Permissões de armazenamento podem ser necessárias no Android
- iOS requer configuração no Info.plist para salvar arquivos

### Clínicas
- Os dados não são salvos automaticamente
- Cada termo é gerado independentemente
- Responsável deve assinar fisicamente após impressão

## 📱 Responsividade

- ✓ `ListView` com scroll para formulários longos
- ✓ Cards adaptáveis ao tamanho da tela
- ✓ Botões responsivos (width: double.infinity)
- ✓ Text wrapping automático
- ✓ Margins e paddings consistentes

## 🔄 Estado

O módulo usa `ChangeNotifierProvider` localmente:
- Estado não persiste entre sessões
- Controllers são disposed corretamente
- Limpeza de formulário disponível

## ✅ Status

**Implementado:**
- ✅ Modelo de dados completo
- ✅ Formulário com todas as seções
- ✅ Validações robustas
- ✅ Formatadores de CPF e telefone
- ✅ Template PDF profissional
- ✅ Geração, visualização, compartilhamento e impressão
- ✅ Integração na navegação do app
- ✅ UI moderna e intuitiva

**Futuras Melhorias:**
- [ ] Salvar dados da clínica/veterinário (SharedPreferences)
- [ ] Histórico de termos gerados
- [ ] Templates customizáveis
- [ ] Assinatura digital (stylus)
- [ ] Campos adicionais opcionais
- [ ] Múltiplos idiomas

## 📚 Dependências

```yaml
dependencies:
  pdf: ^3.10.8           # Criação de PDFs
  printing: ^5.11.1      # Visualização e impressão
  path_provider: ^2.1.1  # Acesso a diretórios
  intl: ^0.19.0          # Formatação de datas
  provider: ^6.1.5       # Gerenciamento de estado
```

## 🚀 Como Usar

```dart
// Navegação direta
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ConsentFormPage(),
  ),
);
```

## 📄 Exemplo de PDF Gerado

```
┌────────────────────────────────────────┐
│ Clínica Veterinária Pet Saúde          │
│ Médico Veterinário: Dr. João Silva     │
│ CRMV: SP 12345                          │
├────────────────────────────────────────┤
│                                        │
│   TERMO DE CONSENTIMENTO LIVRE E       │
│        ESCLARECIDO                     │
│   PARA PROCEDIMENTO ANESTÉSICO         │
│                                        │
├────────────────────────────────────────┤
│ DADOS DO ANIMAL                        │
│ Nome: Rex                              │
│ Espécie: Cão                           │
│ Raça: Golden Retriever                 │
│ Sexo: Macho                            │
├────────────────────────────────────────┤
│ DADOS DO RESPONSÁVEL                   │
│ Nome: Maria Silva Santos               │
│ CPF: 000.000.000-00                    │
│ Telefone: (00) 00000-0000              │
│ Endereço: Rua X, 123, Bairro Y...      │
├────────────────────────────────────────┤
│ PROCEDIMENTO                           │
│ Tipo: Anestesia geral para castração  │
├────────────────────────────────────────┤
│ DECLARAÇÃO DE CONSENTIMENTO            │
│                                        │
│ 1. Eu, na qualidade de proprietário...│
│ 2. DECLARO estar ciente dos riscos... │
│ ... (8 cláusulas completas)           │
├────────────────────────────────────────┤
│ São Paulo, 31/10/2025                  │
│                                        │
│ _______________  _______________       │
│  Responsável     Veterinário           │
└────────────────────────────────────────┘
```

---

**Última atualização:** 31 de Outubro de 2025
**Versão:** 1.0.0
**Status:** ✅ Produção
