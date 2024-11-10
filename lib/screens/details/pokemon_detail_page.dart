import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '/api/graphql_client.dart';
import '/queries/query.dart';
import '/colors/type_color.dart';

class PokemonDetailPage extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailPage({super.key, required this.pokemonId});

  @override
  PokemonDetailPageState createState() => PokemonDetailPageState();
}

class PokemonDetailPageState extends State<PokemonDetailPage> {
  late Future<Map<String, dynamic>> _pokemonData;

  @override
  void initState() {
    super.initState();
    _pokemonData = _fetchPokemonDetail();
  }

  Future<Map<String, dynamic>> _fetchPokemonDetail() async {
    final GraphQLClient client = getGraphQLClient();

    final QueryOptions options = QueryOptions(
      document: gql(fetchPokemonDetailQuery),
      variables: {
        'id': widget.pokemonId,
      },
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final pokemon = result.data?['pokemon_v2_pokemon_by_pk'];

    return pokemon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Pokémon'),
        backgroundColor: Colors.red,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _pokemonData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar los datos'));
          }

          final pokemon = snapshot.data!;
          final String name = pokemon['name'];
          final int id = pokemon['id'];
          // final int height = pokemon['height'];
          // final int weight = pokemon['weight'];
          // final int baseExperience = pokemon['base_experience'];
          final types = pokemon['pokemon_v2_pokemontypes'];
          final stats = pokemon['pokemon_v2_pokemonstats'];
          final abilities = pokemon['pokemon_v2_pokemonabilities'];
          final moves = pokemon['pokemon_v2_pokemonmoves'];
          final evolutions = pokemon['pokemon_v2_pokemonspecy']
              ['pokemon_v2_evolutionchain']['pokemon_v2_pokemonspecies'];

          final imageUrl =
              'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Image.network(
                  imageUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text(
                  '${name[0].toUpperCase()}${name.substring(1)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '#$id',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                // Tipos
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: types.map<Widget>((typeInfo) {
                    final typeName = typeInfo['pokemon_v2_type']['name'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Chip(
                        backgroundColor: getTypeColor(typeName),
                        label: Text(
                          typeName.toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Estadísticas
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Estadísticas',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...stats.map<Widget>((statInfo) {
                        final statName = statInfo['pokemon_v2_stat']['name'];
                        final baseStat = statInfo['base_stat'];
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              statName.toUpperCase(),
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              baseStat.toString(),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Habilidades
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Habilidades',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: abilities.map<Widget>((abilityInfo) {
                          final abilityName =
                              abilityInfo['pokemon_v2_ability']['name'];
                          return Chip(
                            label: Text(
                              abilityName,
                              style: const TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.blueAccent,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Evoluciones
                if (evolutions != null && evolutions.length > 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Evoluciones',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: evolutions.map<Widget>((evolution) {
                              final evolutionId = evolution['id'];
                              final evolutionName = evolution['name'];
                              final evolutionImageUrl =
                                  'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$evolutionId.png';
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PokemonDetailPage(
                                          pokemonId: evolutionId),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                                  child: Column(
                                  children: [
                                    Image.network(
                                      evolutionImageUrl,
                                      height: 80,
                                      width: 80,
                                      fit: BoxFit.cover,
                                    ),
                                    Text(
                                      evolutionName,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Movimientos',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: moves.length,
                        itemBuilder: (context, index) {
                          final move = moves[index]['pokemon_v2_move'];
                          final moveName = move['name'];
                          final movePower = move['power'] ?? 'N/A';
                          // final movePp = move['pp'];
                          final moveAccuracy = move['accuracy'] ?? 'N/A';
                          final moveType = move['pokemon_v2_type']['name'];

                          return ListTile(
                            title: Text(moveName),
                            subtitle: Text(
                                'Tipo: $moveType, Poder: $movePower, Precisión: $moveAccuracy'),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
