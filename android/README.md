# Android Development Setup Guide

This guide provides instructions for setting up the Android development environment for the Calendar App.

## Prerequisites

1. **Android Studio**
   - Download and install [Android Studio](https://developer.android.com/studio)
   - Minimum version: 2024.3
   - Make sure to install:
     - Android SDK
     - Android SDK Platform
     - Android Virtual Device (AVD)

2. **Flutter SDK**
   - Install Flutter SDK (version 3.27.1 or later)
   - Add Flutter to your PATH
   - Run `flutter doctor` to verify installation

3. **Required Android SDK Components**
   - Android SDK Platform 34 (Android 14.0)
   - Android SDK Build-Tools 34.0.0
   - Android SDK Command-line Tools
   - Android SDK Platform-Tools
   - Android Emulator
   - Android SDK Tools

## Project Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/BenLe0110/calendar_app.git
   cd calendar_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Android Studio**
   - Open Android Studio
   - Install Flutter and Dart plugins:
     - Go to File > Settings > Plugins
     - Search for "Flutter" and install
     - Search for "Dart" and install
     - Restart Android Studio

4. **Set up Android Emulator**
   - Open Android Studio
   - Go to Tools > Device Manager
   - Click "Create Device"
   - Select a phone (e.g., Pixel 6)
   - Download and select system image (API 34)
   - Complete the emulator creation

## Building and Running

1. **Run on Emulator**
   ```bash
   flutter run
   ```

2. **Build APK**
   ```bash
   flutter build apk
   ```

3. **Build App Bundle**
   ```bash
   flutter build appbundle
   ```

## Project Structure

```
android/
├── app/                    # Main application module
│   ├── build.gradle       # App-level build configuration
│   └── src/               # Source files
├── build.gradle           # Project-level build configuration
└── settings.gradle        # Project settings
```

## Common Issues and Solutions

1. **SQLite Issues**
   - Ensure proper initialization in `main.dart`
   - Check database path permissions
   - Verify SQLite dependencies in `pubspec.yaml`

2. **Gradle Build Issues**
   - Run `flutter clean`
   - Delete `.gradle` folder
   - Run `flutter pub get`
   - Rebuild project

3. **Emulator Issues**
   - Cold boot the emulator
   - Check AVD settings
   - Verify system image compatibility

## Development Guidelines

1. **Code Style**
   - Follow Flutter's official style guide
   - Use proper indentation and formatting
   - Document complex logic

2. **Testing**
   - Write unit tests for business logic
   - Perform widget tests for UI components
   - Test on multiple Android versions

3. **Performance**
   - Monitor app performance
   - Optimize database operations
   - Handle memory efficiently

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Android Developer Documentation](https://developer.android.com/docs)
- [SQLite Documentation](https://www.sqlite.org/docs.html) 