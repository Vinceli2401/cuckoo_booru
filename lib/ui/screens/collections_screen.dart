import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cuckoo_booru/services/collection_manager.dart';
import 'package:cuckoo_booru/models/artwork.dart';
import 'package:cuckoo_booru/ui/providers/app_state.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  final CollectionManager _collectionManager = CollectionManager();
  List<String> _collectionNames = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => _isLoading = true);
    try {
      final names = await _collectionManager.getCollectionNames();
      if (mounted) {
        setState(() => _collectionNames = names);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to load collections: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  Future<void> _exportCollections() async {
    setState(() => _isLoading = true);
    try {
      final filePath = await _collectionManager.exportCollections();
      if (filePath != null) {
        _showSuccess('Collections exported successfully to: $filePath');
      }
    } catch (e) {
      _showError('Export failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _importCollections() async {
    final overwrite = await _showImportDialog();
    if (overwrite == null) return;

    setState(() => _isLoading = true);
    try {
      final result = await _collectionManager.importCollections(overwrite: overwrite);
      final imported = result['imported'] ?? 0;
      final skipped = result['skipped'] ?? 0;
      
      if (imported > 0 || skipped > 0) {
        _showSuccess('Import complete: $imported imported, $skipped skipped');
        await _loadCollections();
      }
    } catch (e) {
      _showError('Import failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool?> _showImportDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Collections'),
        content: const Text('What should happen if a collection with the same name already exists?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Skip'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Overwrite'),
          ),
        ],
      ),
    );
  }

  Future<void> _createNewCollection() async {
    final name = await _showCreateCollectionDialog();
    if (name == null || name.trim().isEmpty) return;

    if (_collectionNames.contains(name.trim())) {
      _showError('Collection "$name" already exists');
      return;
    }

    try {
      final favorites = context.read<AppState>().favorites;
      await _collectionManager.saveCollection(name.trim(), favorites);
      _showSuccess('Collection "$name" created with ${favorites.length} items');
      await _loadCollections();
    } catch (e) {
      _showError('Failed to create collection: $e');
    }
  }

  Future<String?> _showCreateCollectionDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create a new collection from your current favorites:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Collection Name',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCollection(String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _collectionManager.deleteCollection(name);
        _showSuccess('Collection "$name" deleted');
        await _loadCollections();
      } catch (e) {
        _showError('Failed to delete collection: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Export Collections'),
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Import Collections'),
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportCollections();
                  break;
                case 'import':
                  _importCollections();
                  break;
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _collectionNames.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.collections_bookmark,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No collections yet',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create your first collection from favorites',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _collectionNames.length,
                  itemBuilder: (context, index) {
                    final name = _collectionNames[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(name),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteCollection(name),
                        ),
                        onTap: () async {
                          try {
                            final artworks = await _collectionManager.getCollection(name);
                            if (mounted) {
                              _showCollectionDetails(name, artworks);
                            }
                          } catch (e) {
                            if (mounted) {
                              _showError('Failed to load collection: $e');
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewCollection,
        tooltip: 'Create Collection from Favorites',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCollectionDetails(String name, List<Artwork> artworks) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${artworks.length} items in this collection'),
            const SizedBox(height: 16),
            if (artworks.isNotEmpty)
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: artworks.length.clamp(0, 9),
                  itemBuilder: (context, index) {
                    final artwork = artworks[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Text(
                          '#${artwork.id}',
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}