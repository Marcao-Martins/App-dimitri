# Ficha Anestésica - Documentação

## Visão Geral

A funcionalidade **Ficha Anestésica** permite criar, gerenciar e exportar fichas anestésicas veterinárias completas com monitorização em tempo real, gráficos de tendência e exportação profissional em PDF.

## Estrutura de Arquivos

```
lib/features/ficha_anestesica/
├── models/
│   ├── ficha_anestesica.dart       # Modelo agregado principal
│   ├── paciente.dart                # Dados do paciente
│   ├── medicacao.dart               # Medicamentos e dosagens
│   ├── parametro_monitorizacao.dart # Parâmetros vitais
│   └── intercorrencia.dart          # Intercorrências
├── services/
│   └── storage_service.dart         # Persistência com Hive
├── pdf/
│   └── pdf_service.dart             # Geração de PDF profissional
├── widgets/
│   ├── paciente_form_widget.dart    # Formulário de identificação
│   ├── dynamic_table.dart           # Tabela de medicações
│   ├── monitoring_table.dart        # Tabela de parâmetros
│   └── charts_widget.dart           # Gráficos de tendência
├── ficha_provider.dart              # State management (Provider)
└── ficha_anestesica_page.dart       # Tela principal com tabs
```

## Funcionalidades

### 1. Identificação do Paciente
- **Campos obrigatórios**: Nome, Espécie, Sexo, Peso, ASA
- **Campos opcionais**: Data, Idade, Procedimento, Doenças, Observações
- **Validações**: Peso numérico, ASA selecionável, espécies predefinidas

### 2. Medicações (Tabelas Dinâmicas)
Seções disponíveis:
- Medicação Pré-anestésica
- Antimicrobianos
- Indução Anestésica
- Manutenção Anestésica
- Anestesia Locorregional
- Analgesia Pós-operatória

**Recursos:**
- Adicionar/remover linhas dinamicamente
- Campos: Fármaco (obrigatório), Dose, Via, Hora
- Time picker para seleção de horário
- Validação de campos obrigatórios

### 3. Monitorização de Parâmetros
- **Parâmetros registrados**: FC, FR, SpO2, ETCO2, PAS, PAD, PAM, Temperatura
- **Ações**: Adicionar novo tempo, Editar parâmetros, Remover registro
- **Interface**: Tabela responsiva com scroll horizontal
- **Atualização em tempo real** nos gráficos

### 4. Gráficos de Tendência
Gráficos interativos atualizados automaticamente:
- **Frequência Cardíaca** (0-200 bpm)
- **Pressão Arterial** (PAS/PAD/PAM, 0-200 mmHg)
- **Frequência Respiratória** (0-60 mpm)
- **SpO2 e ETCO2** (0-100%)
- **Temperatura** (35-40°C)

**Recursos:**
- Tooltips com valores exatos ao tocar
- Linhas suavizadas (curved)
- Cores diferenciadas por parâmetro
- Escalas Y ajustadas por tipo de parâmetro

### 5. Exportação PDF
PDF profissional com:
- Cabeçalho institucional (GDVet)
- Identificação completa do paciente
- Todas as tabelas de medicação
- Tabela de monitorização temporal
- Seção de intercorrências
- Campos para assinatura e CRMV

**Como usar:**
1. Preencha a ficha
2. Clique no ícone PDF na AppBar
3. Escolha imprimir, salvar ou compartilhar

### 6. Persistência Local
- **Tecnologia**: Hive (NoSQL local)
- **Ações**: Salvar, Carregar, Deletar fichas
- **Armazenamento**: Fichas salvas automaticamente no dispositivo
- **Listagem**: Visualizar fichas salvas na tela inicial

## Como Usar

### Criar Nova Ficha
1. Abra a aba **Ficha** na navegação inferior
2. Clique no botão flutuante **"Nova Ficha"**
3. Preencha o formulário de identificação do paciente
4. Clique em **"Salvar Paciente"**

### Adicionar Medicações
1. Navegue até a aba **"Paciente & Medicações"**
2. Escolha a seção desejada (Pré-anestésica, Indução, etc.)
3. Clique em **"Adicionar"**
4. Preencha os dados do medicamento
5. Confirme

### Registrar Monitorização
1. Navegue até a aba **"Monitorização"**
2. Clique no ícone **"+"** no canto superior direito
3. Preencha os parâmetros vitais
4. Clique em **"Adicionar"**
5. Repita a cada intervalo de tempo (recomendado: 5 min)

### Visualizar Gráficos
1. Navegue até a aba **"Gráficos"**
2. Os gráficos são atualizados automaticamente conforme você adiciona parâmetros
3. Toque nos pontos para ver valores exatos

### Salvar e Exportar
- **Salvar ficha**: Clique no ícone de disquete na AppBar
- **Exportar PDF**: Clique no ícone PDF na AppBar
- **Fechar ficha**: Clique no "X" na AppBar (lembre-se de salvar antes!)

## Validações Implementadas

### Formulário de Paciente
- Nome: obrigatório, mínimo 1 caractere
- Espécie: obrigatório, seleção de lista
- Sexo: obrigatório, Macho/Fêmea
- Peso: obrigatório, numérico positivo com até 2 casas decimais
- ASA: obrigatório, ASA I-V

### Medicações
- Fármaco: obrigatório
- Dose, Via, Hora: opcionais mas recomendados

### Monitorização
- Todos os campos numéricos
- Temperatura aceita 1 casa decimal
- Campos vazios são salvos como `-` no PDF

## Tecnologias Utilizadas

- **Flutter**: Framework multiplataforma
- **Provider**: Gerenciamento de estado
- **Hive**: Banco de dados local NoSQL
- **fl_chart**: Biblioteca de gráficos interativos
- **pdf + printing**: Geração e exportação de PDFs

## Melhorias Futuras

- [ ] Adicionar campo de Intercorrências na UI
- [ ] Adicionar seção de Recuperação Anestésica
- [ ] Implementar backup/sincronização em nuvem
- [ ] Adicionar gráficos de dispersão para correlação de parâmetros
- [ ] Permitir edição de fichas salvas
- [ ] Adicionar filtros e busca na lista de fichas
- [ ] Exportar em outros formatos (Excel, CSV)
- [ ] Templates de fichas pré-configuradas por procedimento
- [ ] Integração com banco de dados de fármacos

## Suporte

Para reportar bugs ou sugerir melhorias, entre em contato com o time GDVet.

---

**GDVet - Grupo de desenvolvimento veterinário**
