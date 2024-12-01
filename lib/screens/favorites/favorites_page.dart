// favorites_page.dart
import 'package:flutter/material.dart';
import '/services/favorites_service.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<int> favoriteIds = [];

  @override
  void initState() {
    super.initState();
    favoriteIds = FavoritesService().getFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon Favoritos'),
      ),
      body: ListView.builder(
        itemCount: favoriteIds.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Pokémon ID: ${favoriteIds[index]}'),
          );
        },
      ),
    );
  }
}