class Artwork {
  final int id;
  final String? previewFileUrl;
  final String? fileUrl;
  final String? source;
  final String tagString;
  final String? tagStringArtist;
  final String? tagStringCharacter;
  final String? tagStringCopyright;
  final int score;
  final String rating;
  final DateTime createdAt;

  Artwork({
    required this.id,
    this.previewFileUrl,
    this.fileUrl,
    this.source,
    required this.tagString,
    this.tagStringArtist,
    this.tagStringCharacter,
    this.tagStringCopyright,
    required this.score,
    required this.rating,
    required this.createdAt,
  });

  factory Artwork.fromJson(Map<String, dynamic> json) {
    return Artwork(
      id: json['id'] as int,
      previewFileUrl: json['preview_file_url'] as String?,
      fileUrl: json['file_url'] as String?,
      source: json['source'] as String?,
      tagString: json['tag_string'] as String? ?? '',
      tagStringArtist: json['tag_string_artist'] as String?,
      tagStringCharacter: json['tag_string_character'] as String?,
      tagStringCopyright: json['tag_string_copyright'] as String?,
      score: json['score'] as int? ?? 0,
      rating: json['rating'] as String? ?? 'q',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'preview_file_url': previewFileUrl,
      'file_url': fileUrl,
      'source': source,
      'tag_string': tagString,
      'tag_string_artist': tagStringArtist,
      'tag_string_character': tagStringCharacter,
      'tag_string_copyright': tagStringCopyright,
      'score': score,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Post #$id - Score: $score - Rating: $rating\n'
        'Artist: ${tagStringArtist ?? 'Unknown'}\n'
        'Characters: ${tagStringCharacter ?? 'None'}\n'
        'Copyright: ${tagStringCopyright ?? 'Original'}\n'
        'Tags: $tagString\n'
        'Preview: $previewFileUrl\n';
  }
}
