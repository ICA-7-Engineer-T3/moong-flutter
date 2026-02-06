# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Moong** is an AI-based emotional support pet companion Flutter app with 41 complete screens. The app features three Moong types (Pet, Mate, Guide), a shop system with dual currency, quest system, AI chat, and emotion analysis.

**Status**: UI complete (100%), backend integration pending, web platform has data persistence limitations.

## Development Commands

### Setup & Installation

```bash
# Install dependencies (required after clone)
flutter pub get

# Create missing assets directory if needed
mkdir -p assets/images

# Run code analysis (should pass with 0 critical issues)
flutter analyze
```

### Running the App

```bash
# Run on Chrome (web - recommended for development)
flutter run -d chrome

# Run on specific device
flutter devices                    # List available devices
flutter run -d <device-id>

# Hot reload: press 'r' while app is running
# Hot restart: press 'R' while app is running
```

### Testing

```bash
# Run all tests
flutter test

# Run integration tests
flutter test integration_test

# Run E2E tests (Playwright - requires Node.js)
cd tests
npm install
npx playwright test

# Run E2E tests in UI mode
npm run test:ui

# Run E2E tests with specific browsers
npm run test:chromium
npm run test:firefox
npm run test:webkit
```

### Building

```bash
# Build for web (production)
flutter build web --release

# Build Android APK
flutter build apk --release

# Build Android App Bundle (for Play Store)
flutter build appbundle --release

# Build iOS (macOS only)
flutter build ios --release
```

### Troubleshooting

```bash
# Clean build artifacts and caches
flutter clean && flutter pub get

# Fix iOS pod issues (macOS only)
cd ios && pod deintegrate && pod install && cd ..
```

## Architecture Overview

### Layer Structure

```
Presentation (UI)     → lib/screens/, lib/widgets/
     ↓
Business Logic        → lib/providers/, lib/services/
     ↓
Data Access (DAO)     → lib/database/*_dao.dart
     ↓
Data Models           → lib/models/
     ↓
Persistence           → SQLite (desktop/mobile), Not supported on web
```

### Key Directories

- **`lib/screens/`** - 41 UI screens organized by feature
- **`lib/providers/`** - State management (Provider pattern)
  - `AuthProvider` - User authentication and session
  - `MoongProvider` - Moong state management
- **`lib/database/`** - DAO layer (6 DAOs)
  - `user_dao.dart` - User CRUD operations
  - `moong_dao.dart` - Moong management
  - `quest_dao.dart` - Quest/mission operations
  - `shop_item_dao.dart` - Shop items
  - `user_inventory_dao.dart` - User inventory
  - `chat_message_dao.dart` - Chat history
- **`lib/models/`** - Data models with SQLite serialization
- **`lib/services/`** - Core services
  - `database_helper.dart` - SQLite initialization (singleton)
  - `migration_service.dart` - Data migration
  - `seed_data_service.dart` - Initial data seeding

### Database Schema

6 tables with Foreign Key constraints (CASCADE delete):
1. `users` - User accounts
2. `moongs` - Moong pets (FK: user_id)
3. `quests` - Daily missions (FK: moong_id)
4. `shop_items` - Shop catalog
5. `user_inventory` - User's purchased items (FK: user_id, item_id)
6. `chat_messages` - Chat history (FK: moong_id)

12 indexes for query optimization.

### Routing System

45 named routes defined in `main.dart`. All routes follow pattern: `/screen-name`

Key routes:
- `/` - SplashScreen
- `/login` - LoginScreen
- `/signup` - SignupScreen
- `/moong-select` - Moong type selection
- `/garden` - Main garden view
- `/main-moong` - Moong interaction
- `/chat` - AI chat interface
- `/shop` - Shop main screen
- `/shop-category/:category` - Category-specific shop
- `/quest` - Quest/mission screen
- `/settings` - Settings

## State Management

Uses **Provider** pattern with ChangeNotifier:

```dart
// Accessing state (with rebuild on changes)
final authProvider = Provider.of<AuthProvider>(context);

// Accessing state (without rebuild)
final authProvider = Provider.of<AuthProvider>(context, listen: false);

// Using Consumer for scoped rebuilds
Consumer<AuthProvider>(
  builder: (context, auth, child) => Text(auth.currentUser?.nickname ?? ''),
)
```

**Important**: Always check `if (!mounted) return;` before using `context` after async operations.

## Data Persistence

### Web Platform Limitation

**CRITICAL**: SQLite is NOT supported on web. The app runs on web for demo purposes but **data does not persist** across sessions.

For web persistence, implement one of:
- IndexedDB
- Hive (cross-platform)
- Firebase/Supabase backend
- localStorage with JSON serialization

See `WEB_PLATFORM_NOTES.md` for details.

### Desktop/Mobile Platforms

Uses SQLite via:
- `sqflite` for mobile (Android/iOS)
- `sqflite_common_ffi` for desktop (macOS/Windows/Linux)

