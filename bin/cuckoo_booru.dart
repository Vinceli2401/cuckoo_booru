import 'dart:io';
import 'package:args/args.dart';
import 'package:cuckoo_booru/cuckoo_booru.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addCommand('search')
    ..addCommand('favorites')
    ..addCommand('get')
    ..addOption('username', abbr: 'u', help: 'Danbooru username')
    ..addOption('api-key', abbr: 'k', help: 'Danbooru API key')
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show usage information',
    );

  parser.commands['search']!
    ..addOption('tags', abbr: 't', help: 'Tags to search for')
    ..addOption('limit', abbr: 'l', defaultsTo: '20', help: 'Number of results')
    ..addOption(
      'rating',
      abbr: 'r',
      defaultsTo: 'all',
      help: 'Rating filter (s/q/e/all)',
    )
    ..addOption('page', abbr: 'p', defaultsTo: '1', help: 'Page number');

  parser.commands['favorites']!
    ..addOption(
      'action',
      abbr: 'a',
      allowed: ['list', 'add', 'remove'],
      defaultsTo: 'list',
    )
    ..addOption('id', help: 'Post ID for add/remove actions');

  parser.commands['get']!.addOption(
    'id',
    abbr: 'i',
    mandatory: true,
    help: 'Post ID to retrieve',
  );

  try {
    final results = parser.parse(arguments);

    if (results['help'] || results.command == null) {
      printUsage(parser);
      return;
    }

    final service = DanbooruService(
      username: results['username'],
      apiKey: results['api-key'],
    );

    final favoritesManager = FavoritesManager();

    switch (results.command!.name) {
      case 'search':
        await handleSearch(service, results.command!);
        break;
      case 'favorites':
        await handleFavorites(service, favoritesManager, results.command!);
        break;
      case 'get':
        await handleGet(service, results.command!);
        break;
    }

    service.dispose();
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}

void printUsage(ArgParser parser) {
  print('CuckooBooru - Danbooru API wrapper\n');
  print('Usage: cuckoo_booru <command> [options]\n');
  print('Commands:');
  print('  search    Search for posts');
  print('  favorites Manage local favorites');
  print('  get       Get a specific post by ID\n');
  print('Global options:');
  print(parser.usage);
  print('\nSearch options:');
  print(parser.commands['search']!.usage);
  print('\nFavorites options:');
  print(parser.commands['favorites']!.usage);
  print('\nGet options:');
  print(parser.commands['get']!.usage);
}

Future<void> handleSearch(DanbooruService service, ArgResults args) async {
  try {
    final posts = await service.searchPosts(
      tags: args['tags'],
      limit: int.parse(args['limit']),
      page: int.parse(args['page']),
      rating: args['rating'],
    );

    if (posts.isEmpty) {
      print('No posts found.');
      return;
    }

    print('Found ${posts.length} posts:\n');
    for (final post in posts) {
      print(post);
      print('---');
    }
  } catch (e) {
    print('Search failed: $e');
  }
}

Future<void> handleFavorites(
  DanbooruService service,
  FavoritesManager favoritesManager,
  ArgResults args,
) async {
  final action = args['action'];

  try {
    switch (action) {
      case 'list':
        final favorites = await favoritesManager.loadFavorites();
        if (favorites.isEmpty) {
          print('No favorites saved.');
        } else {
          print('Local favorites (${favorites.length}):\n');
          for (final fav in favorites) {
            print(fav);
            print('---');
          }
        }
        break;

      case 'add':
        final idString = args['id'];
        if (idString == null) {
          print('Post ID required for add action.');
          return;
        }

        final id = int.parse(idString);
        final post = await service.getPost(id);

        if (post == null) {
          print('Post not found.');
          return;
        }

        await favoritesManager.addFavorite(post);
        print('Added post #$id to local favorites.');
        break;

      case 'remove':
        final idString = args['id'];
        if (idString == null) {
          print('Post ID required for remove action.');
          return;
        }

        final id = int.parse(idString);
        await favoritesManager.removeFavorite(id);
        print('Removed post #$id from local favorites.');
        break;
    }
  } catch (e) {
    print('Favorites operation failed: $e');
  }
}

Future<void> handleGet(DanbooruService service, ArgResults args) async {
  try {
    final id = int.parse(args['id']);
    final post = await service.getPost(id);

    if (post == null) {
      print('Post #$id not found.');
    } else {
      print(post);
    }
  } catch (e) {
    print('Failed to get post: $e');
  }
}
