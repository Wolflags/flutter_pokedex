
# Pokédex

## Descripción General
Pokédex es una aplicación diseñada para explorar y obtener información detallada sobre diversas especies de Pokémon. A través de una integración con la API GraphQL de [PokeAPI](https://pokeapi.co), los usuarios pueden consultar, buscar y filtrar información en tiempo real de manera eficiente. Además, la aplicación permite marcar Pokémon como favoritos, compartir información y disfrutar de una interfaz atractiva y personalizada.

## Características Principales
1. **Interfaz de Usuario Intuitiva y Atractiva**:
   - Lista de Pokémon con sus nombres, imágenes y tipos.
   - Barra de búsqueda para localizar Pokémon por nombre o número.
   - Pantalla de detalles con información detallada (estadísticas, habilidades, evoluciones, etc.).
   - Posibilidad de marcar Pokémon como favoritos.

2. **Uso de GraphQL**:
   - Integración con la API GraphQL para realizar consultas eficientes y optimizadas.
   - Soporte para paginación al listar Pokémon.
   - Consultas específicas para obtener detalles individuales.

3. **Navegación Fluida**:
   - Transiciones suaves entre pantallas.
   - Navegación intuitiva entre la lista de Pokémon y los detalles individuales.

4. **Filtrado y Ordenación**:
   - Filtrar Pokémon por tipo, generación, habilidades, entre otros.
   - Ordenar la lista por diferentes criterios (nombre, número, poder, etc.).

5. **Compartir Información**:
   - Función para compartir detalles de Pokémon en redes sociales.

6. **Animaciones y Transiciones**:
   - Animaciones que enriquecen la experiencia de usuario.

7. **Persistencia de Datos**:
   - Almacenamiento local para guardar y recuperar favoritos.

8. **Diseño Personalizado**:
   - Interfaz visualmente atractiva con elementos gráficos únicos.

## Tecnologías Utilizadas
- **Frontend**: Flutter
- **Backend**: GraphQL API de PokeAPI
- **Persistencia Local**: Shared Preferences
- **Lenguaje de Programación**: Dart

## Organización del Código
- **graphql_client.dart**: Configuración e implementación del cliente GraphQL.
- **query.dart**: Definición de las consultas necesarias para interactuar con la API.
- **filter_section.dart**: Componente de filtrado y ordenación.
- **home_page.dart**: Pantalla principal de la lista de Pokémon.
- **buildTypes.dart**: Lógica para construir los tipos de Pokémon en la UI.
- **favorites_page.dart**: Gestión y visualización de la lista de favoritos.
- **pokemon_detail_page.dart**: Detalles completos de un Pokémon.

## Implementación de GraphQL
- **Configuración del Cliente**:
  La aplicación utiliza un cliente GraphQL para comunicarse con la API de PokeAPI, gestionando consultas y mutaciones.
  
- **Consultas**:
  - **Lista de Pokémon**: Implementa paginación para cargar Pokémon de forma eficiente.
  - **Detalles de Pokémon**: Consultas optimizadas para obtener información específica.

- **Beneficios de GraphQL**:
  - Reduce la carga en la red al solicitar solo los datos necesarios.
  - Permite un control granular sobre los datos obtenidos.

## Cómo Ejecutar la Aplicación
1. Clonar este repositorio:
   ```bash
   git clone https://github.com/Wolflags/flutter_pokedex
   cd pokedex
   ```
2. Instalar dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecutar la aplicación:
   ```bash
   flutter run
   ```
