import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cuckoo_booru/models/artwork.dart';

class CollectionManager {
  static const String _collectionsFileName = 'collections.json';

  Future<String> _getCollectionsFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$_collectionsFileName';
  }

  Future<Map<String, dynamic>> _getCollectionsData() async {
    try {
      final filePath = await _getCollectionsFilePath();
      final file = File(filePath);
      
      if (!await file.exists()) {
        return {'collections': <String, dynamic>{}, 'metadata': {'version': '1.0', 'exportDate': DateTime.now().toIso8601String()}};
      }
      
      final contents = await file.readAsString();
      final decoded = json.decode(contents);
      
      if (decoded is Map) {
        final result = Map<String, dynamic>.from(decoded);
        // Ensure collections is properly typed
        if (result['collections'] is Map) {
          result['collections'] = Map<String, dynamic>.from(result['collections'] as Map);
        } else {
          result['collections'] = <String, dynamic>{};
        }
        return result;
      } else {
        return {'collections': <String, dynamic>{}, 'metadata': {'version': '1.0', 'exportDate': DateTime.now().toIso8601String()}};
      }
    } catch (e) {
      return {'collections': <String, dynamic>{}, 'metadata': {'version': '1.0', 'exportDate': DateTime.now().toIso8601String()}};
    }
  }

  Future<void> _saveCollectionsData(Map<String, dynamic> data) async {
    final filePath = await _getCollectionsFilePath();
    final file = File(filePath);
    
    data['metadata'] = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
    };
    
    await file.writeAsString(json.encode(data));
  }

  Future<List<String>> getCollectionNames() async {
    try {
      final data = await _getCollectionsData();
      final collections = data['collections'] as Map<String, dynamic>? ?? <String, dynamic>{};
      return collections.keys.toList();
    } catch (e) {
      return <String>[];
    }
  }

  Future<List<Artwork>> getCollection(String name) async {
    try {
      final data = await _getCollectionsData();
      final collections = data['collections'] as Map<String, dynamic>? ?? <String, dynamic>{};
      
      if (!collections.containsKey(name)) {
        return <Artwork>[];
      }
      
      final artworkData = collections[name];
      if (artworkData is List) {
        return artworkData.map((item) {
          if (item is Map<String, dynamic>) {
            return Artwork.fromJson(item);
          } else if (item is Map) {
            return Artwork.fromJson(Map<String, dynamic>.from(item));
          } else {
            throw Exception('Invalid artwork data format');
          }
        }).toList();
      }
      
      return <Artwork>[];
    } catch (e) {
      return <Artwork>[];
    }
  }

  Future<void> saveCollection(String name, List<Artwork> artworks) async {
    try {
      final data = await _getCollectionsData();
      final collections = data['collections'] as Map<String, dynamic>? ?? <String, dynamic>{};
      
      collections[name] = artworks.map((artwork) => artwork.toJson()).toList();
      data['collections'] = collections;
      
      await _saveCollectionsData(data);
    } catch (e) {
      throw Exception('Failed to save collection: $e');
    }
  }

  Future<void> deleteCollection(String name) async {
    try {
      final data = await _getCollectionsData();
      final collections = data['collections'] as Map<String, dynamic>? ?? <String, dynamic>{};
      
      collections.remove(name);
      data['collections'] = collections;
      
      await _saveCollectionsData(data);
    } catch (e) {
      throw Exception('Failed to delete collection: $e');
    }
  }

  Future<String?> exportCollections() async {
    try {
      final data = await _getCollectionsData();
      
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Export Collections',
        fileName: 'cuckoo_booru_collections_${DateTime.now().millisecondsSinceEpoch}.json',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      
      if (result != null) {
        final file = File(result);
        await file.writeAsString(json.encode(data));
        return result;
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to export collections: $e');
    }
  }

  Future<Map<String, int>> importCollections({bool overwrite = false}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final contents = await file.readAsString();
        final decoded = json.decode(contents);
        final importedData = decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
        
        if (!importedData.containsKey('collections')) {
          throw Exception('Invalid collection file format');
        }
        
        final currentData = await _getCollectionsData();
        final currentCollections = currentData['collections'] as Map<String, dynamic>? ?? <String, dynamic>{};
        
        final importedCollectionsRaw = importedData['collections'];
        final importedCollections = importedCollectionsRaw is Map 
          ? Map<String, dynamic>.from(importedCollectionsRaw) 
          : <String, dynamic>{};
        
        int imported = 0;
        int skipped = 0;
        
        for (final entry in importedCollections.entries) {
          final collectionName = entry.key;
          
          if (currentCollections.containsKey(collectionName) && !overwrite) {
            skipped++;
          } else {
            currentCollections[collectionName] = entry.value;
            imported++;
          }
        }
        
        currentData['collections'] = currentCollections;
        await _saveCollectionsData(currentData);
        
        return {'imported': imported, 'skipped': skipped};
      }
      
      return {'imported': 0, 'skipped': 0};
    } catch (e) {
      throw Exception('Failed to import collections: $e');
    }
  }

  Future<Map<String, dynamic>> getCollectionStats() async {
    try {
      final data = await _getCollectionsData();
      final collections = data['collections'] as Map<String, dynamic>? ?? <String, dynamic>{};
      
      int totalArtworks = 0;
      int totalCollections = collections.length;
      Map<String, int> collectionSizes = <String, int>{};
      
      for (final entry in collections.entries) {
        final artworkData = entry.value;
        if (artworkData is List) {
          final size = artworkData.length;
          collectionSizes[entry.key] = size;
          totalArtworks += size;
        }
      }
      
      return {
        'totalCollections': totalCollections,
        'totalArtworks': totalArtworks,
        'collectionSizes': collectionSizes,
        'averageSize': totalCollections > 0 ? (totalArtworks / totalCollections).round() : 0,
      };
    } catch (e) {
      return {
        'totalCollections': 0,
        'totalArtworks': 0,
        'collectionSizes': <String, int>{},
        'averageSize': 0,
      };
    }
  }
}