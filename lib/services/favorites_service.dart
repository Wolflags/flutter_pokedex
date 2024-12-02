import 'package:flutter/foundation.dart';

class FavoritesService extends ChangeNotifier {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  List<int> favoritePokemonIds = [];

  void addFavorite(int id) {
    if (!favoritePokemonIds.contains(id)) {
      favoritePokemonIds.add(id);
      notifyListeners();
    }
  }

  void removeFavorite(int id) {
    if (favoritePokemonIds.remove(id)) {
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