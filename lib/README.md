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

### 📁 theme/
Manages the application's visual styling and theming.
- `app_theme.dart`: Defines the app's color scheme, typography, and overall visual style

### 📁 screens/
Contains the main screens/pages of the application.
- `home_screen.dart`: Main dashboard and calendar view
- `login_screen.dart`: User authentication login interface
- `register_screen.dart`: New user registration interface
- `event_form_screen.dart`: Form for creating and editing calendar events

### 📁 services/
Handles business logic and external service interactions.
- `auth_service.dart`: Manages user authentication and authorization
- `event_service.dart`: Handles calendar event operations and data management

### 📁 models/
Defines data models and structures used throughout the application.
- `event.dart`: Calendar event data model
- `user.dart`: User profile and preferences data model

### 📁 utils/
Contains utility functions and helper classes for common operations.
- Currently empty but reserved for future utility functions

## File Organization Guidelines

1. Keep related functionality together in appropriate directories
2. Follow Flutter's recommended project structure
3. Maintain separation of concerns between UI, business logic, and data models
4. Use consistent naming conventions across all files
5. Document complex logic and important functions

## Best Practices

- Keep widgets modular and reusable
- Implement proper error handling in services
- Use dependency injection where appropriate
- Follow Flutter's style guide for code formatting
- Write unit tests for critical functionality 