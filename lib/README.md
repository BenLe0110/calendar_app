# Calendar App - Directory Structure

This document explains the organization and responsibilities of each directory in the `lib` folder of the Calendar App.

## Directory Structure

### 📁 widgets/
Contains reusable UI components and custom widgets used throughout the application.
- `daily_view.dart`: Implements the daily calendar view interface
- `monthly_view.dart`: Implements the monthly calendar view interface
- `status_animation.dart`: Custom animation for status indicators
- `loading_animation.dart`: Loading animation components
- `animated_container.dart`: Reusable animated container widget
- `spacing.dart`: Consistent spacing utilities for layout
- `platform_widgets/`: Platform-specific widget implementations
  - `ios/`: iOS-specific widgets using Cupertino design
  - `android/`: Android-specific widgets using Material design

### 📁 theme/
Manages the application's visual styling and theming.
- `app_theme.dart`: Defines the app's color scheme, typography, and overall visual style
- `platform_theme.dart`: Platform-specific theme adaptations
- `responsive.dart`: Responsive design utilities for different screen sizes

### 📁 screens/
Contains the main screens/pages of the application.
- `home_screen.dart`: Main dashboard and calendar view
- `login_screen.dart`: User authentication login interface
- `register_screen.dart`: New user registration interface
- `event_form_screen.dart`: Form for creating and editing calendar events
- Platform-specific screen adaptations:
  - Responsive layouts for different screen sizes
  - Platform-specific navigation patterns
  - Device-specific optimizations

### 📁 services/
Handles business logic and external service interactions.
- `auth_service.dart`: Manages user authentication and authorization
- `event_service.dart`: Handles calendar event operations and data management
- `database/`: Database-related services
  - `sqlite_service.dart`: SQLite database implementation
  - `migrations/`: Database migration scripts
- `platform_services/`: Platform-specific implementations
  - `ios_services.dart`: iOS-specific functionality
  - `android_services.dart`: Android-specific functionality

### 📁 models/
Defines data models and structures used throughout the application.
- `event.dart`: Calendar event data model
- `user.dart`: User profile and preferences data model
- `database/`: Database models and entities
  - `event_entity.dart`: SQLite event table model
  - `user_entity.dart`: SQLite user table model

### 📁 utils/
Contains utility functions and helper classes for common operations.
- `date_utils.dart`: Date manipulation and formatting utilities
- `platform_utils.dart`: Platform-specific helper functions
- `validation_utils.dart`: Form and data validation helpers
- `constants.dart`: Application-wide constants
- `storage_utils.dart`: Local storage helpers

## Platform-Specific Implementation

### iOS Implementation
- Uses Cupertino-style widgets for native iOS feel
- Implements iOS-specific gestures and animations
- Follows iOS Human Interface Guidelines
- Handles iOS-specific permissions and capabilities

### Android Implementation
- Uses Material Design components
- Implements Android-specific navigation patterns
- Follows Material Design guidelines
- Handles Android-specific permissions and features

## File Organization Guidelines

1. Keep related functionality together in appropriate directories
2. Follow Flutter's recommended project structure
3. Maintain separation of concerns between UI, business logic, and data models
4. Use consistent naming conventions across all files
5. Document complex logic and important functions
6. Keep platform-specific code in dedicated directories

## Best Practices

- Keep widgets modular and reusable
- Implement proper error handling in services
- Use dependency injection where appropriate
- Follow Flutter's style guide for code formatting
- Write unit tests for critical functionality
- Maintain platform-specific adaptations
- Follow platform-specific design guidelines
- Use responsive design patterns for different screen sizes

## Database Implementation

### SQLite Structure
- Uses `sqflite` package for database operations
- Implements migrations for schema updates
- Handles platform-specific storage paths
- Implements CRUD operations for all entities

### Data Models
- Clear separation between UI models and database entities
- Proper data validation and type safety
- Efficient data serialization/deserialization
- Platform-specific data handling when needed 