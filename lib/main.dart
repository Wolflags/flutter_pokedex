// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_pokedex/screens/home/home_page.dart';
import '/services/favorites_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => FavoritesService(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}