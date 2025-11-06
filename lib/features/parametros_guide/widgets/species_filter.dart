import 'package:flutter/material.dart';
import '../parametros_controller.dart';

class SpeciesFilter extends StatelessWidget {
  final Species selectedSpecies;
  final Function(Species) onSpeciesChanged;

  const SpeciesFilter({
    Key? key,
    required this.selectedSpecies,
    required this.onSpeciesChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Species>(
      segments: const <ButtonSegment<Species>>[
        ButtonSegment<Species>(
          value: Species.cao,
          label: Text('Cão'),
          icon: Icon(Icons.pets),
        ),
        ButtonSegment<Species>(
          value: Species.gato,
          label: Text('Gato'),
          icon: Icon(Icons.pets),
        ),
        ButtonSegment<Species>(
          value: Species.cavalo,
          label: Text('Cavalo'),
          icon: Icon(Icons.pets),
        ),
      ],
      selected: <Species>{selectedSpecies},
      onSelectionChanged: (Set<Species> newSelection) {
        onSpeciesChanged(newSelection.first);
      },
    );
  }
}
