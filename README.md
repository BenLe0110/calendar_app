# Calendar App

A modern, user-friendly calendar application built with Flutter that mirrors the aesthetic and functionality of physical calendar products while providing digital conveniences.

## 🌟 Features

- **Multiple View Options**
  - Daily view with hourly breakdown
  - Monthly view with event indicators
  - Smooth transitions between views

- **Event Management**
  - Create, edit, and delete events
  - Event details including title, date, time, and description
  - Visual event indicators on calendar

- **User Experience**
  - Clean, intuitive interface
  - Physical calendar-inspired design
  - Smooth animations and transitions
  - Responsive layout for all screen sizes

- **Platform Support**
  - iOS (14 and above)
  - Android (8.0 and above)
  - Cross-platform compatibility

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (latest stable version)
- Android Studio / VS Code with Flutter extensions
- iOS Simulator (for iOS development)
- Android Emulator (for Android development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/BenLe0110/calendar_app.git
cd calendar_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📱 Platform-Specific Setup

### Android Development

For detailed Android development setup instructions, see [Android Development Guide](android/README.md).

Key requirements for Android development:
- Android Studio 2024.3 or later
- Android SDK Platform 34 (Android 14.0)
- Android SDK Build-Tools 34.0.0
- Android Emulator with API 34
- Flutter and Dart plugins in Android Studio

Common Android-specific features:
- SQLite database for local storage
- Platform-specific UI components
- Android-specific permissions handling
- Custom Android manifest configurations

### iOS Development

For detailed iOS development setup instructions, see [iOS Development Guide](ios/README.md).

Key requirements for iOS development:
- macOS 13.0 or later
- Xcode 14.0 or later
- CocoaPods package manager
- iOS Simulator or physical device running iOS 14.0+
- Apple Developer account (free for development)

Common iOS-specific features:
- Native UI components and animations
- Local data persistence with SQLite
- iOS-specific permissions handling
- Universal app support (iPhone and iPad)
- Proper signing and provisioning profile setup

## 📱 Usage

1. **Browsing the Calendar**
   - Open the app to view the current day
   - Swipe left/right to navigate between days
   - Tap the month view to switch between daily and monthly views

2. **Managing Events**
   - Tap the "+" button to create a new event
   - Fill in event details (title, date, time, description)
   - Tap an existing event to view or edit it
   - Swipe left on an event to delete it

3. **User Account**
   - Create an account to sync events across devices
   - Login to access your personalized calendar
   - Manage your profile and preferences

## 🛠️ Development

The project follows a clean architecture pattern with the following structure:

```
lib/
├── models/      # Data models and database entities
├── screens/     # UI screens and platform-specific adaptations
├── services/    # Business logic and platform services
├── theme/       # App theming and styling
├── utils/       # Utility functions and platform helpers
└── widgets/     # Reusable components and platform-specific widgets
```

For detailed information about the project structure, see [lib/README.md](lib/README.md).

## 🔧 Platform-Specific Development

### Android
- Located in `android/` directory
- Uses Gradle for build system
- Supports multiple Android API levels (8.0+)
- SQLite implementation for local storage
- Material Design components
- Android-specific permissions handling
- Custom Android manifest configurations

### iOS
- Located in `ios/` directory
- Uses CocoaPods for dependency management
- Supports iOS 14 and above
- Universal app support (iPhone and iPad)
- Native UI components and animations
- iOS-specific permissions handling
- Proper signing and provisioning setup

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch using the format:
   - For features: `feature/feature-name`
   - For bugs: `bugfix/bug-name`
   - For tickets: `ticketnumber/ticket-name` (e.g., `MVP-006/ios-platform-support`)
3. Commit your changes using semantic commit messages:
   - Format: `[Ticket-Number]: Brief description`
   - Example: `MVP-006: Add iOS platform support`
4. Push to the branch (`git push origin your-branch-name`)
5. Create a Pull Request with detailed description

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Contributors and maintainers
- Users who provide feedback and suggestions

## 📞 Support

For support, please open an issue in the GitHub repository or contact the development team.

---

Made with ❤️ by Ben Le and the Calendar App Team 