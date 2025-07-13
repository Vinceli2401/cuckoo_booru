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

  // Quick prompt suggestions
  final List<String> _quickPrompts = [
    'pokemon_masters_ex',
    'genshin_impact',
    'fate/grand_order',
    'azur_lane',
    'blue_archive',
    'honkai_impact_3rd',
    'arknights',
    'touhou',
    'kantai_collection',
    'fire_emblem',
    'final_fantasy',
    'league_of_legends',
  ];

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
      context.read<AppState>().loadMoreResults();
    }
  }

  void _performSearch() {
    final tags = _searchController.text.trim();
    if (tags.isNotEmpty) {
      context.read<AppState>().searchPosts(tags: tags, rating: _selectedRating);
    }
  }

  void _searchPrompt(String prompt) {
    _searchController.text = prompt;
    context.read<AppState>().searchPosts(tags: prompt, rating: _selectedRating);
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
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
            ),
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
                        DropdownMenuItem(
                          value: 'q',
                          child: Text('Questionable'),
                        ),
                        DropdownMenuItem(value: 'e', child: Text('Explicit')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Quick Prompts',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    itemCount: _quickPrompts.length,
                    itemBuilder: (context, index) {
                      final prompt = _quickPrompts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ActionChip(
                          label: Text(
                            prompt,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                          onPressed: () => _searchPrompt(prompt),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          labelStyle: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Consumer<AppState>(
              builder: (context, appState, child) {
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

                if (appState.searchResults.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Enter tags to search for artwork',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try: cat, dog, anime, etc.',
                          style: TextStyle(color: Colors.grey),
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
