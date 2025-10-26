# VetAnesthesia Helper

Aplicativo móvel desenvolvido para auxiliar anestesiologistas veterinários em sua rotina clínica. O app oferece ferramentas essenciais para cálculo de doses, organização do processo pré-operatório e consulta rápida de informações farmacológicas.

## 🎯 Funcionalidades Principais

### 1. 💉 Calculadora de Doses
- Cálculo automático de doses baseado em peso e espécie
- Validação de faixas seguras de dosagem
- Histórico de cálculos realizados
- Banco de dados com 20+ medicamentos comuns
- Alertas para doses fora do padrão recomendado

### 2. ✅ Checklist Pré-Operatório
- 30+ itens organizados por categorias:
  - Paciente
  - Equipamento
  - Medicação
  - Procedimento
  - Segurança
- Marcação de itens críticos obrigatórios
- Timer de jejum integrado
- Seleção de classificação ASA (I-V)
- Indicador visual de progresso
- Exportação para PDF (em desenvolvimento)

### 3. 📖 Guia de Fármacos
- Banco de dados local com informações detalhadas
- Busca por nome ou categoria
- Filtros por espécie compatível
- Informações incluídas:
  - Doses (mínima e máxima)
  - Indicações e contraindicações
  - Precauções especiais
  - Categoria farmacológica

## 🛠️ Tecnologias Utilizadas

- **Framework:** Flutter 3.19+
- **Linguagem:** Dart (com null safety)
- **Arquitetura:** MVC/Clean Architecture
- **Gerenciamento de Estado:** setState (preparado para Provider/Riverpod)
- **Design:** Material Design 3

## 📁 Estrutura do Projeto

```
lib/
├── core/
│   ├── constants/      # Cores, strings, constantes
│   ├── themes/         # Temas claro e escuro
│   ├── utils/          # Utilitários e formatação
│   └── widgets/        # Widgets reutilizáveis
├── features/
│   ├── dose_calculator/    # Calculadora de doses
│   ├── pre_op_checklist/   # Checklist pré-operatório
│   └── drug_guide/         # Guia de fármacos
├── models/             # Modelos de dados
├── services/           # Lógica de negócio e dados
└── main.dart           # Ponto de entrada
```

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK 3.19 ou superior
- Android Studio ou VS Code
- Emulador Android ou dispositivo físico

### Instalação

1. **Clone o repositório:**
```bash
git clone https://github.com/Marcao-Martins/App-dimitri.git
cd App-dimitri-1
```

2. **Instale as dependências:**
```bash
flutter pub get
```

3. **Execute o aplicativo:**
```bash
flutter run
```

### Comandos Úteis

```bash
# Verificar instalação do Flutter
flutter doctor

# Limpar cache
flutter clean

# Analisar código
flutter analyze

# Executar testes
flutter test

# Gerar APK de release
flutter build apk --release

# Gerar app bundle
flutter build appbundle
```

## 📱 Plataformas Suportadas

- ✅ Android (testado)
- 🔄 iOS (compatível, necessita testes)
- 🔄 Web (compatível, necessita ajustes de UI)

## 🎨 Design

### Tema Claro
Otimizado para ambientes bem iluminados de clínicas e hospitais veterinários.

### Tema Escuro
Reduz fadiga ocular em ambientes com pouca luz ou durante procedimentos noturnos.

## 🔐 Segurança e Responsabilidade

⚠️ **AVISO IMPORTANTE:**
- Este aplicativo é uma ferramenta **auxiliar** e não substitui o julgamento clínico profissional
- Sempre verifique doses e protocolos com literatura atualizada
- Em caso de dúvida, consulte referências oficiais e colegas especializados
- Mantenha-se atualizado com as melhores práticas de anestesia veterinária

## 🧪 Medicamentos Incluídos

O banco de dados inclui:
- **Anestésicos Injetáveis:** Ketamina, Propofol, Tiletamina+Zolazepam
- **Sedativos:** Acepromazina, Midazolam, Dexmedetomidina, Xilazina
- **Opioides:** Morfina, Fentanil, Tramadol, Metadona
- **Anestésicos Locais:** Lidocaína, Bupivacaína
- **Anticolinérgicos:** Atropina
- **Anestésicos Inalatórios:** Isoflurano, Sevoflurano
- **Outros:** Maropitanto, Meloxicam

## 📋 Roadmap de Desenvolvimento

### ✅ Versão 1.0 (Atual)
- [x] Calculadora de doses
- [x] Checklist pré-operatório
- [x] Guia de fármacos
- [x] Interface intuitiva
- [x] Temas claro/escuro

### 🔄 Versão 1.1 (Planejado)
- [ ] Persistência de dados com Hive
- [ ] Histórico completo de cálculos
- [ ] Exportação de checklist para PDF
- [ ] Adicionar mais medicamentos
- [ ] Calculadora de fluidoterapia

### 🔮 Versão 2.0 (Futuro)
- [ ] Sincronização na nuvem
- [ ] Perfis de pacientes
- [ ] Protocolos anestésicos salvos
- [ ] Integração com prontuários
- [ ] Modo offline completo
- [ ] Internacionalização (EN/ES)

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👨‍⚕️ Autor

Desenvolvido com ❤️ para a comunidade veterinária.

**Contato:** [Seu Nome/Email]

## 🙏 Agradecimentos

- Comunidade Flutter/Dart
- Anestesiologistas veterinários que forneceram feedback
- Referências farmacológicas veterinárias

## 📚 Referências

- Grimm KA, et al. Veterinary Anesthesia and Analgesia (5th Edition)
- Tranquilli WJ, et al. Lumb & Jones' Veterinary Anesthesia
- AAHA Anesthesia and Monitoring Guidelines

---

**Nota:** Este aplicativo foi desenvolvido seguindo as melhores práticas de engenharia de software e design de UI/UX para garantir usabilidade em ambiente clínico.
