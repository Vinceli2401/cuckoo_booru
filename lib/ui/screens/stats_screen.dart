import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';
import 'package:cuckoo_booru/services/collection_manager.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final CollectionManager _collectionManager = CollectionManager();
  Map<String, dynamic>? _collectionStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _collectionManager.getCollectionStats();
      setState(() => _collectionStats = stats);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load stats: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOverviewSection(),
                  const SizedBox(height: 24),
                  _buildFavoritesSection(),
                  const SizedBox(height: 24),
                  _buildCollectionsSection(),
                  const SizedBox(height: 24),
                  _buildQuickTagsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildOverviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Favorites',
                    context.watch<AppState>().favorites.length.toString(),
                    Icons.favorite,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Collections',
                    (_collectionStats?['totalCollections'] ?? 0).toString(),
                    Icons.collections_bookmark,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Quick Tags',
                    context.watch<AppState>().quickSearchTags.length.toString(),
                    Icons.local_offer,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Theme',
                    context.watch<AppState>().themeMode == ThemeMode.dark ? 'Dark' : 'Light',
                    Icons.palette,
                    Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesSection() {
    final favorites = context.watch<AppState>().favorites;
    if (favorites.isEmpty) {
      return const SizedBox.shrink();
    }

    final ratingCounts = <String, int>{};
    final scoreBuckets = <String, int>{
      '0-10': 0,
      '11-50': 0,
      '51-100': 0,
      '100+': 0,
    };

    for (final artwork in favorites) {
      ratingCounts[artwork.rating] = (ratingCounts[artwork.rating] ?? 0) + 1;
      
      if (artwork.score <= 10) {
        scoreBuckets['0-10'] = scoreBuckets['0-10']! + 1;
      } else if (artwork.score <= 50) {
        scoreBuckets['11-50'] = scoreBuckets['11-50']! + 1;
      } else if (artwork.score <= 100) {
        scoreBuckets['51-100'] = scoreBuckets['51-100']! + 1;
      } else {
        scoreBuckets['100+'] = scoreBuckets['100+']! + 1;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Favorites Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'By Rating',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...ratingCounts.entries.map((entry) {
              final ratingName = _getRatingName(entry.key);
              final percentage = (entry.value / favorites.length * 100).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('$ratingName:'),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: entry.value / favorites.length,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ' ${entry.value} ($percentage%)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Text(
              'By Score Range',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...scoreBuckets.entries.map((entry) {
              final percentage = favorites.isNotEmpty ? (entry.value / favorites.length * 100).round() : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('${entry.key}:'),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: favorites.isNotEmpty ? entry.value / favorites.length : 0,
                        backgroundColor: Colors.grey[300],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        ' ${entry.value} ($percentage%)',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCollectionsSection() {
    if (_collectionStats == null) return const SizedBox.shrink();

    final totalCollections = _collectionStats!['totalCollections'] as int;
    final totalArtworks = _collectionStats!['totalArtworks'] as int;
    final averageSize = _collectionStats!['averageSize'] as int;
    final collectionSizes = _collectionStats!['collectionSizes'] as Map<String, int>;

    if (totalCollections == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Collections Analysis',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoTile('Total Collections', totalCollections.toString()),
                ),
                Expanded(
                  child: _buildInfoTile('Total Items', totalArtworks.toString()),
                ),
                Expanded(
                  child: _buildInfoTile('Average Size', averageSize.toString()),
                ),
              ],
            ),
            if (collectionSizes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Collection Sizes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...collectionSizes.entries.take(5).map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.key,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${entry.value} items',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTagsSection() {
    final quickTags = context.watch<AppState>().quickSearchTags;
    if (quickTags.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Search Tags',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: quickTags.take(10).map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: const TextStyle(fontSize: 11),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                );
              }).toList(),
            ),
            if (quickTags.length > 10)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '... and ${quickTags.length - 10} more',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _getRatingName(String rating) {
    switch (rating.toLowerCase()) {
      case 's':
        return 'Safe';
      case 'q':
        return 'Questionable';
      case 'e':
        return 'Explicit';
      default:
        return 'Unknown';
    }
  }
}