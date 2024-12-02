import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal() {
    loadFavorites();
  }

  List<int> favoritePokemonIds = [];

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favorites = prefs.getStringList('favorites');
    if (favorites != null) {
      favoritePokemonIds = favorites.map(int.parse).toList();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('favorites', favoritePokemonIds.map((id) => id.toString()).toList());
  }

  void addFavorite(int id) {
    if (!favoritePokemonIds.contains(id)) {
      favoritePokemonIds.add(id);
      _saveFavorites();
      notifyListeners();
    }
  }

  void removeFavorite(int id) {
    if (favoritePokemonIds.remove(id)) {
      _saveFavorites();
      notifyListeners();
    }
  }

  bool isFavorite(int id) {
    return favoritePokemonIds.contains(id);
  }

  List<int> getFavorites() {
    return favoritePokemonIds;
  }
}