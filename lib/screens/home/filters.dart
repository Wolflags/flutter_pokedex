import 'package:flutter/material.dart';

class Filters extends StatefulWidget {
  final Function(String, String?, int?) onFiltersChanged;

  const Filters({super.key, required this.onFiltersChanged});

  @override
  _FiltersState createState() => _FiltersState();
}

class _FiltersState extends State<Filters> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedType;
  int? _selectedGeneration;

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

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
    widget.onFiltersChanged(_searchQuery, _selectedType, _selectedGeneration);
  }

  void _onTypeChanged(String? newValue) {
    setState(() {
      _selectedType = newValue;
    });
    widget.onFiltersChanged(_searchQuery, _selectedType, _selectedGeneration);
  }

  void _onGenerationChanged(int? newValue) {
    setState(() {
      _selectedGeneration = newValue;
    });
    widget.onFiltersChanged(_searchQuery, _selectedType, _selectedGeneration);
  }

  void _onClearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedType = null;
      _selectedGeneration = null;
      _searchController.clear();
    });
    widget.onFiltersChanged(_searchQuery, _selectedType, _selectedGeneration);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
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
              value: _selectedType,
              items: types.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: _onTypeChanged,
            ),
            DropdownButton<int>(
              hint: const Text('Generación'),
              value: _selectedGeneration,
              items: generations.map((int generation) {
                return DropdownMenuItem<int>(
                  value: generation,
                  child: Text('Gen $generation'),
                );
              }).toList(),
              onChanged: _onGenerationChanged,
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _onClearFilters,
            ),
          ],
        ),
      ],
    );
  }
}