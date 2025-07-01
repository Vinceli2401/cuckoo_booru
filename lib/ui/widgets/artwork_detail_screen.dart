import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/models/artwork.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ArtworkDetailScreen extends StatefulWidget {
  final Artwork artwork;

  const ArtworkDetailScreen({super.key, required this.artwork});

  @override
  State<ArtworkDetailScreen> createState() => _ArtworkDetailScreenState();
}

class _ArtworkDetailScreenState extends State<ArtworkDetailScreen> {
  bool _isFavorite = false;
  bool _hasValidImage = true;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
    _validateImage();
  }

  void _checkFavoriteStatus() async {
    final isFav = await context.read<AppState>().isFavorite(widget.artwork.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
      });
    }
  }

  void _validateImage() {
    final imageUrl = _getBestImageUrl();
    if (imageUrl.isEmpty) {
      setState(() {
        _hasValidImage = false;
      });
    }
  }

  String _getBestImageUrl() {
    if (widget.artwork.fileUrl?.isNotEmpty == true) {
      return widget.artwork.fileUrl!;
    }
    if (widget.artwork.previewFileUrl?.isNotEmpty == true) {
      return widget.artwork.previewFileUrl!;
    }
    return '';
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

  Future<void> _downloadImage() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final imageUrl = _getBestImageUrl();
      if (imageUrl.isEmpty) {
        throw Exception('No image URL available');
      }

      // Get Downloads directory
      final Directory? downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        throw Exception('Could not access Downloads folder');
      }

      // Create filename
      final String extension = imageUrl.split('.').last.split('?').first;
      final String filename = 'cuckoo_booru_${widget.artwork.id}.$extension';
      final String savePath = '${downloadsDir.path}/$filename';

      // Download the image
      final dio = Dio();
      await dio.download(imageUrl, savePath);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image saved to Downloads/$filename'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open Folder',
              onPressed: () async {
                if (Platform.isWindows) {
                  await Process.run('explorer', [downloadsDir.path]);
                }
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
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
            icon: _isDownloading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
            onPressed: _isDownloading ? null : _downloadImage,
            tooltip: 'Download image',
          ),
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
            if (_hasValidImage)
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 600),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: _getBestImageUrl(),
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      height: 300,
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() {
                            _hasValidImage = false;
                          });
                        }
                      });
                      return Container(
                        height: 300,
                        color: Colors.grey[800],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Image not available',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow('ID', '#${widget.artwork.id}'),
                        ),
                        Expanded(
                          child: _buildInfoRow(
                            'Score',
                            '${widget.artwork.score}',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            'Rating',
                            _getRatingText(),
                            color: _getRatingColor(),
                          ),
                        ),
                        Expanded(
                          child: _buildInfoRow(
                            'Date',
                            '${widget.artwork.createdAt.day}/${widget.artwork.createdAt.month}/${widget.artwork.createdAt.year}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tags',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (widget.artwork.tagStringArtist?.isNotEmpty == true)
                      _buildTagSection(
                        'Artist',
                        widget.artwork.tagStringArtist!,
                        Colors.red,
                      ),

                    if (widget.artwork.tagStringCharacter?.isNotEmpty == true)
                      _buildTagSection(
                        'Character',
                        widget.artwork.tagStringCharacter!,
                        Colors.green,
                      ),

                    if (widget.artwork.tagStringCopyright?.isNotEmpty == true)
                      _buildTagSection(
                        'Copyright',
                        widget.artwork.tagStringCopyright!,
                        Colors.purple,
                      ),

                    _buildTagSection(
                      'General',
                      widget.artwork.tagString,
                      Colors.blue,
                    ),
                  ],
                ),
              ),
            ),

            if (widget.artwork.source?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Source',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _launchUrl(widget.artwork.source!),
                        child: Text(
                          widget.artwork.source!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not launch $url')));
      }
    }
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[400],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color ?? Theme.of(context).colorScheme.onSurface,
              fontWeight: color != null ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagSection(String title, String tags, Color color) {
    final tagList = tags.split(' ').where((tag) => tag.isNotEmpty).toList();

    if (tagList.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 2,
            children: tagList.map((tag) {
              return Chip(
                label: Text(
                  tag.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: color.withValues(alpha: 0.1),
                side: BorderSide(color: color.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
