import 'package:test/test.dart';
import 'package:cuckoo_booru/cuckoo_booru.dart';

void main() {
  group('Artwork', () {
    test('fromJson creates valid Artwork instance', () {
      final json = {
        'id': 12345,
        'preview_file_url': 'https://example.com/preview.jpg',
        'file_url': 'https://example.com/full.jpg',
        'source': 'https://artist.example.com',
        'tag_string': 'original solo 1girl',
        'tag_string_artist': 'artist_name',
        'tag_string_character': 'character_name',
        'tag_string_copyright': 'original',
        'score': 100,
        'rating': 's',
        'created_at': '2023-01-01T00:00:00.000Z',
      };

      final artwork = Artwork.fromJson(json);

      expect(artwork.id, equals(12345));
      expect(artwork.previewFileUrl, equals('https://example.com/preview.jpg'));
      expect(artwork.tagString, equals('original solo 1girl'));
      expect(artwork.score, equals(100));
      expect(artwork.rating, equals('s'));
    });

    test('toJson returns valid JSON', () {
      final artwork = Artwork(
        id: 12345,
        tagString: 'original solo 1girl',
        score: 100,
        rating: 's',
        createdAt: DateTime.parse('2023-01-01T00:00:00.000Z'),
      );

      final json = artwork.toJson();

      expect(json['id'], equals(12345));
      expect(json['tag_string'], equals('original solo 1girl'));
      expect(json['score'], equals(100));
      expect(json['rating'], equals('s'));
    });
  });

  group('DanbooruService', () {
    test('creates service with optional credentials', () {
      final service = DanbooruService();
      expect(service.username, isNull);
      expect(service.apiKey, isNull);
      service.dispose();
    });

    test('creates service with credentials', () {
      final service = DanbooruService(username: 'testuser', apiKey: 'testkey');
      expect(service.username, equals('testuser'));
      expect(service.apiKey, equals('testkey'));
      service.dispose();
    });
  });

  group('FavoritesManager', () {
    test('creates manager with default path', () {
      final manager = FavoritesManager();
      expect(manager, isNotNull);
    });

    test('creates manager with custom path', () {
      final manager = FavoritesManager(favoritesPath: 'test_favorites.json');
      expect(manager, isNotNull);
    });
  });
}
