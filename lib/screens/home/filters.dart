import 'package:flutter/material.dart';

class Filters extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final String? selectedType;
  final Function(String?) onTypeChanged;
  final int? selectedGeneration;
  final Function(int?) onGenerationChanged;
  final Function onClearFilters;
  static const List<String> types = [
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  ];
  static const List<int> generations = [1, 2, 3, 4, 5, 6, 7, 8];

  const Filters({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedType,
    required this.onTypeChanged,
    required this.selectedGeneration,
    required this.onGenerationChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar Pokémon por nombre',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            DropdownButton<String>(
              hint: const Text('Tipo'),
              value: selectedType,
              items: types.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: onTypeChanged,
            ),
            DropdownButton<int>(
              hint: const Text('Generación'),
              value: selectedGeneration,
              items: generations.map((int generation) {
                return DropdownMenuItem<int>(
                  value: generation,
                  child: Text('Gen $generation'),
                );
              }).toList(),
              onChanged: onGenerationChanged,
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                onClearFilters();
              },
            ),
          ],
        ),
      ],
    );
  }
}