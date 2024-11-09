import 'package:flutter/material.dart';

Color getTypeColor(String type) {
  switch (type) {
    case 'bug':
      return Color(0xFF92BC2C);
    case 'dark':
      return Color(0xFF595761);
    case 'dragon':
      return Color(0xFF0C69C8);
    case 'electric':
      return Color(0xFFF2D94E);
    case 'fire':
      return Color(0xFFFBA54C);
    case 'fairy':
      return Color(0xFFEE90E6);
    case 'fighting':
      return Color(0xFFD3425F);
    case 'flying':
      return Color(0xFFA1BBEC);
    case 'ghost':
      return Color(0xFF5F6DBC);
    case 'grass':
      return Color(0xFF5FBD58);
    case 'ground':
      return Color(0xFFDA7C4D);
    case 'ice':
      return Color(0xFF75D0C1);
    case 'normal':
      return Color(0xFFA0A29F);
    case 'poison':
      return Color(0xFFB763CF);
    case 'psychic':
      return Color(0xFFFA8581);
    case 'rock':
      return Color(0xFFC9BB8A);
    case 'steel':
      return Color(0xFF5695A3);
    case 'water':
      return Color(0xFF539DDF);
    default:
      return Colors.grey;
  }
}