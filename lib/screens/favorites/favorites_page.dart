// favorites_page.dart
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import '/services/favorites_service.dart';
import '/queries/query.dart';
import '/api/graphql_client.dart';
import '../details/pokemon_detail_page.dart';
import 'package:flutter_pokedex/screens/home/buildTypes.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<int> favoriteIds = [];
  final List<dynamic> _pokemonFavoritesList = [];
  bool _isLoading = false;
  final GraphQLClient client = getGraphQLClient();

  @override
  void initState() {
    super.initState();
    favoriteIds = Provider.of<FavoritesService>(context, listen: false).getFavorites();
    print(favoriteIds);
    _fetchFavoritePokemons();

    // Escuchar cambios
    Provider.of<FavoritesService>(context, listen: false).addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    Provider.of<FavoritesService>(context, listen: false).removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    setState(() {
      favoriteIds = Provider.of<FavoritesService>(context, listen: false).getFavorites();
    });
    _fetchFavoritePokemons();
  }

  Future<void> _fetchFavoritePokemons() async {
    if (favoriteIds.isEmpty) {
      setState(() {
        _pokemonFavoritesList.clear();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic> where = {
      'id': {'_in': favoriteIds},
      'pokemon_v2_pokemonforms': {'is_default': {'_eq': true}}
    };

    try {
      final QueryOptions options = QueryOptions(
        document: gql(fetchPokemonsQuery),
        variables: {
          'limit': favoriteIds.length,
          'offset': 0,
          'where': where,
          'order_by': [
            {'id': 'asc'}
          ],
        },
      );

      final QueryResult result = await client.query(options);

      if (result.hasException) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final List fetchedPokemons = result.data?['pokemon_v2_pokemon'];

      setState(() {
        _pokemonFavoritesList.clear();
        _pokemonFavoritesList.addAll(fetchedPokemons);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokémon Favoritos'),
      ),
      body: IndexedStack(
        index: 0,
        children: [
          Column(
            children: [
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: _pokemonFavoritesList.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _pokemonFavoritesList.length && _isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (index < _pokemonFavoritesList.length) {
                      final pokemon = _pokemonFavoritesList[index];
                      final String name = pokemon['name'];
                      final int id = pokemon['id'];
                      final types = pokemon['pokemon_v2_pokemontypes'];

                      var imageUrl =
                          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PokemonDetailPage(pokemonId: id),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Hero(
                                  tag: 'pokemon-image-$id',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(10)),
                                      image: DecorationImage(
                                        image: NetworkImage(imageUrl),
                                        fit: BoxFit.fitHeight,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${name[0].toUpperCase()}${name.substring(1)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      '#$id',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Row(
                                  children: types.map<Widget>((typeInfo) {
                                    return buildTypeWidget(
                                        typeInfo as Map<String, dynamic>);
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}