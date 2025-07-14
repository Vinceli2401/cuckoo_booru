class SearchFilters {
  final String tags;
  final String rating;
  final int? minScore;
  final int? maxScore;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? minWidth;
  final String? minHeight;
  final List<String> fileTypes;

  const SearchFilters({
    this.tags = '',
    this.rating = 'all',
    this.minScore,
    this.maxScore,
    this.dateFrom,
    this.dateTo,
    this.minWidth,
    this.minHeight,
    this.fileTypes = const [],
  });

  SearchFilters copyWith({
    String? tags,
    String? rating,
    int? minScore,
    int? maxScore,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? minWidth,
    String? minHeight,
    List<String>? fileTypes,
  }) {
    return SearchFilters(
      tags: tags ?? this.tags,
      rating: rating ?? this.rating,
      minScore: minScore ?? this.minScore,
      maxScore: maxScore ?? this.maxScore,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      minWidth: minWidth ?? this.minWidth,
      minHeight: minHeight ?? this.minHeight,
      fileTypes: fileTypes ?? this.fileTypes,
    );
  }

  bool get hasActiveFilters {
    return minScore != null ||
        maxScore != null ||
        dateFrom != null ||
        dateTo != null ||
        minWidth != null ||
        minHeight != null ||
        fileTypes.isNotEmpty;
  }

  String get filterSummary {
    final List<String> summaryParts = [];
    
    if (minScore != null || maxScore != null) {
      final min = minScore?.toString() ?? '0';
      final max = maxScore?.toString() ?? '∞';
      summaryParts.add('Score: $min-$max');
    }
    
    if (dateFrom != null || dateTo != null) {
      summaryParts.add('Date filtered');
    }
    
    if (minWidth != null || minHeight != null) {
      summaryParts.add('Resolution filtered');
    }
    
    if (fileTypes.isNotEmpty) {
      summaryParts.add('File types: ${fileTypes.join(', ')}');
    }
    
    return summaryParts.isEmpty ? 'No filters' : summaryParts.join(' • ');
  }
}