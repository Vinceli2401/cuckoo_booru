import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'models/artwork.dart';

class DanbooruService {
  static const String baseUrl = 'https://danbooru.donmai.us';
  final String? username;
  final String? apiKey;
  final http.Client _client;

  DanbooruService({this.username, this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  Map<String, String> get _headers {
    final headers = <String, String>{
      'User-Agent': 'CuckooBooru/1.0.0',
      'Accept': 'application/json',
    };

    if (username != null && apiKey != null) {
      final credentials = base64Encode(utf8.encode('$username:$apiKey'));
      headers['Authorization'] = 'Basic $credentials';
    }

    return headers;
  }

  Future<List<Artwork>> searchPosts({
    String? tags,
    int limit = 20,
    int page = 1,
    String rating = 'all',
  }) async {
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'page': page.toString(),
    };

    if (tags != null && tags.trim().isNotEmpty) {
      queryParams['tags'] = tags.trim();
    }

    if (rating != 'all') {
      final ratingTag = 'rating:$rating';
      final currentTags = queryParams['tags'];
      if (currentTags != null && currentTags.isNotEmpty) {
        queryParams['tags'] = '$currentTags $ratingTag';
      } else {
        queryParams['tags'] = ratingTag;
      }
    }

    final uri = Uri.parse(
      '$baseUrl/posts.json',
    ).replace(queryParameters: queryParams);

    
    try {
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Artwork.fromJson(json)).toList();
      } else if (response.statusCode == 429) {
        throw Exception(
          'Rate limit exceeded. Please wait before making more requests.',
        );
      } else {
        throw Exception(
          'Failed to fetch posts: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } on SocketException {
      throw Exception('Network error: Please check your internet connection.');
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  Future<Artwork?> getPost(int id) async {
    final uri = Uri.parse('$baseUrl/posts/$id.json');

    try {
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return Artwork.fromJson(jsonData);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception(
          'Failed to fetch post: ${response.statusCode} ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching post: $e');
    }
  }

  Future<bool> addToFavorites(int postId) async {
    if (username == null || apiKey == null) {
      throw Exception('Authentication required for favorites');
    }

    final uri = Uri.parse('$baseUrl/favorites.json');

    try {
      final response = await _client.post(
        uri,
        headers: _headers,
        body: {'post_id': postId.toString()},
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception('Error adding to favorites: $e');
    }
  }

  Future<bool> removeFromFavorites(int postId) async {
    if (username == null || apiKey == null) {
      throw Exception('Authentication required for favorites');
    }

    final uri = Uri.parse('$baseUrl/favorites/$postId.json');

    try {
      final response = await _client.delete(uri, headers: _headers);
      return response.statusCode == 204;
    } catch (e) {
      throw Exception('Error removing from favorites: $e');
    }
  }

  Future<List<String>> searchTags({
    required String query,
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];

    final queryParams = <String, String>{
      'limit': limit.toString(),
      'search[name_matches]': '${query.trim()}*', // Wildcard search
    };

    final uri = Uri.parse(
      '$baseUrl/tags.json',
    ).replace(queryParameters: queryParams);

    try {
      final response = await _client.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList
            .map((json) => json['name'] as String)
            .where((name) => name.isNotEmpty)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> searchPostsWithFuzzy({
    String? tags,
    int limit = 20,
    int page = 1,
    String rating = 'all',
  }) async {
    if (tags == null || tags.trim().isEmpty) {
      final results = await searchPosts(
        tags: tags,
        limit: limit,
        page: page,
        rating: rating,
      );
      return {
        'results': results,
        'usedSuggestion': false,
        'suggestedTag': null,
      };
    }

    // First try exact search
    final exactResults = await searchPosts(
      tags: tags,
      limit: limit,
      page: page,
      rating: rating,
    );

    // If we got results, return them
    if (exactResults.isNotEmpty) {
      return {
        'results': exactResults,
        'usedSuggestion': false,
        'suggestedTag': null,
      };
    }

    // If no exact results, try fuzzy search by finding similar tags
    final words = tags.trim().toLowerCase().split(RegExp(r'\s+'));
    final List<String> suggestedTags = [];

    for (final word in words) {
      if (word.length >= 2) {
        final tagSuggestions = await searchTags(query: word, limit: 5);
        suggestedTags.addAll(tagSuggestions);
      }
    }

    // Try search with suggested tags
    if (suggestedTags.isNotEmpty) {
      final suggestedTag = suggestedTags.first;
      final fuzzyResults = await searchPosts(
        tags: suggestedTag,
        limit: limit,
        page: page,
        rating: rating,
      );
      
      return {
        'results': fuzzyResults,
        'usedSuggestion': fuzzyResults.isNotEmpty,
        'suggestedTag': fuzzyResults.isNotEmpty ? suggestedTag : null,
      };
    }

    return {
      'results': exactResults,
      'usedSuggestion': false,
      'suggestedTag': null,
    };
  }

  void dispose() {
    _client.close();
  }
}
