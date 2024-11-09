// ignore: file_names
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/colors/type_color.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '/api/graphql_client.dart';
import '/queries/query.dart';
import '/screens/pokemon_detail_page.dart';
import '/screens/home/filters.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<dynamic> _pokemonList = [];
  bool _isLoading = false;
  bool _hasNextPage = true;
  bool _isFetching = false;

  final GraphQLClient client = getGraphQLClient();
  Map<String, dynamic> where = {};

  @override
  void initState() {
    super.initState();
    _fetchMorePokemon();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _fetchMorePokemon();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //Obtener pokemons
  Future<void> _fetchMorePokemon({bool reset = false}) async {
    if (_isFetching || !_hasNextPage) return;

    setState(() {
      _isLoading = true;
      _isFetching = true;
    });

    if (reset) {
      _pokemonList.clear();
      _hasNextPage = true;
    }

    final QueryOptions options = QueryOptions(
      document: gql(fetchPokemonsQuery),
      variables: {
        'limit': 20,
        'offset': _pokemonList.length,
        'where': where,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      setState(() {
        _isLoading = false;
        _isFetching = false;
      });
      return;
    }

    final List fetchedPokemons = result.data?['pokemon_v2_pokemon'];

    setState(() {
      _pokemonList.addAll(fetchedPokemons);
      _isLoading = false;
      _isFetching = false;
      if (fetchedPokemons.length < 20) {
        _hasNextPage = false;
      }
    });
  }

  //Manejo de filtros para pasar a la clase filters
  void _onFiltersChanged(String searchQuery, String? selectedType, int? selectedGeneration) {
    setState(() {
      where = {};
      if (searchQuery.isNotEmpty) {
        where['name'] = {'_ilike': '%$searchQuery%'};
      }
      if (selectedGeneration != null) {
        where['pokemon_v2_pokemonspecy'] = {
          'generation_id': {'_eq': selectedGeneration}
        };
      }
      if (selectedType != null) {
        where['pokemon_v2_pokemontypes'] = {
          'pokemon_v2_type': {
            'name': {'_eq': selectedType}
          }
        };
      }
      _fetchMorePokemon(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Filters(
            onFiltersChanged: _onFiltersChanged,
          ),
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: _pokemonList.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _pokemonList.length && _isLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (index < _pokemonList.length) {
                  final pokemon = _pokemonList[index];
                  final String name = pokemon['name'];
                  final int id = pokemon['id'];
                  final types = pokemon['pokemon_v2_pokemontypes'];

                  final imageUrl =
                      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              PokemonDetailPage(pokemonId: id),
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
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10)),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
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
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '#$id',
                                  style: const TextStyle(
                                    color: Colors.grey,
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
                                final typeName =
                                    typeInfo['pokemon_v2_type']['name'];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: getTypeColor(typeName),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: getTypeColor(typeName)
                                              .withOpacity(0.5),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: SvgPicture.asset(
                                        'assets/icons/$typeName.svg',
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
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
    );
  }
}
