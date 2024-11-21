const String fetchPokemonsQuery = r'''
  query FetchPokemons($limit: Int!, $offset: Int!, $where: pokemon_v2_pokemon_bool_exp, $order_by: [pokemon_v2_pokemon_order_by!]) {
    pokemon_v2_pokemon(
      limit: $limit,
      offset: $offset,
      where: $where,
      order_by: $order_by
    ) {
      id
      name
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
    }
  }
''';



const String fetchPokemonDetailQuery = r'''
  query FetchPokemonDetail($id: Int!) {
    pokemon_v2_pokemon_by_pk(id: $id) {
      id
      name
      height
      weight
      base_experience
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
      pokemon_v2_pokemonstats {
        base_stat
        pokemon_v2_stat {
          name
        }
      }
      pokemon_v2_pokemonabilities {
        pokemon_v2_ability {
          name
        }
      }
      pokemon_v2_pokemonmoves {
        pokemon_v2_move {
          name
          power
          pp
          accuracy
          pokemon_v2_type {
            name
          }
        }
      }
      pokemon_v2_pokemonspecy {
        pokemon_v2_evolutionchain {
          pokemon_v2_pokemonspecies(order_by: {id: asc}) {
            id
            name
          }
        }
      }
    }
  }
''';



//Luego se puede implementar movelearnmethod