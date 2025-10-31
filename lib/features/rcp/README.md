# 🫀 Módulo RCP Coach

## Visão Geral
Módulo de auxílio para Ressuscitação Cardiopulmonar (RCP) em anestesiologia veterinária, com timer de 2 minutos, metrônomo de compressões e alertas sonoros.

## 📁 Estrutura de Arquivos

```
lib/features/rcp/
├── rcp_page.dart              # Página principal com UI completa (Título: "RCP")
├── rcp_controller.dart        # Lógica de negócio (timer, áudio, ciclos, wake lock)
└── widgets/
    ├── circular_timer.dart    # Timer circular VERMELHO animado
    └── control_buttons.dart   # Botões: play/pause/reset/mute/wake lock
```

## ⚡ Funcionalidades

### 1. **Timer de Ciclos (2 minutos)**
- ✅ Contagem regressiva de 120 segundos
- ✅ Display circular com progressão visual
- ✅ Formato MM:SS com números tabulares (monospace)
- ✅ Reinício automático após cada ciclo
- ✅ **COR VERMELHA** constante (conforme solicitado) 🔴

### 2. **Metrônomo de Compressões**
- ✅ Beep a cada **500ms** (120 BPM)
- ✅ Volume reduzido (50%) para não sobrepor alerta de ciclo
- ✅ Guia ritmo ideal de compressões torácicas

### 3. **Sistema de Áudio**
- ✅ **Metrônomo:** `beep.mp3` (500ms intervalo)
- ✅ **Alerta de ciclo:** `cycle_end.mp3` (volume 100%)
- ✅ Dois `AudioPlayer` independentes para evitar conflitos
- ✅ Controle de mute global

### 4. **Controles Interativos**
- ✅ **Botão INICIAR/PAUSAR** (laranja quando ativo)
- ✅ **Botão REINICIAR** (reseta timer e contador)
- ✅ **Botão SOM ON/OFF** (mute/unmute)
- ✅ **Botão TELA SEMPRE LIGADA** (wake lock) 🆕
- ✅ Estados disabled conforme lógica
- ✅ Feedback visual claro

### 5. **Wake Lock (Tela Sempre Ligada)** 🆕
- ✅ Mantém tela ativa durante uso do RCP
- ✅ Ícone: `Icons.screen_lock_portrait`
- ✅ Cor laranja quando ativo, cinza quando inativo
- ✅ Desativa automaticamente ao sair da tela
- ✅ Label: "Tela Ativa" / "Tela Normal"
- ✅ Pacote: `wakelock_plus: ^1.2.8`

### 6. **Contador de Ciclos**
- ✅ Badge com contagem de ciclos completos
- ✅ Incremento automático a cada 2 minutos
- ✅ Reset manual disponível

### 6. **Mensagens de Status**
- ✅ "Pronto para iniciar"
- ✅ "Compressões torácicas - 100-120/min"
- ✅ "Continue as compressões - XX:XX"
- ✅ "Pausado - XX:XX restante"
- ✅ "Ciclo completo! Avalie paciente"

### 7. **Diálogo de Ajuda**
- ✅ Instruções sobre compressões (30:2)
- ✅ Explicação do timer e metrônomo
- ✅ Dicas de uso do áudio

## 🎨 Design

