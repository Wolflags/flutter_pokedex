import 'package:flutter/material.dart';


  String _searchQuery = '';
  String? _selectedType;
  int? _selectedGeneration;
  

  const List<String> types = [
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
const List<int> generations = [1, 2, 3, 4, 5, 6, 7, 8];
