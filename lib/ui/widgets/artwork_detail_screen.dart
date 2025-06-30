import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/models/artwork.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';
import 'package:url_launcher/url_launcher.dart';

class ArtworkDetailScreen extends StatefulWidget {
  final Artwork artwork;

  const ArtworkDetailScreen({super.key, required this.artwork});

  @override
  State<ArtworkDetailScreen> createState() => _ArtworkDetailScreenState();
}

class _ArtworkDetailScreenState extends State<ArtworkDetailScreen> {
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post #${widget.artwork.id}'),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
            tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: widget.artwork.fileUrl ?? widget.artwork.previewFileUrl ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 300,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 64, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Image not available', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Basic Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    _buildInfoRow('Post ID', '#${widget.artwork.id}'),
                    _buildInfoRow('Score', '${widget.artwork.score}'),
                    _buildInfoRow('Rating', _getRatingText(), 
                        color: _getRatingColor()),
                    _buildInfoRow('Created', 
                        '${widget.artwork.createdAt.day}/${widget.artwork.createdAt.month}/${widget.artwork.createdAt.year}'),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Tags Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    if (widget.artwork.tagStringArtist?.isNotEmpty == true)
                      _buildTagSection('Artist', widget.artwork.tagStringArtist!, Colors.red),
                    
                    if (widget.artwork.tagStringCharacter?.isNotEmpty == true)
                      _buildTagSection('Character', widget.artwork.tagStringCharacter!, Colors.green),
                    
                    if (widget.artwork.tagStringCopyright?.isNotEmpty == true)
                      _buildTagSection('Copyright', widget.artwork.tagStringCopyright!, Colors.purple),
                    
                    if (widget.artwork.tagString.isNotEmpty)
                      _buildTagSection('General', widget.artwork.tagString, Colors.blue),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Source Card
            if (widget.artwork.source?.isNotEmpty == true)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Source',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      InkWell(
                        onTap: () => _launchUrl(widget.artwork.source!),
                        child: Text(
                          widget.artwork.source!,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSection(String category, String tags, Color color) {
    final tagList = tags.split(' ').where((tag) => tag.isNotEmpty).toList();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$category:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: tagList.map((tag) => Chip(
              label: Text(
                tag,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: color.withOpacity(0.1),
              side: BorderSide(color: color.withOpacity(0.3)),
            )).toList(),
          ),
        ],
      ),
    );
  }
} 