import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/models/artwork.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';
import 'package:cuckoo_booru/ui/widgets/artwork_detail_screen.dart';

class ArtworkGrid extends StatelessWidget {
  final List<Artwork> artworks;
  final ScrollController? scrollController;
  final bool isLoading;

  const ArtworkGrid({
    super.key,
    required this.artworks,
    this.scrollController,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MasonryGridView.count(
            controller: scrollController,
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: const EdgeInsets.all(8),
            itemCount: artworks.length,
            itemBuilder: (context, index) {
              final artwork = artworks[index];
              return ArtworkCard(artwork: artwork);
            },
          ),
        ),
        
        // Loading indicator at bottom
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text('Loading more...'),
              ],
            ),
          ),
      ],
    );
  }
}

class ArtworkCard extends StatefulWidget {
  final Artwork artwork;

  const ArtworkCard({super.key, required this.artwork});

  @override
  State<ArtworkCard> createState() => _ArtworkCardState();
}

class _ArtworkCardState extends State<ArtworkCard> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final isFav = await context.read<AppState>().isFavorite(widget.artwork.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  void _toggleFavorite() async {
    await context.read<AppState>().toggleFavorite(widget.artwork);
    _checkFavoriteStatus();
  }

  Color _getRatingColor() {
    switch (widget.artwork.rating.toLowerCase()) {
      case 's':
        return Colors.green;
      case 'q':
        return Colors.orange;
      case 'e':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getRatingText() {
    switch (widget.artwork.rating.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ArtworkDetailScreen(artwork: widget.artwork),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.artwork.previewFileUrl ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Image not available', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Rating badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRatingColor(),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getRatingText(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                
                // Favorite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? Colors.red : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ID and Score
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '#${widget.artwork.id}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.thumb_up, size: 12, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(
                            '${widget.artwork.score}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Artist
                  if (widget.artwork.tagStringArtist?.isNotEmpty == true)
                    Text(
                      'Artist: ${widget.artwork.tagStringArtist}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  
                  // Character
                  if (widget.artwork.tagStringCharacter?.isNotEmpty == true)
                    Text(
                      'Character: ${widget.artwork.tagStringCharacter}',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 