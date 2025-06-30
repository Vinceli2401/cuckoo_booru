import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';
import 'package:cuckoo_booru/ui/widgets/artwork_grid.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppState>().loadFavorites();
            },
            tooltip: 'Refresh favorites',
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          // Error handling
          if (appState.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading favorites: ${appState.errorMessage}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      appState.clearError();
                      appState.loadFavorites();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (appState.favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Search for artwork and tap the heart icon to add favorites',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Favorites grid
          return Column(
            children: [
              // Stats bar
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${appState.favorites.length} favorites',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              
              // Grid
              Expanded(
                child: ArtworkGrid(
                  artworks: appState.favorites,
                  isLoading: false,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 