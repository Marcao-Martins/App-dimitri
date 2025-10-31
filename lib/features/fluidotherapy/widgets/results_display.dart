import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/fluid_calculation.dart';

/// Widget para exibir os resultados do cálculo de fluidoterapia
class ResultsDisplay extends StatelessWidget {
  final FluidCalculation calculation;

  const ResultsDisplay({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryTeal.withValues(alpha: 0.1),
              AppColors.categoryBlue.withValues(alpha: 0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.water_drop,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resultado da Fluidoterapia',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryTeal,
                            ),
                      ),
                      Text(
                        '${calculation.species} • ${calculation.weight.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            
            // Resultados
            _buildResultRow(
              context,
              icon: Icons.local_hospital,
              label: 'Taxa de infusão',
              value: '${calculation.infusionRateMlPerHour.toStringAsFixed(1)} mL/h',
              iconColor: AppColors.categoryOrange,
            ),
            
            const SizedBox(height: 12),
            
            _buildResultRow(
              context,
              icon: Icons.opacity,
              label: 'Gotas por minuto',
              value: '${calculation.dropsPerMinute.toStringAsFixed(0)} gotas/min',
              iconColor: AppColors.categoryBlue,
              subtitle: 'Macrogotas (20 gotas/mL)',
            ),
            
            const SizedBox(height: 12),
            
            _buildResultRow(
              context,
              icon: Icons.timer,
              label: 'Intervalo entre gotas',
              value: '${calculation.secondsBetweenDrops.toStringAsFixed(1)} segundos',
              iconColor: AppColors.categoryPurple,
            ),
            
            const SizedBox(height: 12),
            
            _buildResultRow(
              context,
              icon: Icons.water,
              label: 'Volume diário total',
              value: '${calculation.totalDailyVolume.toStringAsFixed(1)} mL/dia',
              iconColor: AppColors.categoryGreen,
            ),
            
            // Detalhes adicionais se houver desidratação
            if (calculation.hasDehydration) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Detalhes da Reidratação',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Desidratação: ${calculation.dehydrationPercent?.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Volume de reidratação: ${calculation.rehydrationVolume?.toStringAsFixed(1)} mL',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Tempo: ${calculation.rehydrationTime}h',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      'Manutenção: ${calculation.maintenanceVolume.toStringAsFixed(1)} mL/dia',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                ),
            ],
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
      ],
    );
  }
}
