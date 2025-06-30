import 'dart:convert';
import 'dart:io';
import 'models/artwork.dart';

class FavoritesManager {
  final String _favoritesPath;

  FavoritesManager({String? favoritesPath})
    : _favoritesPath = favoritesPath ?? 'favorites.json';

  Future<List<Artwork>> loadFavorites() async {
    try {
      final file = File(_favoritesPath);
      if (!await file.exists()) {
        return [];
      }

      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Artwork.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error loading favorites: $e');
    }
  }

  Future<void> saveFavorites(List<Artwork> favorites) async {
    try {
      final file = File(_favoritesPath);
      final jsonList = favorites.map((artwork) => artwork.toJson()).toList();
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      throw Exception('Error saving favorites: $e');
    }
  }

  Future<void> addFavorite(Artwork artwork) async {
    final favorites = await loadFavorites();

    if (!favorites.any((fav) => fav.id == artwork.id)) {
      favorites.add(artwork);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(int artworkId) async {
    final favorites = await loadFavorites();
    favorites.removeWhere((fav) => fav.id == artworkId);
    await saveFavorites(favorites);
  }

  Future<bool> isFavorite(int artworkId) async {
    final favorites = await loadFavorites();
    return favorites.any((fav) => fav.id == artworkId);
  }

  Future<int> getFavoritesCount() async {
    final favorites = await loadFavorites();
    return favorites.length;
  }
}
