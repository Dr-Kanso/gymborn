# Gymborn App

A fitness-driven idle RPG that connects real-world fitness activities to in-game progression.

## Features

- Real-world fitness data powers in-game progression
- Stats system based on different types of workouts (STR, END, WIS, REC)
- Role-based gameplay with classless progression system
- Dungeons, raids, crafting, and marketplace
- Gym Fortress customization and upgrades
- GPS-based gym check-in and fitness activity verification

## Getting Started

### Prerequisites

- Flutter SDK
- Firebase account
- Google Maps API key
- IDE (VS Code, Android Studio, etc.)

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/gymborn_app.git
cd gymborn_app
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Firebase
- Create a new Firebase project
- Add Android and/or iOS apps to the project
- Download the Firebase configuration files:
  - `google-services.json` for Android
  - `GoogleService-Info.plist` for iOS
- Place these files in the corresponding platform directories
- Run FlutterFire CLI to generate Firebase options:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

4. Configure Google Maps API
- Create a Google Cloud project and enable the Maps SDK
- Generate API keys for the platforms you're targeting
- Add the API keys to your app:
  - For Android: Add to `android/app/src/main/AndroidManifest.xml`
  - For iOS: Add to `ios/Runner/AppDelegate.swift`

5. Run the app
```bash
flutter run
```

## Project Structure
