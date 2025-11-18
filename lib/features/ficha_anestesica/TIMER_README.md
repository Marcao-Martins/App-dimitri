# Cronômetro de Procedimento - Ficha Anestésica

## 📋 Visão Geral

O **Cronômetro de Procedimento** é um componente integrado à Ficha Anestésica do GDVet que permite o controle preciso do tempo cirúrgico/anestésico, com sincronização automática com todos os dados de monitorização.

## ✨ Funcionalidades

### 1. Controle de Tempo
- ⏱️ **Formato HH:MM:SS** com display grande e legível
- ▶️ **Iniciar** procedimento com um clique
- ⏸️ **Pausar/Continuar** para interrupções
- ⏹️ **Parar** com diálogo de confirmação
- 🔄 **Reset** opcional ao finalizar

### 2. Visual Intuitivo
- 🎨 Display destacado que muda de cor quando em execução
- 📊 Indicador visual de status (Em andamento/Pausado)
- 🔵 Ícone animado quando o timer está rodando
- 📱 Layout responsivo e adaptado ao Material 3

### 3. Integração com Sistema
- 💾 **Persistência automática** ao salvar a ficha
- 🔄 **Restauração de estado** ao reabrir ficha salva
- 📈 **Sincronização** com gráficos de monitorização
- ⏰ **Referência temporal** para medicamentos e parâmetros
- 👁️ **Visualização** em todas as abas da ficha

## 🎯 Localização

### Aba "Paciente & Medicações"
- **Posição**: Topo da página, antes das informações do paciente
- **Função**: Controle completo (iniciar/pausar/parar)
- **Visual**: Card destacado com todos os botões de controle

### Aba "Monitorização"
- **Posição**: Topo da página, antes da tabela de parâmetros
- **Função**: Visualização rápida do tempo decorrido
- **Visual**: Card informativo com tempo atual
- **Nota**: Instruindo o usuário a usar a primeira aba para controlar

## 🔧 Implementação Técnica

### Arquivos Criados/Modificados

#### 1. `widgets/procedure_timer_widget.dart` (NOVO)
Widget standalone com lógica completa do cronômetro:
```dart
class ProcedureTimerWidget extends StatefulWidget {
  final Function(Duration elapsedTime)? onTick;
  final Duration? initialDuration;
  final bool startRunning;
}
```

**Métodos Públicos**:
- `Duration get elapsedTime` - Tempo decorrido atual
- `bool get isRunning` - Status de execução
- `bool get hasStarted` - Se já foi iniciado alguma vez

#### 2. `models/ficha_anestesica.dart` (MODIFICADO)
Adicionados campos para persistência:
```dart
class FichaAnestesica {
  // ... campos existentes
  int procedureTimeSeconds;      // Tempo em segundos
  bool timerWasRunning;          // Estado ao salvar
}
```

#### 3. `ficha_provider.dart` (MODIFICADO)
Novo método para atualizar estado do timer:
```dart
void updateTimerState(int seconds, bool isRunning) {
  if (_current != null) {
    _current!.procedureTimeSeconds = seconds;
    _current!.timerWasRunning = isRunning;
    notifyListeners();
  }
}
```

#### 4. `ficha_anestesica_page.dart` (MODIFICADO)
- Adicionado `GlobalKey<ProcedureTimerWidgetState>` para referência
- Integrado widget nas abas de Medicações e Monitorização
- Atualização automática do estado ao salvar

### Fluxo de Dados

```
┌─────────────────────────────────────────────────┐
│           ProcedureTimerWidget                  │
│  (Timer.periodic atualiza a cada segundo)       │
└────────────────┬────────────────────────────────┘
                 │ onTick(Duration)
                 ▼
┌─────────────────────────────────────────────────┐
│            FichaProvider                        │
│  updateTimerState(seconds, isRunning)           │
└────────────────┬────────────────────────────────┘
                 │ notifyListeners()
                 ▼
┌─────────────────────────────────────────────────┐
│          FichaAnestesica Model                  │
│  procedureTimeSeconds: int                      │
│  timerWasRunning: bool                          │
└────────────────┬────────────────────────────────┘
                 │ toJson() / fromJson()
                 ▼
┌─────────────────────────────────────────────────┐
│          StorageService (Hive)                  │
│  Persistência local                             │
└─────────────────────────────────────────────────┘
```

## 📝 Uso Prático

### Cenário 1: Novo Procedimento
1. Crie nova ficha anestésica
2. Clique em **"Iniciar"** quando começar a anestesia
3. O cronômetro começa a contar automaticamente
4. O display fica destacado em azul
5. Status mostra "Em andamento" com indicador verde

