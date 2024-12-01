import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PokemonCacheService {
  static const Duration _cacheValidity = Duration(hours: 24);
  final SharedPreferences _prefs;

  PokemonCacheService(this._prefs);

  String _getPokemonKey(int pokemonId) => 'pokemon_detail_$pokemonId';
  String _getLastUpdateKey(int pokemonId) => 'last_update_detail_$pokemonId';

  Future<void> cachePokemonDetail(int pokemonId, Map<String, dynamic> pokemonData) async {
    final String pokemonJson = jsonEncode(pokemonData);
    await _prefs.setString(_getPokemonKey(pokemonId), pokemonJson);
    await _prefs.setInt(_getLastUpdateKey(pokemonId), DateTime.now().millisecondsSinceEpoch);
  }

  Map<String, dynamic>? getCachedPokemonDetail(int pokemonId) {
    final String? pokemonJson = _prefs.getString(_getPokemonKey(pokemonId));
    if (pokemonJson == null) return null;

    final int? lastUpdate = _prefs.getInt(_getLastUpdateKey(pokemonId));
    if (lastUpdate == null) return null;

    final DateTime lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    if (DateTime.now().difference(lastUpdateTime) > _cacheValidity) {
      // Cache expired
      return null;
    }

    return jsonDecode(pokemonJson) as Map<String, dynamic>;
  }

  Future<void> clearPokemonCache(int pokemonId) async {
    await _prefs.remove(_getPokemonKey(pokemonId));
    await _prefs.remove(_getLastUpdateKey(pokemonId));
  }
}