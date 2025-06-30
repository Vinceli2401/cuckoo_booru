# CuckooBooru

A Dart-based console application for managing fanart collections from Danbooru and similar booru-style imageboards.

## Features

- Search for posts using tag-based queries
- Retrieve individual posts by ID
- Local favorites management
- Support for Danbooru API authentication
- Rate limiting and error handling
- Clean CLI interface

## Installation

1. Clone the repository
2. Install dependencies: `dart pub get`
3. Run the application: `dart run bin/cuckoo_booru.dart`

## Usage

### Basic Search

```bash
dart run bin/cuckoo_booru.dart search --tags "original solo 1girl"
dart run bin/cuckoo_booru.dart search --tags "touhou" --limit 10 --rating s
```

### Get Specific Post

```bash
dart run bin/cuckoo_booru.dart get --id 1234567
```

### Manage Local Favorites

```bash
# List favorites
dart run bin/cuckoo_booru.dart favorites

# Add to favorites
dart run bin/cuckoo_booru.dart favorites --action add --id 1234567

# Remove from favorites
dart run bin/cuckoo_booru.dart favorites --action remove --id 1234567
```

### Using with Authentication

```bash
dart run bin/cuckoo_booru.dart search --username your_username --api-key your_api_key --tags "rating:explicit"
```

## Project Structure

- `bin/cuckoo_booru.dart` - Main CLI entry point
- `lib/danbooru_service.dart` - Danbooru API client
- `lib/models/artwork.dart` - Artwork data model
- `lib/favorites_manager.dart` - Local favorites storage
- `favorites.json` - Local favorites storage file (created automatically)

## API Reference

### DanbooruService

Main service for interacting with the Danbooru API.

### Artwork

Data model representing a Danbooru post with metadata.

### FavoritesManager

Handles local storage and management of favorite posts.

## Development

Run tests: `dart test`
Analyze code: `dart analyze`

## License

MIT License
