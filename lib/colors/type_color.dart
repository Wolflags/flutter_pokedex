import 'package:flutter/material.dart';

Color getTypeColor(String type) {
  switch (type) {
    case 'electric':
      return Color(0xFFF2D94E);
    case 'water':
      return Color(0xFF539DDF);
    case 'grass':
      return Color(0xFF5FBD58);
    // Add more types as needed
    default:
      return Colors.grey;
  }
}
