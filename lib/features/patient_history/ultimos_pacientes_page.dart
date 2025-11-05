import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ficha_anestesica/ficha_provider.dart';
import '../ficha_anestesica/models/ficha_anestesica.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';

class UltimosPacientesPage extends StatelessWidget {
  const UltimosPacientesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FichaProvider>(
      builder: (context, provider, _) {
        final fichas = provider.fichas;
        
        // Ordenar fichas por data (mais recentes primeiro)
        fichas.sort((a, b) {
          final dateA = a.paciente.data ?? DateTime(1900);
          final dateB = b.paciente.data ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });

        if (fichas.isEmpty) {
          return const Center(
            child: EmptyState(
              icon: Icons.pets,
              title: 'Nenhum paciente encontrado',
              message: 'Crie uma nova ficha anestésica para começar',
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fichas.length,
          itemBuilder: (context, index) {
            final ficha = fichas[index];
            return _buildPatientCard(context, ficha);
          },
        );
      },
    );
  }

  Widget _buildPatientCard(BuildContext context, FichaAnestesica ficha) {
    final theme = Theme.of(context);
    final status = ficha.timerWasRunning ? 'Em andamento' : 'Concluído';
    final statusColor = ficha.timerWasRunning ? AppColors.warning : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Carregar a ficha selecionada
          final provider = Provider.of<FichaProvider>(context, listen: false);
          provider.load(ficha, ficha.paciente.nome);
          
          // Navegar para a página da ficha
          Navigator.pushNamed(context, '/ficha');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com nome e status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ficha.paciente.nome,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Informações do paciente
              Row(
                children: [
                  Icon(
                    Icons.pets,
                    size: 16,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ficha.paciente.especie ?? 'Espécie não informada',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  if (ficha.paciente.peso != null) ...[
                    Text(
                      ' • ${ficha.paciente.peso} kg',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              
              // Data e procedimento
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16,
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    ficha.paciente.data != null
                        ? '${ficha.paciente.data!.day}/${ficha.paciente.data!.month}/${ficha.paciente.data!.year}'
                        : 'Data não informada',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                    ),
                  ),
                  if (ficha.paciente.procedimento != null) ...[
                    Text(
                      ' • ${ficha.paciente.procedimento}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}