### Cores e Estados
- **Timer circular:** VERMELHO constante (Colors.red) 🔴
- **Botão rodando:** Laranja (#FF9800)
- **Botão pausado:** Primário
- **Wake Lock ativo:** Laranja
- **Wake Lock inativo:** Cinza

### Título da Página
- **AppBar:** "RCP" (simplificado conforme solicitado)

### Layout Responsivo
- Timer circular adapta tamanho ao espaço disponível
- Font size responsivo baseado em constraints
- Padding e spacing ajustados para mobile/tablet
- 3 botões secundários em linha (Som, Tela, Reset)

## 🔊 Arquivos de Áudio

Localizados em `assets/sounds/`:
- `beep.mp3` - Som curto para metrônomo (500ms)
- `cycle_end.mp3` - Alerta sonoro ao fim do ciclo

## 🏗️ Arquitetura

### Estado (Provider)
```dart
RcpController (ChangeNotifier)
├── Timer countdown (1s)
├── Timer metrônomo (500ms)
├── AudioPlayer metrônomo
├── AudioPlayer alertas
├── Wake Lock (wakelock_plus)
└── Notifica UI a cada mudança
```

### Widgets
```
RcpPage (StatelessWidget)
└── ChangeNotifierProvider<RcpController>
    └── Consumer
        ├── Chip (contador de ciclos)
        ├── Container (mensagem de status)
        ├── CircularTimer (CustomPaint VERMELHO)
        └── ControlButtons
            ├── ElevatedButton (play/pause)
            ├── OutlinedButton (mute)
            ├── OutlinedButton (wake lock) 🆕
            └── OutlinedButton (reset)
```

## 🔧 Tecnologias

- **Timer:** `Timer.periodic` (dart:async)
- **Áudio:** `audioplayers` package (^6.5.1)
- **Wake Lock:** `wakelock_plus` package (^1.2.8) 🆕
- **Estado:** `provider` package (^6.1.5)
- **Animação:** `CustomPaint` + `CustomPainter`
- **Font:** `FontFeature.tabularFigures()` para números
        ├── Chip (contador de ciclos)
        ├── Container (mensagem de status)
        ├── CircularTimer (CustomPaint)
        └── ControlButtons
            ├── ElevatedButton (play/pause)
            ├── OutlinedButton (mute)
            └── OutlinedButton (reset)
```

## 🔧 Tecnologias

- **Timer:** `Timer.periodic` (dart:async)
- **Áudio:** `audioplayers` package (^6.5.1)
- **Estado:** `provider` package (^6.1.5)
- **Animação:** `CustomPaint` + `CustomPainter`
- **Font:** `FontFeature.tabularFigures()` para números

## 📊 Fluxo de Execução

```mermaid
graph TD
    A[Usuário clica INICIAR] --> B[startStop()]
    B --> C{isRunning?}
    C -->|false| D[_start()]
    D --> E[Inicia countdown timer 1s]
    D --> F[Inicia metrônomo timer 500ms]
    F --> G[Play beep.mp3]
    E --> H{secondsRemaining > 0?}
    H -->|sim| I[Decrementa segundos]
    H -->|não| J[_cycleCompleted()]
    J --> K[Play cycle_end.mp3]
    J --> L[Incrementa cycleCount]
    J --> M[Reset timer para 120s]
    M --> E
    C -->|true| N[_pause()]
    N --> O[Cancela timers]
```

## 🎯 Casos de Uso

### Iniciar RCP
1. Usuário clica "INICIAR"
2. Timer começa de 02:00
3. Metrônomo toca beeps a cada 500ms (120 BPM)
4. Display mostra tempo decrescente
5. Ao chegar em 00:00, alerta toca e timer reinicia automaticamente

### Pausar RCP
1. Usuário clica "PAUSAR"
2. Timer e metrônomo param
3. Tempo atual é preservado
4. Botão muda para "INICIAR"

### Reiniciar RCP
1. Usuário clica "Reiniciar"
2. Timer volta para 02:00
3. Contador de ciclos zera
4. Estado volta para pausado

### Mutar Áudio
1. Usuário clica "Som OFF"
2. Metrônomo e alertas são silenciados
3. Timer continua funcionando normalmente

## 🔒 Boas Práticas Implementadas

✅ Dois `AudioPlayer` independentes (evita conflitos)  
✅ Dispose correto de timers e players  
✅ Estado imutável com notifyListeners()  
✅ Widgets reutilizáveis e desacoplados  
✅ Documentação inline clara  
✅ Tratamento de edge cases (timer em 0, ciclos múltiplos)  
✅ UI responsiva com LayoutBuilder  
✅ Cores acessíveis e contrastes adequados  

## 🚀 Como Usar

### Navegação
```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const RcpPage()),
);
```

### Personalização de Áudio
Para trocar sons, substitua os arquivos em `assets/sounds/`:
- `beep.mp3` - Duração recomendada: 50-100ms
- `cycle_end.mp3` - Duração recomendada: 1-2s

E atualize `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/sounds/beep.mp3
    - assets/sounds/cycle_end.mp3
```

## 📝 Notas Técnicas

- **BPM do Metrônomo:** 120 BPM = 500ms entre beeps
- **Duração do Ciclo:** 2 minutos (120 segundos)
- **Protocolo RCP:** 30 compressões : 2 ventilações
- **Volume Metrônomo:** 50% (para não interferir com alertas)
- **Volume Alertas:** 100% (destaque ao fim do ciclo)

## 🐛 Troubleshooting

**Áudio não toca:**
- Verificar se arquivos estão em `assets/sounds/`
- Verificar se `pubspec.yaml` lista os assets
- Verificar permissões de áudio no dispositivo
- Verificar se mute está desativado

**Timer não inicia:**
- Verificar logs do console
- Verificar se `Timer.periodic` está sendo criado
- Verificar se `notifyListeners()` é chamado

**Performance ruim:**
- `CustomPaint` otimizado com `shouldRepaint`
- Timers cancelados no dispose
- Sem rebuilds desnecessários (Consumer específico)

## 📚 Referências

- [Audioplayers Package](https://pub.dev/packages/audioplayers)
- [Provider State Management](https://pub.dev/packages/provider)
- [CustomPaint Flutter](https://api.flutter.dev/flutter/widgets/CustomPaint-class.html)
- [Timer Dart](https://api.dart.dev/stable/dart-async/Timer-class.html)

---

**Última atualização:** Outubro 2025  
**Versão:** 2.0  
**Status:** ✅ Completo e funcional