### Cenário 2: Interrupção Temporária
1. Durante o procedimento, clique em **"Pausar"**
2. O cronômetro para mas mantém o tempo
3. Status muda para "Pausado" com indicador laranja
4. Para continuar, clique em **"Continuar"**

### Cenário 3: Finalização
1. Ao fim do procedimento, clique em **"Parar"**
2. Um diálogo mostra o tempo total
3. Opções:
   - **"Manter Tempo"**: Mantém para referência
   - **"Resetar"**: Zera o cronômetro

### Cenário 4: Salvar e Reabrir
1. Clique no botão **"Salvar"** no AppBar
2. O estado atual do cronômetro é salvo automaticamente
3. Ao reabrir a ficha:
   - O tempo é restaurado
   - Se estava rodando, continua automaticamente
   - Se estava pausado, fica pausado

## 🎨 Estados Visuais

### Estado Inicial (Não Iniciado)
```
┌──────────────────────────────────────┐
│  ⏱️  Tempo de Procedimento            │
│                                      │
│        [ 00:00:00 ]                  │
│                                      │
│         [Iniciar]                    │
└──────────────────────────────────────┘
```

### Estado Em Execução
```
┌──────────────────────────────────────┐
│  ⏱️  Tempo de Procedimento            │
│  (Card destacado em azul)            │
│        [ 01:25:36 ]                  │
│  (Display destacado com borda azul)  │
│     [Pausar]  [Parar]                │
│                                      │
│  🟢 Em andamento                      │
└──────────────────────────────────────┘
```

### Estado Pausado
```
┌──────────────────────────────────────┐
│  ⏱️  Tempo de Procedimento            │
│                                      │
│        [ 01:25:36 ]                  │
│                                      │
│   [Continuar]  [Parar]               │
│                                      │
│  🟠 Pausado                           │
└──────────────────────────────────────┘
```

## 🔗 Integrações Futuras

### Planejadas
1. **Gráficos de Monitorização**
   - Usar `elapsedTime` como eixo X dos gráficos
   - Mostrar eventos sincronizados com o tempo

2. **Horários de Medicamentos**
   - Associar aplicações ao tempo decorrido (ex: "15:30" do procedimento)
   - Alertas baseados em tempo decorrido

3. **Relatórios**
   - Incluir tempo total no PDF
   - Timeline de eventos com timestamps relativos

4. **Alertas Automáticos**
   - Notificações a cada X minutos
   - Lembrete de monitorização a cada 5 minutos

## 🐛 Tratamento de Erros

### Situações Cobertas
1. ✅ Timer cancelado corretamente ao dispose do widget
2. ✅ Estado salvo mesmo se houver erro na persistência
3. ✅ Valores padrão seguros (0 segundos, não rodando)
4. ✅ Validação de estado nulo antes de atualizar

### Situações a Monitorar
- ⚠️ Mudança de aba não afeta o timer (continua rodando)
- ⚠️ Timer continua mesmo se o app for minimizado
- ℹ️ Ao fechar a ficha sem salvar, o tempo é perdido

## 📊 Exemplo de Dados Salvos

```json
{
  "paciente": { ... },
  "preAnestesica": [ ... ],
  "procedureTimeSeconds": 5136,
  "timerWasRunning": false,
  "parametros": [ ... ]
}
```
**Interpretação**: Procedimento de 1h 25min 36s, estava pausado ao salvar.

## 🎓 Boas Práticas

### Para Veterinários
1. ✅ **Inicie o timer assim que aplicar a MPA ou indução**
2. ✅ **Pause durante transferências de sala/posicionamento**
3. ✅ **Pare ao fim da recuperação anestésica**
4. ✅ **Salve a ficha regularmente** (o tempo é salvo junto)

### Para Desenvolvedores
1. ✅ Use `_timerKey.currentState` para acessar o widget
2. ✅ Sempre verifique `!= null` antes de usar o state
3. ✅ Chame `updateTimerState()` antes de `saveCurrent()`
4. ✅ Timer usa `Timer.periodic` - não esqueça de cancelar

## 🚀 Melhorias Futuras

- [ ] Lap times para marcar eventos importantes
- [ ] Gráfico de linha do tempo com eventos
- [ ] Export do tempo para análise estatística
- [ ] Comparação de tempos entre procedimentos
- [ ] Alertas sonoros configuráveis
- [ ] Integração com notificações do sistema

## 📞 Suporte

Para questões técnicas sobre o cronômetro:
- Consulte o código em `widgets/procedure_timer_widget.dart`
- Veja exemplos de uso em `ficha_anestesica_page.dart`
- Estado persistido em `models/ficha_anestesica.dart`

---

**Versão**: 1.0.0  
**Data**: Outubro 2025  
**Status**: ✅ Implementado e Testado
