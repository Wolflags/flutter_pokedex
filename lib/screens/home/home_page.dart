import 'package:flutter/material.dart';
import 'package:flutter_pokedex/screens/home/buildTypes.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '/api/graphql_client.dart';
import '/queries/query.dart';
import '../details/pokemon_detail_page.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'filter_section.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../favorites/favorites_page.dart';

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
  int _selectedIndex = 0;
  String _currentSorting = 'id';

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _selectedTypes = [];
  List<int> _selectedGenerations = [];
  final List<String> _types = [
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy',
  ];
  final List<int> _generations = [1, 2, 3, 4, 5, 6, 7, 8, 9];

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

    Map<String, dynamic> where = {
      'pokemon_v2_pokemonforms': {'is_default': {'_eq': true}}
    };

    if (_searchQuery.isNotEmpty) {
      final isNumeric = int.tryParse(_searchQuery) != null;
      
      where = {
        '_or': [
          {'name': {'_ilike': '%$_searchQuery%'}},
          if (isNumeric) {'id': {'_eq': int.parse(_searchQuery)}}
        ],
        'pokemon_v2_pokemonforms': {'is_default': {'_eq': true}}
      };
    }

    if (_selectedGenerations.isNotEmpty) {
      where['pokemon_v2_pokemonspecy'] = {
        'generation_id': {'_in': _selectedGenerations}
      };
    }

    if (_selectedTypes.isNotEmpty) {
      where['pokemon_v2_pokemontypes'] = {
        'pokemon_v2_type': {
          'name': {'_in': _selectedTypes}
        }
      };
    }

    try {
      final QueryOptions options = QueryOptions(
        document: gql(fetchPokemonsQuery),
        variables: {
          'limit': 20,
          'offset': _pokemonList.length,
          'where': where,
          'order_by': [
            {_currentSorting: 'asc'}
          ],
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
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isFetching = false;
      });
    }
  }

  void _toggleType(String type) {
    setState(() {
      if (_selectedTypes.contains(type)) {
        _selectedTypes.remove(type);
      } else {
        _selectedTypes.add(type);
      }
      _hasNextPage = true;
    });
    _fetchMorePokemon(reset: true);
  }

  void _toggleGeneration(int generation) {
    setState(() {
      if (_selectedGenerations.contains(generation)) {
        _selectedGenerations.remove(generation);
      } else {
        _selectedGenerations.add(generation);
      }
      _hasNextPage = true;
    });
    _fetchMorePokemon(reset: true);
  }

  void _clearFilters() {
    setState(() {
      _selectedTypes = [];
      _selectedGenerations = [];
      _searchQuery = '';
      _searchController.clear();
      _hasNextPage = true;
    });
    _fetchMorePokemon(reset: true);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _hasNextPage = true;
      _pokemonList.clear();
      _fetchMorePokemon(reset: true);
    });
  }

  void _changeSorting(String sorting) {
    setState(() {
      _currentSorting = sorting;
      _hasNextPage = true;
    });
    _fetchMorePokemon(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text(
                'Pokedéx',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white,
                  fontFamily: 'PokemonSolid',
                  letterSpacing: 3.0,
                ),
              ),
              backgroundColor: Colors.red,
              centerTitle: true,
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          Column(
            children: [
              FilterSection(
                searchController: _searchController,
                onSearchChanged: (value) {
                  _searchQuery = value.toLowerCase();
                  _hasNextPage = true;
                  _fetchMorePokemon(reset: true);
                },
                selectedTypes: _selectedTypes,
                selectedGenerations: _selectedGenerations,
                onTypeToggle: _toggleType,
                onGenerationToggle: _toggleGeneration,
                onClearFilters: _clearFilters,
                types: _types,
                generations: _generations,
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

                      var imageUrl =
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
                                        fit: BoxFit.fitHeight,
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
          FavoritesPage(),
        ],
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.textIn,
        backgroundColor: Colors.red,
        items: const [
          TabItem(icon: Icons.list, title: 'Pokémons'),
          TabItem(icon: Icons.favorite, title: 'Favorites'),
        ],
        initialActiveIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.sort,
        iconTheme: const IconThemeData(color: Colors.white),
        activeIcon: Icons.close,
        backgroundColor: Colors.red,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.tag, color: Colors.white),
            backgroundColor: Colors.redAccent,
            label: 'Ordenar por Numero',
            onTap: () => _changeSorting('id'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.sort_by_alpha, color: Colors.white),
            backgroundColor: Colors.redAccent,
            label: 'Ordenar por Nombre',
            onTap: () => _changeSorting('name'),
          ),
        ],
      ),
    );
  }
}
