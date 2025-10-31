import 'package:flutter/material.dart';
import 'dart:math';

/// Timer circular animado com display MM:SS
/// Mostra progresso visual do ciclo de RCP (2 minutos)
class CircularTimer extends StatelessWidget {
  final double progress;
  final int secondsRemaining;

  const CircularTimer({
    super.key,
    required this.progress,
    required this.secondsRemaining,
  });

  /// Formata tempo em MM:SS com padding
  String get _formattedTime {
    final minutes = (secondsRemaining / 60).floor().toString().padLeft(2, '0');
    final seconds = (secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;
          return CustomPaint(
            painter: _CircularTimerPainter(
              progress: progress,
              color: _getColorForProgress(context),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Timer display com font monospace
                  Text(
                    _formattedTime,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: size * 0.15, // Responsive
                          fontFeatures: const [
                            FontFeature.tabularFigures(), // Números tabulares
                          ],
                          letterSpacing: 4,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Label secundário
                  Text(
                    secondsRemaining > 0 ? 'restante' : 'Ciclo completo!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: size * 0.04,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Retorna cor vermelha para o timer (conforme solicitado)
  Color _getColorForProgress(BuildContext context) {
    // Timer sempre vermelho
    return Colors.red;
  }
}

/// CustomPainter para desenhar o timer circular
class _CircularTimerPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularTimerPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8; // Margem interna
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Background circle (cinza claro)
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc (colorido)
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    
    // Desenha de -90° (topo) no sentido horário
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );

    // Adiciona glow effect se estiver próximo do fim
    if (progress > 0.85) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 24
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * progress,
        false,
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CircularTimerPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
