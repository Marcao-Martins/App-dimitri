import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'rcp_controller.dart';
import 'widgets/circular_timer.dart';
import 'widgets/control_buttons.dart';

/// Página principal do RCP Coach
/// Timer de 2 minutos com metrônomo para compressões torácicas
class RcpPage extends StatefulWidget {
  const RcpPage({super.key});

  @override
  State<RcpPage> createState() => _RcpPageState();
}

class _RcpPageState extends State<RcpPage> {
  late final RcpController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RcpController();
  }

  @override
  void deactivate() {
    // Quando a página deixa de estar ativa (navegação para outra aba/rota), pausar
    _controller.pauseTimer();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RCP'),
          actions: [
            // Botão de informação sobre uso
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(context),
              tooltip: 'Como usar',
            ),
          ],
        ),
        body: Consumer<RcpController>(
          builder: (context, controller, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      minWidth: constraints.maxWidth,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 8),
                        
                        // Responsivo: exibe em linha quando houver espaço, empilha em coluna em telas estreitas
                        LayoutBuilder(builder: (context, constraints) {
                          if (constraints.maxWidth < 420) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildDrugTable(context),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Chip(
                                    label: Text(
                                      'Ciclo: ${controller.cycleCount}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    avatar: Icon(
                                      Icons.sync,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primaryContainer,
                                    padding: const EdgeInsets.all(12),
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tabela de Fármacos (esquerda/centro)
                                Expanded(
                                  child: _buildDrugTable(context),
                                ),
                                const SizedBox(width: 8),
                                // Cycle Counter Badge (direita)
                                Chip(
                                  label: Text(
                                    'Ciclo: ${controller.cycleCount}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  avatar: Icon(
                                    Icons.sync,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primaryContainer,
                                  padding: const EdgeInsets.all(12),
                                ),
                              ],
                            );
                          }
                        }),
            
                        const SizedBox(height: 16),
            
                        // Status Message
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: controller.isRunning
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                controller.isRunning
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: controller.isRunning
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  controller.statusMessage,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                        color: controller.isRunning
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
            
                        const SizedBox(height: 32),
            
                        // Circular Timer - Removido o Expanded, agora usa ConstrainedBox
                        SizedBox(
                          height: MediaQuery.of(context).size.width * 0.6,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: CircularTimer(
                            progress: controller.progress,
                            secondsRemaining: controller.secondsRemaining,
                          ),
                        ),
            
                        const SizedBox(height: 32),
            
                        // Control Buttons
                        ControlButtons(
                          isRunning: controller.isRunning,
                          isWakeLockEnabled: controller.isWakeLockEnabled,
                          onStartStop: _onStartStop,
                          onReset: _onReset,
                          onToggleWakeLock: _onToggleWakeLock,
                        ),
            
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Constrói tabela discreta de fármacos
  Widget _buildDrugTable(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha((0.5 * 255).round()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha((0.2 * 255).round()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Fármacos',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          // Peso do animal + volumes calculados
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    // Peso (entrada) - tornar responsivo em telas estreitas
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double fieldWidth = constraints.maxWidth < 360
                            ? constraints.maxWidth
                            : 160;
                        return SizedBox(
                          width: fieldWidth,
                          child: TextField(
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Peso (kg)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              isDense: true,
                              suffixText: 'kg',
                            ),
                            onChanged: (v) {
                              // Update controller weight
                              final controller =
                                  Provider.of<RcpController>(context, listen: false);
                              controller.setWeightFromString(v);
                            },
                          ),
                        );
                      },
                    ),
              const SizedBox(width: 12),
              // Volumes calculados
              Expanded(
                child: Consumer<RcpController>(
                  builder: (context, controller, child) {
                    final atv = controller.atropineVolumeMl;
                    final adv = controller.adrenalineVolumeMl;
                    final lidv = controller.lidocaineVolumeMl;
                    String fmt(double v) => v <= 0
                        ? '-'
                        : v.toStringAsFixed(v < 1 ? 2 : 2);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.medication,
                              size: 14,
                              color: Theme.of(context)
                                    .colorScheme
                                      .onSurfaceVariant
                                      .withAlpha((0.7 * 255).round()),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Atropina (0,04mg/kg) - Volume: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontSize: 11),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${fmt(atv)} ml (Atropina 1%)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.medication,
                              size: 14,
                              color: Theme.of(context)
                                    .colorScheme
                                      .onSurfaceVariant
                                      .withAlpha((0.7 * 255).round()),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Adrenalina/Epinefrina (0,01mg/kg) - Volume: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontSize: 11),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${fmt(adv)} ml',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.medication,
                              size: 14,
                              color: Theme.of(context)
                                    .colorScheme
                                      .onSurfaceVariant
                                      .withAlpha((0.7 * 255).round()),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Lidocaína (2mg/kg) - Volume: ',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(fontSize: 11),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${fmt(lidv)} ml',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11, fontWeight: FontWeight.bold),
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mostra diálogo com instruções de uso
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info_outline),
            SizedBox(width: 8),
            Text('Como usar o RCP Coach'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🫀 Compressões Torácicas',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Realize 100-120 compressões por minuto'),
              Text('• Use o timer para controlar o tempo'),
              Text('• 30 compressões : 2 ventilações'),
              SizedBox(height: 16),
              Text(
                '⏱️ Timer de Ciclos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Cada ciclo dura 2 minutos'),
              Text('• Avalie o paciente a cada ciclo'),
              Text('• Contador automático de ciclos'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  // Wrappers para callbacks dos botões — adicionam logs e delegam ao controller
  void _onStartStop() {
    debugPrint('RCP Page: onStartStop pressed');
    _controller.startStop();
  }

  void _onReset() {
    debugPrint('RCP Page: onReset pressed');
    _controller.reset();
  }

  void _onToggleWakeLock() {
    debugPrint('RCP Page: onToggleWakeLock pressed');
    _controller.toggleWakeLock();
  }
}
