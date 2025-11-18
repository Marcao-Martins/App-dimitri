import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ficha_provider.dart';

/// Widget de Alerta de Monitorização Programável
/// Emite alertas sonoros em intervalos regulares para lembrar da monitorização
class MonitoringAlarmWidget extends StatefulWidget {
  const MonitoringAlarmWidget({super.key});

  @override
  State<MonitoringAlarmWidget> createState() => _MonitoringAlarmWidgetState();
}

class _MonitoringAlarmWidgetState extends State<MonitoringAlarmWidget> {
  // Opções de intervalo disponíveis
  static const List<int> _intervalosDisponiveis = [1, 2, 3, 5, 10, 15, 30];

  @override
  void initState() {
    super.initState();
    // Configura callback para mostrar notificação quando alarme tocar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<FichaProvider>(context, listen: false);
      provider.setAlarmeCallback(() {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  const SizedBox(width: 12),
                  const Text('Lembrete: Adicionar dados de monitorização'),
                ],
              ),
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    });
  }

  /// Mostra diálogo de configuração
  void _mostrarConfiguracao(BuildContext context, FichaProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings),
            SizedBox(width: 8),
            Text('Configurar Alerta'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Intervalo de Alerta:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _intervalosDisponiveis.map((intervalo) {
                final selecionado = intervalo == provider.intervaloMinutos;
                return ChoiceChip(
                  label: Text('$intervalo min'),
                  selected: selecionado,
                  onSelected: (selected) {
                    provider.setIntervaloAlarme(intervalo);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              'O alarme tocará a cada ${provider.intervaloMinutos} minutos para lembrar de adicionar dados de monitorização.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FichaProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ícone de sino
                Icon(
                  provider.alarmeAtivo ? Icons.notifications_active : Icons.notifications_outlined,
                  color: provider.alarmeAtivo 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                  size: 20,
                ),
                const SizedBox(width: 8),
                
                // Switch liga/desliga
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: provider.alarmeAtivo,
                    onChanged: (value) {
                      if (value) {
                        provider.iniciarAlarme();
                        // Mostrar snackbar de confirmação
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  color: Theme.of(context).colorScheme.onInverseSurface,
                                ),
                                const SizedBox(width: 12),
                                Text('Alarme ativado (${provider.intervaloMinutos} min)'),
                              ],
                            ),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        provider.pararAlarme();
                      }
                    },
                  ),
                ),
                
                // Tempo restante (se ativo)
                if (provider.alarmeAtivo) ...[
                  const SizedBox(width: 4),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Text(
                        provider.getTempoRestanteAlarme(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
                
                // Botão de configuração
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  onPressed: () => _mostrarConfiguracao(context, provider),
                  tooltip: 'Configurar intervalo',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                
                const SizedBox(width: 4),
                
                // Texto do intervalo
                Text(
                  '${provider.intervaloMinutos}min',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
