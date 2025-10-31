
# Guia de Configuração e Desenvolvimento (SETUPGUIDE.md)

Este guia fornece instruções detalhadas para configurar o ambiente de desenvolvimento, compilar e executar o projeto **Vet Anesthesia Helper**.

## 1. Pré-requisitos

Antes de começar, certifique-se de que você tem as seguintes ferramentas instaladas e configuradas em sua máquina:

- **Git:** Para clonar o repositório. [Download Git](https://git-scm.com/downloads)
- **Flutter SDK:** Versão `>=3.0.0`. O Flutter SDK inclui o Dart SDK. [Instalação do Flutter](https://flutter.dev/docs/get-started/install)
- **Um Editor de Código:**
  - **Visual Studio Code:** Com a extensão [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter).
  - **Android Studio:** Com o plugin [Flutter](https://flutter.dev/docs/get-started/editor?tab=androidstudio).
- **Configuração de Plataforma Específica:**
  - **Android:** Android Studio para instalar o Android SDK e as ferramentas de linha de comando.
  - **iOS (apenas em macOS):** Xcode para compilar para dispositivos iOS.
  - **Web:** Google Chrome para desenvolvimento web.

### Verificando a Instalação do Flutter

Após instalar o Flutter, execute o seguinte comando no seu terminal para verificar se há alguma dependência faltando:

```bash
flutter doctor
```

O `flutter doctor` irá analisar sua configuração e mostrar um relatório do status da sua instalação. Resolva quaisquer problemas (`[!]`) que ele apontar antes de prosseguir.

## 2. Clonando o Repositório

Use o Git para clonar o projeto para sua máquina local:

```bash
git clone https://github.com/Marcao-Martins/App-dimitri.git
cd App-dimitri
```

## 3. Instalando as Dependências

Com o repositório clonado, o próximo passo é instalar todas as dependências do projeto listadas no arquivo `pubspec.yaml`.

Execute o seguinte comando na raiz do projeto:

```bash
flutter pub get
```

Este comando irá baixar todas as bibliotecas necessárias para o projeto.

## 4. Configurando o Ambiente de Execução

### Android
1.  Abra o Android Studio.
2.  Vá para `Tools > AVD Manager` e crie um novo Emulador Android (AVD).
3.  Inicie o emulador.
4.  Alternativamente, conecte um dispositivo Android físico via USB e ative o modo de desenvolvedor e a depuração USB.

### iOS (apenas macOS)
1.  Abra o Xcode.
2.  Conecte um dispositivo iOS físico ou use o Simulador (`Xcode > Open Developer Tool > Simulator`).
3.  Para rodar em um dispositivo físico, pode ser necessário configurar a assinatura de código no Xcode.

### Web
Nenhuma configuração adicional é necessária. O Flutter usará o Google Chrome (se instalado) como o dispositivo padrão para desenvolvimento web.

## 5. Executando o Aplicativo

Com o ambiente configurado e um dispositivo/emulador em execução, você pode iniciar o aplicativo.

1.  **Verifique os dispositivos conectados:**
    ```bash
    flutter devices
    ```
    Este comando listará todos os emuladores, simuladores e dispositivos físicos disponíveis.

2.  **Execute o aplicativo:**
    - Para executar no dispositivo selecionado:
      ```bash
      flutter run
      ```
    - Para selecionar um dispositivo específico (se vários estiverem disponíveis):
      ```bash
      flutter run -d <device_id>
      ```
      (Substitua `<device_id>` pelo ID do dispositivo da lista `flutter devices`).

O aplicativo será compilado e instalado no dispositivo. O modo de depuração inclui o **Hot Reload**, que permite aplicar alterações no código quase instantaneamente sem reiniciar o app.

## 6. Estrutura do Projeto

A estrutura de pastas principal do código-fonte está em `lib/`:

```
lib/
├── main.dart               # Ponto de entrada da aplicação e navegação principal
├── core/                   # Widgets, constantes, temas e utilitários compartilhados
│   ├── constants/
│   ├── providers/
│   ├── themes/
│   ├── utils/
│   └── widgets/
├── features/               # Módulos de funcionalidades principais
│   ├── dose_calculator/
│   ├── drug_guide/
│   ├── explorer/           # Tela inicial
│   ├── ficha_anestesica/
│   ├── fluidotherapy/      # Calculadora de Fluidoterapia
│   ├── pre_op_checklist/
│   ├── rcp/                # Módulo de RCP Coach
│   └── transfusion/        # Calculadora de Transfusão
├── models/                 # Modelos de dados usados em múltiplos features
└── services/               # Serviços (ex: PDF, armazenamento)
```

## 7. Compilando para Produção (Build)

Quando o aplicativo estiver pronto para ser lançado, use os seguintes comandos para gerar os pacotes de produção:

### Android

- **APK (pacote único):**
  ```bash
  flutter build apk --release
  ```
  O arquivo de saída estará em `build/app/outputs/flutter-apk/app-release.apk`.

- **App Bundle (recomendado para a Google Play Store):**
  ```bash
  flutter build appbundle --release
  ```
  O arquivo de saída estará em `build/app/outputs/bundle/release/app-release.aab`.

### iOS (apenas macOS)

1.  Execute o comando de build:
    ```bash
    flutter build ipa --release
    ```
2.  Abra o projeto no Xcode (`ios/Runner.xcworkspace`).
3.  Configure a versão e o build number.
4.  Use o Xcode para arquivar e distribuir o aplicativo para a App Store Connect.

### Web

```bash
flutter build web --release
```
O conteúdo da pasta `build/web` pode ser hospedado em qualquer serviço de hospedagem web (Firebase Hosting, Netlify, etc.).

## 8. Troubleshooting Comum

- **Problemas de dependências ou build:**
  Tente limpar o cache de build do Flutter:
  ```bash
  flutter clean
  flutter pub get
  ```

- **O app não roda ou apresenta erros inesperados:**
  Verifique novamente a sua instalação com `flutter doctor` para garantir que tudo está configurado corretamente.

- **Problemas específicos de plataforma (Android/iOS):**
  - **Android:** Verifique se o `build.gradle` e `local.properties` estão corretos.
  - **iOS:** Abra o projeto no Xcode (`ios/Runner.xcworkspace`) para verificar se há problemas de configuração de pods ou de assinatura de código. Execute `pod install` no diretório `ios/`.

---
**Última atualização:** 30 de Outubro de 2025
