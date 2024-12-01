import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/api/graphql_client.dart';
import '/queries/query.dart';
import '/colors/type_color.dart';
import '../home/buildTypes.dart';
import '/services/pokemon_cache_service.dart';
import '/services/favorites_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class PokemonDetailPage extends StatefulWidget {
  final int pokemonId;

  const PokemonDetailPage({super.key, required this.pokemonId});

  @override
  PokemonDetailPageState createState() => PokemonDetailPageState();
}

class PokemonDetailPageState extends State<PokemonDetailPage> {
  late Future<Map<String, dynamic>> _pokemonData = _initPokemonData();
  bool _isFavorited = false;
  late PokemonCacheService _cacheService;
  bool _isOffline = false;
  final FavoritesService _favoritesService = FavoritesService();
  final ScreenshotController _screenshotController = ScreenshotController();


  Future<Map<String, dynamic>> _initPokemonData() async {
    final prefs = await SharedPreferences.getInstance();
    _cacheService = PokemonCacheService(prefs);
    return _fetchPokemonDetail();
  }

  @override
  void initState() {
    super.initState();
    _isFavorited = FavoritesService().isFavorite(widget.pokemonId);
  }

  // Eliminar el método _initializeCache() ya que no lo necesitamos más

  Future<Map<String, dynamic>> _fetchPokemonDetail() async {
    // Intentar obtener datos del caché primero
    final cachedData = _cacheService.getCachedPokemonDetail(widget.pokemonId);
    if (cachedData != null) {
      setState(() => _isOffline = true);
      return cachedData;
    }

    try {
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

      await _cacheService.cachePokemonDetail(widget.pokemonId, pokemon);
      setState(() => _isOffline = false);

      return pokemon;
    } catch (e) {
      final cachedData = _cacheService.getCachedPokemonDetail(widget.pokemonId);
      if (cachedData != null) {
        setState(() => _isOffline = true);
        return cachedData;
      }
      throw e;
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
      if (_isFavorited) {
        FavoritesService().addFavorite(widget.pokemonId);
      } else {
        FavoritesService().removeFavorite(widget.pokemonId);
      }
    });
  }

  bool _isFavorite() {
    return _favoritesService.isFavorite(widget.pokemonId);
  }

  Map<String, List<dynamic>> _groupMovesByLearnMethod(List<dynamic> moves) {
    final groupedMoves = <String, List<dynamic>>{};
    final Map<String, Set<String>> movesAddedPerMethod = {};

    for (var move in moves) {
      final learnMethod = move['pokemon_v2_movelearnmethod']['name'];
      final moveName = move['pokemon_v2_move']['name'];

      if (!groupedMoves.containsKey(learnMethod)) {
        groupedMoves[learnMethod] = [];
        movesAddedPerMethod[learnMethod] = {};
      }

      if (!movesAddedPerMethod[learnMethod]!.contains(moveName)) {
        groupedMoves[learnMethod]!.add(move);
        movesAddedPerMethod[learnMethod]!.add(moveName);
      }
    }
    return groupedMoves;
  }

  void _navigateToNextPokemon() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PokemonDetailPage(pokemonId: widget.pokemonId + 1),
      ),
    );
  }

  void _navigateToPreviousPokemon() {
    if (widget.pokemonId > 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PokemonDetailPage(pokemonId: widget.pokemonId - 1),
        ),
      );
    }
  }

  void _addToFavorites() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }


  

  void _sharePokemonDetails() async {
  try {
    final image = await _screenshotController.capture();
    if (image == null) return;

    final directory = await getTemporaryDirectory();
    final imagePath = '${directory.path}/pokemon_${widget.pokemonId}.png';
    final imageFile = File(imagePath)..writeAsBytesSync(image);

    final pokemonData = await _pokemonData;
    final name = pokemonData['name'];
    final stats = pokemonData['pokemon_v2_pokemonstats']
        .map((stat) => '${stat['pokemon_v2_stat']['name']}: ${stat['base_stat']}')
        .join('\n');

    final shareText = 'Detalles de ${name[0].toUpperCase()}${name.substring(1)}:\n\n'
        'ID: ${widget.pokemonId}\n\n'
        'Estadísticas:\n$stats';

    await Share.shareXFiles(
      [XFile(imageFile.path)],
      text: shareText,
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al compartir: $e')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final int id = widget.pokemonId;
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detalles del Pokémon',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [IconButton(
    icon: Icon(Icons.share, color: Colors.white),
    onPressed: _sharePokemonDetails,
  ),
          if (_isOffline)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.offline_bolt, color: Colors.white),
            ),
        ],
        
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
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
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Screenshot(
                        controller: _screenshotController,
                        child: Container(
                          color: Colors.white,
                          child: Column(
                          children: [
                            Hero(
              tag: 'pokemon-image-$id',
              child: Image.network(
                imageUrl,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
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
                            Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: types.map<Widget>((typeInfo) {
                            final typeName =
                                typeInfo['pokemon_v2_type']['name'];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      getTypeColor(typeName).withOpacity(0.8),
                                      getTypeColor(typeName),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: getTypeColor(typeName)
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      buildTypeWidget(typeInfo),
                                      const SizedBox(width: 8),
                                      Text(
                                        typeName.toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Estadísticas
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade300,
                                Colors.blue.shade600
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.bar_chart,
                                          color: Colors.blue.shade600),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Estadísticas',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: stats.map<Widget>((statInfo) {
                                      final statName =
                                          statInfo['pokemon_v2_stat']['name'];
                                      final baseStat = statInfo['base_stat'];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  statName.toUpperCase(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  baseStat.toString(),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            LinearProgressIndicator(
                                              value: baseStat / 255,
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.blue.shade400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                          ],
                        ),
                        )
                      ),
                      
                      
                      // Habilidades
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.purple.shade300,
                                Colors.purple.shade600
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 16.0, 16.0, 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.auto_awesome,
                                          color: Colors.purple.shade600),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Habilidades',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 8.0, 16.0, 24.0),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children:
                                        abilities.map<Widget>((abilityInfo) {
                                      final abilityName =
                                          abilityInfo['pokemon_v2_ability']
                                              ['name'];
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.purple.shade400,
                                              Colors.purple.shade600
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.purple.shade200,
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          abilityName.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Evoluciones
                      if (evolutions != null && evolutions.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.green.shade300,
                                  Colors.green.shade600
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.change_circle,
                                            color: Colors.green.shade600),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Evoluciones',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children:
                                          evolutions.map<Widget>((evolution) {
                                        final evolutionId = evolution['id'];
                                        final evolutionName = evolution['name'];
                                        final evolutionImageUrl =
                                            'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$evolutionId.png';
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PokemonDetailPage(
                                                          pokemonId:
                                                              evolutionId),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                border: Border.all(
                                                    color:
                                                        Colors.green.shade200),
                                              ),
                                              child: Column(
                                                children: [
                                                  Image.network(
                                                    evolutionImageUrl,
                                                    height: 80,
                                                    width: 80,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    evolutionName.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.green.shade700,
                                                    ),
                                                  ),
                                                ],
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
                          ),
                        ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade300,
                                Colors.red.shade600
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.auto_awesome,
                                          color: Colors.red.shade600),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Movimientos',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Builder(
                                  builder: (context) {
                                    final groupedMoves =
                                        _groupMovesByLearnMethod(moves);
                                    final learnMethods =
                                        groupedMoves.keys.toList();

                                    return DefaultTabController(
                                      length: learnMethods.length,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 45,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.grey.shade200,
                                                  Colors.grey.shade100
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4, vertical: 4),
                                            child: TabBar(
                                              isScrollable: true,
                                              tabs: learnMethods.map((method) {
                                                return Tab(
                                                  height:
                                                      35, // Reduced tab height
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          method == 'level-up'
                                                              ? Icons.straight
                                                              : method ==
                                                                      'machine'
                                                                  ? Icons
                                                                      .settings
                                                                  : method ==
                                                                          'egg'
                                                                      ? Icons
                                                                          .egg
                                                                      : Icons
                                                                          .auto_awesome,
                                                          size:
                                                              16, // Smaller icon
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        Text(
                                                          method
                                                              .replaceAll(
                                                                  '-', ' ')
                                                              .toUpperCase(),
                                                          style: const TextStyle(
                                                              fontSize:
                                                                  12), // Smaller text
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                              labelColor: Colors.white,
                                              unselectedLabelColor:
                                                  Colors.grey.shade600,
                                              indicator: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.red.shade400,
                                                    Colors.red.shade600
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.red.shade200
                                                        .withOpacity(0.5),
                                                    blurRadius: 4,
                                                    spreadRadius: 1,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              dividerColor: Colors.transparent,
                                              indicatorSize:
                                                  TabBarIndicatorSize.tab,
                                              labelPadding: EdgeInsets.zero,
                                              tabAlignment: TabAlignment.center,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            height: 332,
                                            child: TabBarView(
                                              children:
                                                  learnMethods.map((method) {
                                                final methodMoves =
                                                    groupedMoves[method]!;
                                                return ListView.builder(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  itemCount: methodMoves.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final move =
                                                        methodMoves[index];
                                                    final moveDetails =
                                                        move['pokemon_v2_move'];
                                                    final moveName =
                                                        moveDetails['name'];
                                                    final movePower =
                                                        moveDetails['power']
                                                                ?.toString() ??
                                                            'N/A';
                                                    final moveAccuracy =
                                                        moveDetails['accuracy']
                                                                ?.toString() ??
                                                            'N/A';
                                                    final moveType = moveDetails[
                                                            'pokemon_v2_type']
                                                        ['name'];
                                                    final level = move['level'];

                                                    return Card(
                                                      elevation: 3,
                                                      margin: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4,
                                                          horizontal: 8),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                      ),
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          gradient:
                                                              LinearGradient(
                                                            colors: [
                                                              Colors.white,
                                                              getTypeColor(
                                                                      moveType)
                                                                  .withOpacity(
                                                                      0.1),
                                                            ],
                                                            begin: Alignment
                                                                .centerLeft,
                                                            end: Alignment
                                                                .centerRight,
                                                          ),
                                                        ),
                                                        child: ListTile(
                                                          leading: Container(
                                                            width: 45,
                                                            height: 45,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  getTypeColor(
                                                                      moveType),
                                                              shape: BoxShape
                                                                  .circle,
                                                              boxShadow: [
                                                                BoxShadow(
                                                                  color: getTypeColor(
                                                                          moveType)
                                                                      .withOpacity(
                                                                          0.5),
                                                                  blurRadius: 6,
                                                                  offset:
                                                                      const Offset(
                                                                          0, 3),
                                                                ),
                                                              ],
                                                            ),
                                                            child: Center(
                                                              child: method ==
                                                                      'level-up'
                                                                  ? Text(
                                                                      'Lv${level}',
                                                                      style:
                                                                          const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    )
                                                                  : Icon(
                                                                      Icons
                                                                          .auto_awesome,
                                                                      color: Colors
                                                                          .white,
                                                                      size: 24,
                                                                    ),
                                                            ),
                                                          ),
                                                          title: Text(
                                                            moveName
                                                                .replaceAll(
                                                                    '-', ' ')
                                                                .toUpperCase(),
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          subtitle: Wrap(
                                                            spacing: 8,
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 2,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: getTypeColor(
                                                                      moveType),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              12),
                                                                ),
                                                                child: Text(
                                                                  moveType
                                                                      .toUpperCase(),
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              Text(
                                                                  'POW: $movePower'),
                                                              Text(
                                                                  'ACC: $moveAccuracy'),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 36),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: ConvexAppBar(
        style: TabStyle.reactCircle,
        backgroundColor: Colors.red,
        items: [
          TabItem(icon: Icons.arrow_back, title: 'Previous'),
          TabItem(
            icon: GestureDetector(
              onTap: _toggleFavorite,
              child: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 30,
              ),
            ),
            title: 'Favorite',
          ),
          TabItem(icon: Icons.arrow_forward, title: 'Next'),
        ],
        initialActiveIndex: 1,
        onTap: (int index) {
          if (index == 0) {
            _navigateToPreviousPokemon();
          } else if (index == 1) {
            _addToFavorites();
          } else if (index == 2) {
            _navigateToNextPokemon();
          }
        },
      ),
    );
  }
}
