import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/colors/type_color.dart';

class FilterSection extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final List<String> selectedTypes;
  final List<int> selectedGenerations;
  final Function(String) onTypeToggle;
  final Function(int) onGenerationToggle;
  final VoidCallback onClearFilters;
  final List<String> types;
  final List<int> generations;

  const FilterSection({
    Key? key,
    required this.searchController,
    required this.onSearchChanged,
    required this.selectedTypes,
    required this.selectedGenerations,
    required this.onTypeToggle,
    required this.onGenerationToggle,
    required this.onClearFilters,
    required this.types,
    required this.generations,
  }) : super(key: key);

  void _showFilterModal(BuildContext context, bool isTypeFilter) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isTypeFilter ? 'Tipos' : 'Generaciones',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: isTypeFilter
                            ? types.map((type) {
                                final isSelected = selectedTypes.contains(type);
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: FilterChip(
                                    selected: isSelected,
                                    label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: SvgPicture.asset(
                                            'assets/icons/$type.svg',
                                            colorFilter: ColorFilter.mode(
                                              isSelected ? Colors.white : getTypeColor(type),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          type.toUpperCase(),
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.transparent,
                                    selectedColor: getTypeColor(type),
                                    checkmarkColor: Colors.white,
                                    side: BorderSide(color: getTypeColor(type)),
                                    onSelected: (_) {
                                      onTypeToggle(type);
                                      setModalState(() {}); // Actualiza el estado del modal
                                    },
                                  ),
                                );
                              }).toList()
                            : generations.map((gen) {
                                final isSelected = selectedGenerations.contains(gen);
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: FilterChip(
                                    selected: isSelected,
                                    label: Text(
                                      'Gen $gen',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    backgroundColor: Colors.transparent,
                                    selectedColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                    onSelected: (_) {
                                      onGenerationToggle(gen);
                                      setModalState(() {}); // Actualiza el estado del modal
                                    },
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Buscar Pokémon',
              prefixIcon: const Icon(Icons.search, color: Colors.red),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        searchController.clear();
                        onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),

        // Filter buttons and active filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showFilterModal(context, true),
                  icon: const Icon(Icons.catching_pokemon, size: 20),
                  label: Text('Tipos (${selectedTypes.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showFilterModal(context, false),
                  icon: const Icon(Icons.numbers, size: 20),
                  label: Text('Gen (${selectedGenerations.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              if (selectedTypes.isNotEmpty || selectedGenerations.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.filter_list_off),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}