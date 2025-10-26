# 🚀 Guia de Setup - VetAnesthesia Helper

## Requisitos do Sistema

### Software Necessário
- **Flutter SDK:** 3.19 ou superior
- **Android Studio:** 2023.1 ou superior
- **Java JDK:** 11 ou superior
- **Git:** Para controle de versão

### Verificação do Ambiente

Abra o terminal e execute:
```bash
flutter doctor
```

Certifique-se de que todos os itens estão marcados com ✓ (verde).

---

## 📱 Setup no Android Studio

### 1. Abrir o Projeto

1. Inicie o **Android Studio**
2. Clique em **"Open"** ou **"Open an Existing Project"**
3. Navegue até a pasta `App-dimitri-1`
4. Clique em **"OK"**

### 2. Instalar Dependências

Após abrir o projeto, o Android Studio detectará automaticamente que é um projeto Flutter. No terminal integrado, execute:

```bash
flutter pub get
```

Este comando baixará todas as dependências listadas no `pubspec.yaml`.

### 3. Configurar Emulador Android

#### Opção A: Usar Emulador Existente
1. No Android Studio, clique no ícone **"AVD Manager"** (Device Manager)
2. Selecione um dispositivo virtual existente
3. Clique em **"Play"** (▶️) para iniciar

#### Opção B: Criar Novo Emulador
1. Abra **AVD Manager** (Tools > Device Manager)
2. Clique em **"Create Device"**
3. Escolha um dispositivo (recomendado: **Pixel 6**)
4. Selecione uma API System Image (recomendado: **API 33 - Android 13**)
5. Clique em **"Next"** e depois em **"Finish"**

### 4. Executar o Aplicativo

Com o emulador iniciado:

```bash
flutter run
```

Ou use o botão **"Run"** (▶️) no Android Studio.

---

## 🔧 Comandos Úteis

### Desenvolvimento
```bash
# Hot Reload (recarrega sem perder estado)
# Pressione 'r' no terminal

# Hot Restart (reinicia o app)
# Pressione 'R' no terminal

# Limpar cache e rebuildar
flutter clean
flutter pub get
flutter run

# Ver logs em tempo real
flutter logs

# Analisar código
flutter analyze
```

### Build
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (para Google Play)
flutter build appbundle --release
```

---

## 📂 Estrutura de Arquivos Importantes

```
App-dimitri-1/
├── lib/
│   ├── main.dart                    # Ponto de entrada
│   ├── core/                        # Recursos compartilhados
│   │   ├── constants/               # Constantes globais
│   │   ├── themes/                  # Temas do app
│   │   ├── utils/                   # Utilitários
│   │   └── widgets/                 # Widgets reutilizáveis
│   ├── features/                    # Funcionalidades
│   │   ├── dose_calculator/         # Calculadora
│   │   ├── pre_op_checklist/        # Checklist
│   │   └── drug_guide/              # Guia de fármacos
│   ├── models/                      # Modelos de dados
│   └── services/                    # Lógica de negócio
├── pubspec.yaml                     # Dependências
├── analysis_options.yaml            # Regras de análise
└── README.md                        # Documentação
```

---

## 🐛 Solução de Problemas Comuns

### Erro: "Flutter SDK not found"
**Solução:**
1. Vá em **File > Settings > Languages & Frameworks > Flutter**
2. Configure o caminho do Flutter SDK
3. Clique em **"Apply"** e **"OK"**

### Erro: "Gradle build failed"
**Solução:**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Erro: "No devices found"
**Solução:**
1. Certifique-se de que o emulador está rodando
2. Ou conecte um dispositivo físico via USB com **USB Debugging** ativado
3. Execute: `flutter devices` para verificar

### Erro: "Package not found"
**Solução:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

### Emulador muito lento
**Solução:**
1. Certifique-se de que a **virtualização está habilitada** no BIOS
2. Use uma API mais leve (API 29-30)
3. Reduza a RAM do emulador (2GB é suficiente)
4. Ou use um dispositivo físico

---

## 🎨 Customização

### Alterar Nome do App
Edite `pubspec.yaml`:
```yaml
name: seu_nome_aqui
description: Sua descrição aqui
```

### Alterar Ícone do App
1. Adicione o ícone em `assets/icon/icon.png`
2. Use o pacote `flutter_launcher_icons`
3. Execute: `flutter pub run flutter_launcher_icons`

### Adicionar Novos Medicamentos
Edite `lib/services/medication_service.dart` e adicione à lista `_medications`.

---

## 📊 Performance

### Modo Release vs Debug
- **Debug:** Inclui hot reload, logs detalhados, mas é mais lento
- **Release:** Otimizado, sem hot reload, performance máxima

### Dicas de Otimização
```dart
// Use const sempre que possível
const Text('Hello');

// Evite rebuilds desnecessários
const SizedBox(height: 16);

// Use ListView.builder para listas longas
ListView.builder(itemBuilder: ...)
```

---

## 🧪 Testes

### Executar Testes (quando disponíveis)
```bash
flutter test
```

### Executar com Coverage
```bash
flutter test --coverage
```

---

## 📱 Deploy para Dispositivo Físico

### Android
1. Ative **"Opções do Desenvolvedor"** no dispositivo
2. Ative **"Depuração USB"**
3. Conecte via USB
4. Execute: `flutter run`

### iOS (requer macOS)
1. Conecte o iPhone
2. Configure assinatura no Xcode
3. Execute: `flutter run`

---

## 📚 Recursos Adicionais

- **Documentação Flutter:** https://flutter.dev/docs
- **Flutter Cookbook:** https://flutter.dev/docs/cookbook
- **Dart Language Tour:** https://dart.dev/guides/language/language-tour
- **Material Design:** https://material.io/design

---

## ✅ Checklist de Setup

- [ ] Flutter SDK instalado e configurado
- [ ] Android Studio instalado
- [ ] `flutter doctor` sem erros
- [ ] Projeto aberto no Android Studio
- [ ] Dependências instaladas (`flutter pub get`)
- [ ] Emulador ou dispositivo configurado
- [ ] App executado com sucesso
- [ ] Hot reload funcionando

---

## 🆘 Suporte

Se encontrar problemas:
1. Consulte a seção de **Solução de Problemas** acima
2. Execute `flutter doctor -v` para diagnóstico detalhado
3. Verifique os logs do Android Studio
4. Consulte a documentação oficial do Flutter

---

**Desenvolvido com ❤️ para a comunidade veterinária**

Bom desenvolvimento! 🚀
