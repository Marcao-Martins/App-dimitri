import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ficha_provider.dart';

/// Widget de cronômetro para controle do tempo de procedimento anestésico.
/// 
/// O timer é gerenciado pelo FichaProvider para garantir que continue
/// rodando independentemente da navegação entre abas.
class ProcedureTimerWidget extends StatelessWidget {
  const ProcedureTimerWidget({super.key});

  void _showStopDialog(BuildContext context, FichaProvider provider) {
    final duration = Duration(seconds: provider.procedureTimeSeconds);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar Procedimento'),
        content: Text(
          'Tempo total: ${_formatDuration(duration)}\n\n'
          'Deseja resetar o cronômetro?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Manter Tempo'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.resetTimer();
            },
            child: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FichaProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    
    final isRunning = provider.isTimerRunning;
    final hasStarted = provider.hasTimerStarted;
    final elapsedTime = Duration(seconds: provider.procedureTimeSeconds);

    return Card(
      elevation: isRunning ? 4 : 1,
      color: isRunning 
          ? colorScheme.primaryContainer 
          : colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Título
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRunning ? Icons.timer : Icons.timer_outlined,
                  color: isRunning 
                      ? colorScheme.primary 
                      : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tempo de Procedimento',
                  style: textTheme.titleSmall?.copyWith(
                    color: isRunning 
                        ? colorScheme.onPrimaryContainer 
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Display do cronômetro
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isRunning 
                    ? Colors.white
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isRunning 
                      ? colorScheme.primary 
                      : colorScheme.outline.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _formatDuration(elapsedTime),
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFeatures: [const FontFeature.tabularFigures()],
                    color: isRunning 
                        ? colorScheme.primary 
                        : colorScheme.onSurfaceVariant,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Botões de controle
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (!hasStarted)
                  FilledButton.icon(
                    onPressed: () => provider.startTimer(),
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text('Iniciar'),
                  ),
                
                if (hasStarted && !isRunning)
                  FilledButton.tonalIcon(
                    onPressed: () => provider.startTimer(),
                    icon: const Icon(Icons.play_arrow, size: 20),
                    label: const Text('Continuar'),
                  ),
                
                if (isRunning)
                  FilledButton.tonalIcon(
                    onPressed: () => provider.pauseTimer(),
                    icon: const Icon(Icons.pause, size: 20),
                    label: const Text('Pausar'),
                  ),
                
                if (hasStarted)
                  OutlinedButton.icon(
                    onPressed: () {
                      provider.stopTimer();
                      _showStopDialog(context, provider);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error),
                    ),
                    icon: const Icon(Icons.stop, size: 20),
                    label: const Text('Parar'),
                  ),
              ],
            ),
            
            // Indicador de status
            if (hasStarted) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRunning ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isRunning ? 'Em andamento' : 'Pausado',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
