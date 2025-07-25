import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:cuckoo_booru/ui/providers/app_state.dart';
import 'package:cuckoo_booru/ui/widgets/artwork_grid.dart';
import 'package:cuckoo_booru/ui/screens/advanced_search_screen.dart';
import 'package:cuckoo_booru/ui/widgets/tag_autocomplete_field.dart';
import 'package:cuckoo_booru/models/search_filters.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedRating = 'all';
  Timer? _debounceTimer;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingSearchText();
    });
  }

  void _checkPendingSearchText() {
    final appState = context.read<AppState>();
    if (appState.pendingSearchText.isNotEmpty) {
      _searchController.text = appState.pendingSearchText;
      appState.clearPendingSearchText();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
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


  void _performSearchImmediate() {
    _debounceTimer?.cancel();
    final tags = _searchController.text.trim();
    final appState = context.read<AppState>();
    appState.searchPosts(
      tags: tags, 
      rating: _selectedRating,
      filters: appState.currentFilters.copyWith(
        tags: tags,
        rating: _selectedRating,
      ),
    );
  }

  void _searchPrompt(String prompt) {
    _searchController.text = prompt;
    final appState = context.read<AppState>();
    appState.searchPosts(
      tags: prompt, 
      rating: _selectedRating,
      filters: appState.currentFilters.copyWith(
        tags: prompt,
        rating: _selectedRating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Using existing paint.png as logo - replace with your logo
            Image.asset(
              'assets/images/paint.png',
              height: 32,
              width: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image, size: 32);
              },
            ),
            const SizedBox(width: 8),
            const Text('CuckooBooru'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              context.watch<AppState>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => context.read<AppState>().toggleTheme(),
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(
                16.0,
                MediaQuery.of(context).padding.top > 0 ? 8.0 : 16.0,
                16.0,
                16.0,
              ),
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
                      child: TagAutocompleteField(
                        controller: _searchController,
                        hintText: 'Search tags (e.g., cat, dog, anime)',
                        prefixIcon: const Icon(Icons.search),
                        onSubmitted: (_) => _performSearchImmediate(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AdvancedSearchScreen(),
                          ),
                        );
                      },
                      icon: Consumer<AppState>(
                        builder: (context, appState, child) {
                          return Icon(
                            Icons.tune,
                            color: appState.currentFilters.hasActiveFilters
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          );
                        },
                      ),
                      tooltip: 'Advanced Search',
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _performSearchImmediate,
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
                    const SizedBox(width: 24),
                    Consumer<AppState>(
                      builder: (context, appState, child) {
                        return Row(
                          children: [
                            const Text('Sort: '),
                            DropdownButton<SortOrder>(
                              value: appState.currentFilters.sortOrder,
                              onChanged: (value) {
                                final newFilters = appState.currentFilters.copyWith(
                                  sortOrder: value!,
                                );
                                appState.updateSearchFilters(newFilters);
                                // Re-search with new sorting
                                if (appState.searchResults.isNotEmpty) {
                                  _performSearchImmediate();
                                }
                              },
                              items: const [
                                DropdownMenuItem(value: SortOrder.id, child: Text('Default')),
                                DropdownMenuItem(value: SortOrder.dateDesc, child: Text('Date ↓')),
                                DropdownMenuItem(value: SortOrder.dateAsc, child: Text('Date ↑')),
                                DropdownMenuItem(value: SortOrder.scoreDesc, child: Text('Score ↓')),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    return Column(
                      children: [
                        // Search suggestion
                        if (appState.searchSuggestion.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              // Extract the suggested tag from the message
                              final suggestionMessage = appState.searchSuggestion;
                              final match = RegExp(r'"([^"]+)"').firstMatch(suggestionMessage);
                              if (match != null) {
                                final suggestedTag = match.group(1)!;
                                _searchController.text = suggestedTag;
                                _performSearchImmediate();
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_fix_high,
                                    size: 16,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      appState.searchSuggestion,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[800],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.touch_app,
                                    size: 14,
                                    color: Colors.orange[800],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        // Active filters
                        if (appState.currentFilters.hasActiveFilters) ...[
                          const SizedBox(height: 8),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.filter_alt,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    appState.currentFilters.filterSummary,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => appState.clearSearchFilters(),
                                  child: Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
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
                Consumer<AppState>(
                  builder: (context, appState, child) {
                    if (appState.quickSearchTags.isEmpty) {
                      return Container();
                    }
                    return SizedBox(
                      height: 48,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        itemCount: appState.quickSearchTags.length,
                        itemBuilder: (context, index) {
                          final tag = appState.quickSearchTags[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: InputChip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.center,
                              ),
                              onPressed: () => _searchPrompt(tag),
                              onDeleted: () => context.read<AppState>().removeQuickSearchTag(tag),
                              deleteIcon: const Icon(Icons.close, size: 16),
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
                              deleteIconColor: Theme.of(context).colorScheme.onPrimaryContainer,
                              visualDensity: VisualDensity.compact,
                            ),
                          );
                        },
                      ),
                    );
                  },
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
      ),
    );
  }
}
