# Moong - AI Pet Companion (Web Version)

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat&logo=dart&logoColor=white)
![Web](https://img.shields.io/badge/Platform-Web-blue)
![Status](https://img.shields.io/badge/Status-Complete-success)
![Screens](https://img.shields.io/badge/Screens-41%2F41-green)
![Progress](https://img.shields.io/badge/Progress-100%25-brightgreen)

AI-powered emotional support pet companion application built with Flutter.

## Overview

**Moong** is an AI-based emotional support pet companion service that understands and supports user emotions. This web version showcases the complete UI implementation with 41 fully functional screens, ready for backend integration.

## Features

### Core Features
- **3 Moong Types**: Pet, Mate, Guide - each with unique personalities
- **41 Complete Screens**: 100% UI implementation
- **AI Chat System**: Real-time chat interface (backend integration pending)
- **Shop System**: 5 categories (Clothing, Accessories, Furniture, Backgrounds, Seasonal)
- **Dual Currency**: Sprout/Credit system with earning mechanisms
- **Quest System**: Daily step goals (3000/7000/10000 steps)
- **Emotion Analysis**: AI-based emotion tracking interface
- **Music Generation**: 8-slider emotion-based music creation
- **Background Themes**: 4 themes (Forest, Beach, Space, Cherry Blossom)

### Technical Highlights
- Clean architecture with Provider state management
- Responsive web design
- Comprehensive routing system (45 named routes)
- Professional UI/UX polish
- E2E testing infrastructure (Playwright)

## Important: Web Platform Limitations

**Data Persistence Not Available on Web**

This web version uses SQLite for data persistence, which is **not supported in web browsers**. The complete UI is functional for demonstration purposes, but data will not persist across sessions.

**What Works:**
- All 41 screens render perfectly
- Navigation and routing
- Provider state management (in-memory)
- UI interactions and animations

**What Doesn't Work:**
- Data persistence (no database storage)
- Login state persistence
- Moong creation/deletion persistence
- Shop purchases persistence

**Recommended Solutions:**
- Implement IndexedDB for browser storage
- Use Hive for cross-platform persistence
- Integrate Firebase/Supabase backend
- Add localStorage with JSON serialization

See [WEB_PLATFORM_NOTES.md](WEB_PLATFORM_NOTES.md) for detailed technical information.

## Tech Stack

- **Frontend**: Flutter 3.7.2+
- **Language**: Dart 3.7.2+
- **State Management**: Provider
- **Storage**: SQLite (not web-compatible) + SharedPreferences
- **Testing**: Integration tests + Playwright E2E tests
- **Platform**: Web (responsive design)

## Project Structure

```
moong-flutter/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models (User, Moong, Item, Quest)
│   ├── providers/                # State management (AuthProvider, MoongProvider)
│   ├── services/                 # Database services and DAOs
│   ├── screens/                  # 41 UI screens
│   │   ├── auth/                 # Authentication (5 screens)
│   │   ├── moong/                # Moong management (8 screens)
│   │   ├── chat/                 # AI chat (3 screens)
│   │   ├── shop/                 # Shop system (6 screens)
│   │   ├── credit/               # Credit management (4 screens)
│   │   ├── background/           # Background collection (4 screens)
│   │   ├── emotion/              # Emotion state (2 screens)
│   │   └── misc/                 # Other screens (9 screens)
│   └── widgets/                  # Reusable components
├── web/                          # Web platform files
├── assets/                       # Images and resources
├── test/                         # Unit tests
├── integration_test/             # Integration tests
├── tests/                        # E2E tests (Playwright)
└── docs/                         # Additional documentation
```

## Getting Started

### Prerequisites

- Flutter SDK 3.7.2 or higher
- Chrome browser (for development)
- Git

### Installation

```bash
# Clone repository
git clone https://github.com/ICA-7-Engineer-T3/moong-flutter.git
cd moong-flutter

# Install dependencies
flutter pub get

# Run analysis (should pass with 0 issues)
flutter analyze

# Run web app
flutter run -d chrome

# Build for production
flutter build web --release
```

### Running Tests

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Run E2E tests (requires Playwright)
cd tests
npm install
npx playwright test
```

## Development

See [DEVELOPMENT.md](DEVELOPMENT.md) for detailed development guidelines including:
- Code structure and organization
- State management patterns
- Naming conventions
- Testing requirements

## Architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for comprehensive technical documentation including:
- System architecture overview
- Data flow diagrams
- Component relationships
- Storage layer design

## Implementation Status

| Category | Screens | Status |
|----------|---------|--------|
| Authentication & Onboarding | 5 | ✅ Complete |
| Moong Management | 8 | ✅ Complete |
| Interactions | 9 | ✅ Complete |
| Shop System | 6 | ✅ Complete |
| Credit System | 4 | ✅ Complete |
| Background Collection | 4 | ✅ Complete |
| Emotion State | 2 | ✅ Complete |
| Other | 3 | ✅ Complete |
| **Total** | **41** | **✅ 100%** |

### Current State
- ✅ 41/41 Screens Complete (100%)
- ✅ State Management (Provider)
- ✅ Routing & Navigation (45 routes)
- ✅ UI/UX Polish
- ✅ E2E Testing Infrastructure
- ⚠️ Backend Integration (pending)
- ⚠️ Web Data Persistence (requires implementation)

## Documentation

### Essential Documentation
- [README.md](README.md) - This file
- [WEB_PLATFORM_NOTES.md](WEB_PLATFORM_NOTES.md) - Web platform limitations and solutions
- [ARCHITECTURE.md](ARCHITECTURE.md) - Technical architecture overview
- [DEVELOPMENT.md](DEVELOPMENT.md) - Development setup and guidelines

### Additional Documentation
- [API.md](docs/API.md) - API specification for backend integration
- [SQLITE_STATUS.md](docs/SQLITE_STATUS.md) - SQLite implementation status
- [TESTING.md](docs/TESTING.md) - Testing guide and coverage
- [USECASES.md](docs/USECASES.md) - User scenarios and use cases
- [PLAYBOOK.md](docs/PLAYBOOK.md) - Project development playbook
- [COMPLETION_SUMMARY.md](docs/COMPLETION_SUMMARY.md) - Project completion summary

## Future Roadmap

### Phase 1: Backend Integration
- Set up Firebase or Supabase backend
- Implement authentication API
- Add data persistence endpoints
- Real-time sync capabilities

### Phase 2: AI Features
- Integrate OpenAI GPT for chat
- Implement emotion analysis engine
- Add music generation logic
- Personalized recommendations

### Phase 3: Web Data Persistence
- Replace SQLite with IndexedDB
- Or implement Hive for cross-platform support
- Or use cloud storage (Firebase/Supabase)
- Offline-first architecture

### Phase 4: Social Features
- User profiles and friends
- Moong sharing and trading
- Community challenges
- Leaderboards

### Phase 5: Gamification Enhancements
- Achievement system
- Daily rewards
- Special events
- Seasonal content

## Statistics

- **Total Lines of Code**: ~14,821 LOC
- **Screens**: 41/41 (100%)
- **Compile Errors**: 0
- **Analysis Warnings**: 0
- **Build Time**: ~11 seconds
- **Test Coverage**: Integration tests implemented

## Contributing

This is a portfolio project for ICA-7-Engineer-T3. Contributions are welcome for:
- Backend integration implementations
- Web storage solutions
- AI feature integrations
- UI/UX improvements
- Bug fixes and optimizations

## License

This project is available for educational and portfolio purposes.

## Contact

Created for **ICA-7-Engineer-T3**

Project Completed: 2026-02-03

---

**Made with Flutter** | *Web Version Showcase*
