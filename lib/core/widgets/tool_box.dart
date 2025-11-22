import 'package:flutter/material.dart';
 
/// Componente reutilizável que encapsula um bloco (box) visual para ferramentas.
/// - `title`: título principal
/// - `subtitle`: texto secundário (opcional)
/// - `icon`: ícone representativo
/// - `color`: cor base do box (usada em gradiente)
/// - `child`: conteúdo interno (opcional)
class ToolBox extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final List<Color>? gradientColors;
  final Widget? child;
  final double borderRadius;

  const ToolBox({
    Key? key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    this.gradientColors,
    this.child,
    this.borderRadius = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors ?? [color, color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: (gradientColors != null && gradientColors!.isNotEmpty)
                ? gradientColors!.first.withOpacity(0.18)
                : color.withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (child != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: child,
            ),
          ],
        ],
      ),
    );
  }
}
