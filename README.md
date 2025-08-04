# Gymborn App

A fitness-driven idle RPG that gamifies your workout journey by connecting real-world fitness activities to in-game progression.

## Overview

Gymborn transforms your fitness routine into an engaging RPG experience. Train at real gyms, track your workouts, and watch your character grow stronger as you do. Every rep, every run, and every workout session contributes to your in-game power.

## Features

### Core Gameplay
- **Real-World Fitness Integration**: Your actual workouts directly impact your character's stats and progression
- **Dynamic Stats System**: Four core stats (STR, END, WIS, REC) that grow based on different workout types
- **Classless Progression**: Flexible character development without rigid class restrictions
- **GPS Gym Check-ins**: Verify your gym visits and earn location-based rewards

### Game Modes
- **Dungeons**: Battle through procedurally generated dungeons with real-time combat
- **Raids**: Team up with other players for challenging boss encounters
- **Gym Fortress**: Build and customize your personal gym stronghold
- **Marketplace**: Trade items and equipment with other players
- **Synergy Cards**: Collect and combine cards for powerful buffs

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase account for backend services
- Android Studio / VS Code with Flutter extensions
- Physical device for testing (GPS features)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/gymborn.git
   cd gymborn
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Configure Firebase:
   - Create a new Firebase project
   - Add your Android/iOS apps to the project
   - Download and add the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
gymborn/
├── lib/
│   ├── app.dart                 # Main app configuration
│   ├── main.dart                # Entry point
│   ├── components/              # Reusable UI components
│   ├── frontend_screens/        # App screens
│   ├── game/                    # Game engine and logic
│   ├── models/                  # Data models
│   ├── providers/               # State management
│   ├── services/                # Backend services
│   ├── themes/                  # App theming
│   └── utils/                   # Utility functions
├── assets/                      # Images, animations, fonts
├── android/                     # Android-specific files
├── ios/                         # iOS-specific files
└── web/                         # Web-specific files
```

## Development

### Running Tests
```bash
flutter test
```

### Building for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release
```

## Technologies Used

- **Flutter**: Cross-platform mobile framework
- **Firebase**: Backend services (Auth, Firestore, etc.)
- **Flame**: 2D game engine for Flutter
- **Provider**: State management
- **OpenStreetMap**: Map services
- **Geolocator**: GPS functionality

## Contributing

We welcome contributions! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Attribution

This application uses OpenStreetMap data. © OpenStreetMap contributors.
Learn more: https://www.openstreetmap.org/copyright

## Contact

For questions or support, please open an issue on GitHub.
