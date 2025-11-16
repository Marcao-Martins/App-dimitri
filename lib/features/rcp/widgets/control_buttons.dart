import 'package:flutter/material.dart';

/// Controles do RCP Coach
/// Botões de play/pause, reset e wake lock
class ControlButtons extends StatelessWidget {
  final bool isRunning;
  final bool isWakeLockEnabled;
  final VoidCallback onStartStop;
  final VoidCallback onReset;
  final VoidCallback onToggleWakeLock;

  const ControlButtons({
    super.key,
    required this.isRunning,
    required this.isWakeLockEnabled,
    required this.onStartStop,
    required this.onReset,
    required this.onToggleWakeLock,
  });

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder para ajustar largura dos botões em telas pequenas
    return LayoutBuilder(
      builder: (context, constraints) {
        // largura máxima relativa (até 180px)
        double maxMainWidth = constraints.maxWidth * 0.9;
        if (maxMainWidth > 180) maxMainWidth = 180;

        return Column(
          children: [
            // Botão principal (Play/Pause)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botão grande de iniciar/pausar (responsivo)
                SizedBox(
                  width: maxMainWidth,
                  height: 64,
                  child: ElevatedButton.icon(
                    onPressed: onStartStop,
                    icon: Icon(
                      isRunning ? Icons.pause : Icons.play_arrow,
                      size: 32,
                    ),
                    // FittedBox para evitar overflow do texto em telas muito estreitas
                    label: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isRunning ? 'PAUSAR' : 'INICIAR',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning
                          ? Colors.orange
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Botões secundários (Reset e Wake Lock)
            // Usa Wrap para permitir quebra/empacotamento em telas estreitas (mobile)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                // Botão Wake Lock (Tela Sempre Ligada)
                _SecondaryButton(
                  icon: Icons.screen_lock_portrait,
                  label: isWakeLockEnabled ? 'Tela Ativa' : 'Tela Normal',
                  onPressed: onToggleWakeLock,
                  color: isWakeLockEnabled ? Colors.orange : Colors.grey,
                ),

                // Botão Reset
                _SecondaryButton(
                  icon: Icons.restart_alt,
                  label: 'Reiniciar',
                  onPressed: onReset,
                  color: Colors.grey,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Botão secundário estilizado
class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 24),
      // Limitar largura do label e usar FittedBox para evitar overflow
      label: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 140),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
