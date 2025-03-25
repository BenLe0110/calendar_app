# iOS Development Setup Guide

This guide provides instructions for setting up the iOS development environment for the Calendar App.

## Prerequisites

1. **Xcode**
   - Download and install [Xcode](https://apps.apple.com/us/app/xcode/id497799835) from the Mac App Store
   - Minimum version: 14.0
   - Required macOS version: 13.0 or later
   - Install Xcode Command Line Tools:
     ```bash
     xcode-select --install
     ```

2. **Flutter SDK**
   - Install Flutter SDK (version 3.27.1 or later)
   - Add Flutter to your PATH
   - Run `flutter doctor` to verify installation

3. **CocoaPods**
   - Install via Homebrew:
     ```bash
     brew install cocoapods
     ```
   - Verify installation:
     ```bash
     pod --version
     ```

4. **Apple Developer Account**
   - Free Apple ID for development and testing
   - Apple Developer Program membership ($99/year) for App Store distribution

## Project Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/BenLe0110/calendar_app.git
   cd calendar_app
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

3. **Configure Xcode**
   - Open `ios/Runner.xcworkspace` in Xcode
   - Set up signing:
     - Select Runner project
     - Select Runner target
     - In Signing & Capabilities:
       - Check "Automatically manage signing"
       - Select your development team
       - Configure bundle identifier

4. **Set up iOS Simulator**
   - Open Xcode
   - Go to Xcode > Open Developer Tool > Simulator
   - Select desired iOS device

## Building and Running

1. **Run on Simulator**
   ```bash
   flutter run
   ```

2. **Build for Release**
   ```bash
   flutter build ios
   ```

3. **Archive for App Store**
   - Open Xcode
   - Select Product > Archive
   - Follow App Store submission process

## Project Structure

```
ios/
├── Runner/                 # Main application
│   ├── AppDelegate.swift  # App delegate
│   ├── Info.plist        # App configuration
│   └── Assets.xcassets   # App resources
├── Runner.xcodeproj/      # Xcode project
├── Runner.xcworkspace/    # Xcode workspace
└── Podfile               # CocoaPods configuration
```

## Common Issues and Solutions

1. **Signing Issues**
   - Verify Apple ID setup in Xcode
   - Check bundle identifier format
   - Clean build folder and rebuild
   - Reset signing certificates if needed

2. **Pod Installation Issues**
   - Run `pod deintegrate`
   - Delete Podfile.lock
   - Run `pod install` again
   - Clean and rebuild project

3. **Build Errors**
   - Run `flutter clean`
   - Delete derived data:
     ```bash
     rm -rf ~/Library/Developer/Xcode/DerivedData
     ```
   - Rebuild project

## Development Guidelines

1. **Code Style**
   - Follow Flutter and Swift style guides
   - Use proper indentation
   - Document complex logic

2. **Testing**
   - Test on multiple iOS versions
   - Test on different device sizes
   - Include iPad-specific testing
   - Write unit and widget tests

3. **Performance**
   - Monitor memory usage
   - Optimize database operations
   - Follow iOS-specific best practices

## Additional Resources

- [Flutter iOS Documentation](https://flutter.dev/docs/development/ios-project-setup)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [CocoaPods Guide](https://guides.cocoapods.org/) 