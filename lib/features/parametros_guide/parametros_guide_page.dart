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
          title: const Text('Guia de Parâmetros'),
        ),
        body: Consumer<ParametrosController>(
          builder: (context, controller, child) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Buscar parâmetro',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => controller.setSearchTerm(value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SpeciesFilter(
                    selectedSpecies: controller.selectedSpecies,
                    onSpeciesChanged: (species) =>
                        controller.setSelectedSpecies(species),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
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
