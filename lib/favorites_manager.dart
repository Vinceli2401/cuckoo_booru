import 'dart:convert';
import 'models/artwork.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' if (dart.library.html) 'io_stub.dart';

class FavoritesManager {
  final String _favoritesPath;

  FavoritesManager({String? favoritesPath})
    : _favoritesPath = favoritesPath ?? 'favorites.json';

  Future<List<Artwork>> loadFavorites() async {
    try {
      if (kIsWeb) {
        // Use SharedPreferences for web
        final prefs = await SharedPreferences.getInstance();
        final favoritesJson = prefs.getString('favorites') ?? '[]';
        final List<dynamic> jsonList = json.decode(favoritesJson);
        return jsonList.map((json) => Artwork.fromJson(json)).toList();
      } else {
        // Use file system for desktop/mobile
        final file = File(_favoritesPath);
        if (!await file.exists()) {
          return [];
        }

        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        return jsonList.map((json) => Artwork.fromJson(json)).toList();
      }
    } catch (e) {
      throw Exception('Error loading favorites: $e');
    }
  }

  Future<void> saveFavorites(List<Artwork> favorites) async {
    try {
      final jsonList = favorites.map((artwork) => artwork.toJson()).toList();
      final favoritesJson = json.encode(jsonList);
      
      if (kIsWeb) {
        // Use SharedPreferences for web
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('favorites', favoritesJson);
      } else {
        // Use file system for desktop/mobile
        final file = File(_favoritesPath);
        await file.writeAsString(favoritesJson);
      }
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
