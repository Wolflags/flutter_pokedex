import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/colors/type_color.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '/api/graphql_client.dart';
import '/queries/query.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _pokemonList = [];
  bool _isLoading = false;

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

  Future<void> _fetchMorePokemon() async {
  setState(() {
    _isLoading = true;
  });

  final GraphQLClient client = getGraphQLClient();

  final QueryOptions options = QueryOptions(
    document: gql(fetchPokemonsQuery),
    variables: {
      'limit': 20,
      'offset': _pokemonList.length,
    },
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    print(result.exception.toString());
    setState(() {
      _isLoading = false;
    });
    return;
  }

  final List fetchedPokemons = result.data?['pokemon_v2_pokemon'];

  setState(() {
    _pokemonList.addAll(fetchedPokemons);
    _isLoading = false;
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokedex'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              itemCount: _pokemonList.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
  if (index == _pokemonList.length && _isLoading) {
    return Center(child: CircularProgressIndicator());
  } else {
    final pokemon = _pokemonList[index];
    final String name = pokemon['name'];
    final int id = pokemon['id'];
    final types = pokemon['pokemon_v2_pokemontypes'];

    final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '#$id',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: types.map<Widget>((typeInfo) {
                final typeName = typeInfo['pokemon_v2_type']['name'];
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
                          color: getTypeColor(typeName).withOpacity(0.5),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: SvgPicture.asset(
                        'assets/icons/$typeName.svg',
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
},

            ),
          ),
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
