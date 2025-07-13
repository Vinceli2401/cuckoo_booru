import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cuckoo_booru/models/artwork.dart';
import 'package:cuckoo_booru/danbooru_service.dart';
import 'package:cuckoo_booru/favorites_manager.dart';

class AppState extends ChangeNotifier {
  final DanbooruService _danbooruService = DanbooruService();
  final FavoritesManager _favoritesManager = FavoritesManager();

  List<Artwork> _searchResults = [];
  List<Artwork> _favorites = [];
  List<String> _quickSearchTags = [];
  bool _isLoading = false;
  String _errorMessage = '';
  int _currentPage = 1;
  String _currentSearchTags = '';

  AppState() {
    _loadQuickSearchTags();
  }

  // Getters
  List<Artwork> get searchResults => _searchResults;
  List<Artwork> get favorites => _favorites;
  List<String> get quickSearchTags => _quickSearchTags;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  String get currentSearchTags => _currentSearchTags;

  // Search functionality
  Future<void> searchPosts({
    required String tags,
    int page = 1,
    String rating = 'all',
    bool append = false,
  }) async {
    if (!append) {
      _isLoading = true;
      _errorMessage = '';
      _searchResults.clear();
      _currentPage = 1;
    }

    _currentSearchTags = tags;
    notifyListeners();

    try {
      final results = await _danbooruService.searchPosts(
        tags: tags,
        page: page,
        rating: rating,
        limit: 20,
      );

      if (append) {
        _searchResults.addAll(results);
        _currentPage = page;
      } else {
        _searchResults = results;
        _currentPage = page;
      }

      _errorMessage = '';
      
      if (!append && tags.trim().isNotEmpty) {
        addQuickSearchTag(tags.trim());
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more results (pagination)
  Future<void> loadMoreResults() async {
    if (_isLoading || _currentSearchTags.isEmpty) return;

    await searchPosts(
      tags: _currentSearchTags,
      page: _currentPage + 1,
      append: true,
    );
  }

  // Favorites functionality
  Future<void> loadFavorites() async {
    try {
      _favorites = await _favoritesManager.loadFavorites();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Artwork artwork) async {
    try {
      final isFav = await _favoritesManager.isFavorite(artwork.id);
      
      if (isFav) {
        await _favoritesManager.removeFavorite(artwork.id);
      } else {
        await _favoritesManager.addFavorite(artwork);
      }
      
      await loadFavorites();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> isFavorite(int artworkId) async {
    return await _favoritesManager.isFavorite(artworkId);
  }

  // Quick search tags management
  Future<void> _loadQuickSearchTags() async {
    final prefs = await SharedPreferences.getInstance();
    _quickSearchTags = prefs.getStringList('quick_search_tags') ?? [];
    notifyListeners();
  }

  Future<void> _saveQuickSearchTags() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('quick_search_tags', _quickSearchTags);
  }

  void addQuickSearchTag(String tag) {
    if (!_quickSearchTags.contains(tag)) {
      _quickSearchTags.insert(0, tag);
      if (_quickSearchTags.length > 12) {
        _quickSearchTags.removeLast();
      }
      _saveQuickSearchTags();
      notifyListeners();
    }
  }

  void removeQuickSearchTag(String tag) {
    _quickSearchTags.remove(tag);
    _saveQuickSearchTags();
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _danbooruService.dispose();
    super.dispose();
  }
} 