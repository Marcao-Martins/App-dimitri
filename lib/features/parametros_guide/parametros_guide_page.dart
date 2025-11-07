import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'parametros_controller.dart';
import 'widgets/parametro_card.dart';
import 'widgets/species_filter.dart';

class ParametrosGuidePage extends StatelessWidget {
  const ParametrosGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParametrosController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('GUIA DE PARÂMETROS'),
          elevation: 0,
          actions: [
            Consumer<ParametrosController>(
              builder: (context, controller, _) => IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Recarregar CSV',
                onPressed: controller.isLoading ? null : () => controller.refresh(),
              ),
            ),
          ],
        ),
        body: Consumer<ParametrosController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Carregando parâmetros do CSV...'),
                  ],
                ),
              );
            }

            if (controller.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 56, color: Theme.of(context).colorScheme.error),
                      const SizedBox(height: 12),
                      Text(
                        'Falha ao carregar parâmetros',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => controller.refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                // Header com informações
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parâmetros Fisiológicos Veterinários',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Valores de referência para monitoramento anestésico',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Buscar parâmetro',
                      hintText: 'Ex: Frequência cardíaca, Pressão arterial...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) => controller.setSearchTerm(value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selecione a espécie:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      SpeciesFilter(
                        selectedSpecies: controller.selectedSpecies,
                        onSpeciesChanged: (species) =>
                            controller.setSelectedSpecies(species),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${controller.filteredParametros.length} parâmetros encontrados',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: controller.filteredParametros.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhum parâmetro encontrado',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tente buscar por outro termo',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: controller.filteredParametros.length,
                          itemBuilder: (context, index) {
                            final parametro = controller.filteredParametros[index];
                            return ParametroCard(
                              parametro: parametro,
                              selectedSpecies: controller.selectedSpecies,
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
