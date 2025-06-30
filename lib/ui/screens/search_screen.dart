import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';
import 'package:cuckoo_booru/ui/widgets/artwork_grid.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedRating = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near the bottom
      context.read<AppState>().loadMoreResults();
    }
  }

  void _performSearch() {
    final tags = _searchController.text.trim();
    if (tags.isNotEmpty) {
      context.read<AppState>().searchPosts(
        tags: tags,
        rating: _selectedRating,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CuckooBooru'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search tags (e.g., cat, dog, anime)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.search),
                        ),
                        onSubmitted: (_) => _performSearch(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _performSearch,
                      child: const Text('Search'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Rating Filter
                Row(
                  children: [
                    const Text('Rating: '),
                    DropdownButton<String>(
                      value: _selectedRating,
                      onChanged: (value) {
                        setState(() {
                          _selectedRating = value!;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(value: 's', child: Text('Safe')),
                        DropdownMenuItem(value: 'q', child: Text('Questionable')),
                        DropdownMenuItem(value: 'e', child: Text('Explicit')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: Consumer<AppState>(
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
                          'Error: ${appState.errorMessage}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: appState.clearError,
                          child: const Text('Dismiss'),
                        ),
                      ],
                    ),
                  );
                }

                // Loading state
                if (appState.isLoading && appState.searchResults.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Searching...'),
                      ],
                    ),
                  );
                }

                // Empty state
                if (appState.searchResults.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Enter tags to search for artwork',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try: cat, dog, anime, etc.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Results grid
                return ArtworkGrid(
                  artworks: appState.searchResults,
                  scrollController: _scrollController,
                  isLoading: appState.isLoading,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 