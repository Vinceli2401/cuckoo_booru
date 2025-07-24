# iOS Build Guide for CuckooBooru

## Prerequisites (macOS Required)

iOS development requires:
- macOS (iOS builds cannot be done on Windows/Linux)
- Xcode (latest version from App Store)
- iOS Simulator or physical iOS device
- Apple Developer Account (for device testing/distribution)

## Setup Complete ✅

The following iOS configurations have been completed:

### 1. Info.plist Configuration
- App metadata and bundle information
- Network security (ATS) settings for HTTP requests
- Required permissions for photo library access
- Orientation support for iPhone and iPad

### 2. iOS Deployment Target
- Set to iOS 12.0+ in Podfile
- Compatible with modern iOS devices

### 3. UI Optimizations
- SafeArea widgets added for iPhone notch/dynamic island
- Bottom navigation with safe area handling
- Responsive padding for different screen sizes

## Build Commands (macOS Only)

### Install Dependencies
```bash
flutter pub get
cd ios && pod install && cd ..
```

### Test in iOS Simulator
```bash
# List available simulators
flutter emulators

# Run in specific simulator
flutter run -d "iPhone 15 Simulator"

# Or run and select device
flutter run
```

### Build for Development
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

### Build IPA for Distribution
```bash
# Archive build
flutter build ipa

# Or with specific configuration
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

## Features Configured for iOS

✅ **Network Requests**: Danbooru API calls with ATS exceptions
✅ **Image Caching**: Optimized for iOS with cached_network_image
✅ **File Storage**: Local favorites/collections using path_provider
✅ **URL Launching**: External links support
✅ **Responsive UI**: iPhone/iPad compatible layouts
✅ **Safe Areas**: Proper handling of notch/dynamic island
✅ **Material Design**: iOS-optimized Material 3 theming

## Testing Checklist

When testing on iOS:

- [ ] App launches without crashes
- [ ] Search functionality works
- [ ] Images load and display correctly
- [ ] Network requests to Danbooru succeed
- [ ] Favorites can be saved/loaded
- [ ] Collections management works
- [ ] Bottom navigation functions properly
- [ ] Safe areas display correctly on different iPhone models
- [ ] Light/dark theme switching works
- [ ] External links open in Safari

## Known iOS Considerations

1. **Network Security**: ATS configured to allow HTTP requests to image boards
2. **File Permissions**: Photo library access for potential image saving
3. **Memory Management**: Large image grids optimized for iOS memory constraints
4. **Performance**: Scrolling performance optimized for iOS devices

## Distribution

For App Store distribution, you'll need:
1. Apple Developer Account ($99/year)
2. App Store Connect setup
3. Code signing certificates
4. App Store Review compliance

The app is ready for iOS development and testing on macOS systems.