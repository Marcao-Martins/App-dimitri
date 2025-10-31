import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'rcp_controller.dart';
import 'widgets/circular_timer.dart';
import 'widgets/control_buttons.dart';

/// Página principal do RCP Coach
/// Timer de 2 minutos com metrônomo para compressões torácicas
class RcpPage extends StatelessWidget {
  const RcpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RcpController(),
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
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Cycle Counter Badge
                  Align(
                    alignment: Alignment.topRight,
                    child: Chip(
                      label: Text(
                        'Ciclo: ${controller.cycleCount}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      avatar: Icon(
                        Icons.sync,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      padding: const EdgeInsets.all(12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Status Message
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: controller.isRunning 
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          controller.isRunning ? Icons.favorite : Icons.favorite_border,
                          color: controller.isRunning 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            controller.statusMessage,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: controller.isRunning
                                  ? Theme.of(context).colorScheme.onPrimaryContainer
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Circular Timer
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: CircularTimer(
                        progress: controller.progress,
                        secondsRemaining: controller.secondsRemaining,
                      ),
                    ),
                  ),

                  // Control Buttons
                  ControlButtons(
                    isRunning: controller.isRunning,
                    isMuted: controller.isMuted,
                    isWakeLockEnabled: controller.isWakeLockEnabled,
                    onStartStop: controller.startStop,
                    onReset: controller.reset,
                    onMute: controller.toggleMute,
                    onToggleWakeLock: controller.toggleWakeLock,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
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
              Text('• Metrônomo a 120 BPM (beep a cada 0.5s)'),
              Text('• Siga o ritmo para compressões efetivas'),
              Text('• 30 compressões : 2 ventilações'),
              SizedBox(height: 16),
              Text(
                '⏱️ Timer de Ciclos',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Cada ciclo dura 2 minutos'),
              Text('• Alerta sonoro ao final do ciclo'),
              Text('• Avalie paciente a cada ciclo'),
              SizedBox(height: 16),
              Text(
                '🔊 Controles de Áudio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text('• Use o ícone de volume para ativar/desativar'),
              Text('• Metrônomo ajuda a manter ritmo correto'),
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
}
