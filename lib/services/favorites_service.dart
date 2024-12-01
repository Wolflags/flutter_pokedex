class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  List<int> favoritePokemonIds = [];

  void addFavorite(int id) {
    if (!favoritePokemonIds.contains(id)) {
      favoritePokemonIds.add(id);
    }
  }

  void removeFavorite(int id) {
    favoritePokemonIds.remove(id);
  }

  bool isFavorite(int id) {
    return favoritePokemonIds.contains(id);
  }

  List<int> getFavorites() {
    return favoritePokemonIds;
  }
}