Platform detection in `main.dart`:
```dart
if (!kIsWeb) {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
```

## Adding a New Screen

1. **Create screen file**: `lib/screens/my_screen.dart`
2. **Add route**: Import in `main.dart` and add to `routes` map
3. **Navigate**: `Navigator.pushNamed(context, '/my-screen');`

Standard screen template uses:
- Green gradient background (`Color(0xFFE8F5E9)` to `Color(0xFFA5D6A7)`)
- SafeArea wrapper
- Top bar with back button
- Bottom navigation bar with circular icon buttons

See `DEVELOPMENT.md` for detailed screen template.

## Code Style

### Naming Conventions

- Classes: `UpperCamelCase` (e.g., `MyClassName`)
- Variables/functions: `lowerCamelCase` (e.g., `myVariable`)
- Private members: prefix with `_` (e.g., `_privateMethod`)
- Constants: `lowerCamelCase` with `const` (e.g., `const myConstant`)

### Widget Organization

Order within StatefulWidget/State class:
1. State variables
2. Lifecycle methods (`initState`, `dispose`)
3. Business logic methods
4. `build()` method
5. Private UI builder methods (`_buildHeader()`, etc.)

### Import Order

1. Dart SDK imports (`dart:*`)
2. Flutter imports (`package:flutter/*`)
3. External package imports
4. Internal imports (relative paths)

## Testing Strategy

### Integration Tests

Location: `integration_test/`

Run: `flutter test integration_test`

### E2E Tests (Playwright)

Location: `tests/e2e/`

**Important**: Flutter web uses Canvas rendering, so:
- Avoid text-based selectors (won't work)
- Use coordinate-based clicks or `data-testid` attributes
- Add `Semantics(testID: 'button-id')` to widgets for testing

Run: `cd tests && npx playwright test`

See `tests/README.md` for comprehensive E2E testing guide including:
- Parallel test execution
- Browser-specific testing
- Visual regression testing
- Performance testing

## Common Patterns

### Async Operations with Context

```dart
Future<void> _saveData() async {
  await someAsyncOperation();

  // ALWAYS check mounted before using context
  if (!mounted) return;

  Navigator.pop(context);
}
```

### Provider Usage

```dart
// In build method - listens to changes
final user = context.watch<AuthProvider>().currentUser;

// One-time read - no rebuild
final user = context.read<AuthProvider>().currentUser;

// Select specific field
final nickname = context.select<AuthProvider, String?>(
  (auth) => auth.currentUser?.nickname
);
```

### DAO Pattern

All DAO methods are async and follow pattern:
```dart
Future<T> operation() async {
  try {
    final db = await DatabaseHelper.instance.database;
    // Perform operation
    return result;
  } catch (e) {
    debugPrint('Error in operation: $e');
    rethrow;
  }
}
```

## Known Issues & Limitations

1. **Web Platform**: No data persistence (SQLite not supported)
2. **Backend Integration**: Pending - all AI features are UI-only
3. **Authentication**: Local only, no server-side auth
4. **Transactions**: Shop purchases not atomic (future improvement)
5. **Data Backup**: Not implemented
6. **Encryption**: SQLite data not encrypted

## Future Roadmap

See `README.md` for detailed roadmap. Key phases:
1. Backend integration (Firebase/Supabase)
2. AI features (OpenAI GPT for chat, emotion analysis)
3. Web data persistence (IndexedDB/Hive)
4. Social features (friends, trading)
5. Gamification enhancements

## Documentation

- `README.md` - Project overview and statistics
- `ARCHITECTURE.md` - Detailed technical architecture
- `DEVELOPMENT.md` - Development guide and code templates
- `WEB_PLATFORM_NOTES.md` - Web platform limitations
- `tests/README.md` - E2E testing guide
- `docs/API.md` - API specification for backend
- `docs/TESTING.md` - Testing guide and coverage
- `docs/SQLITE_STATUS.md` - SQLite implementation status

## Tech Stack Summary

- **Framework**: Flutter 3.7.2+
- **Language**: Dart ^3.7.2
- **State Management**: Provider ^6.1.2
- **Database**: sqflite ^2.3.0, sqflite_common_ffi ^2.3.0
- **Storage**: shared_preferences ^2.3.3
- **UI**: Material Design 3, flutter_svg ^2.0.10+1
- **Testing**: flutter_test, integration_test, Playwright

## Quick Reference

### Screen Count
- Total: 41 screens (100% complete)
- Authentication: 5 screens
- Moong Management: 8 screens
- Shop System: 6 screens
- Chat: 3 screens
- Quest: 2 screens
- Credit: 4 screens
- Background: 4 screens
- Emotion: 2 screens
- Other: 7 screens

### Currency System
- **Credits**: Premium currency (purchased or earned)
- **Sprouts**: Free currency (earned through quests)

### Moong Types
- **Pet**: Playful companion
- **Mate**: Friendly peer
- **Guide**: Wise mentor

Each type has unique personality traits (UI implementation complete, backend AI pending).
