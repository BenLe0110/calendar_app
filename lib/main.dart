import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';
import 'package:calendar_app/services/logging_service.dart';
import 'package:logging/logging.dart';
import 'package:calendar_app/screens/login_screen.dart';
import 'package:calendar_app/screens/home_screen.dart';
import 'package:calendar_app/screens/register_screen.dart';
import 'package:calendar_app/theme/app_theme.dart';

// Error widget to show when initialization fails
class ErrorScreen extends StatelessWidget {
  final String error;
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize logging
    await LoggingService.initialize();
    final log = LoggingService.getLogger('main');
    log.info('Starting Calendar App...');

    // Initialize SQLite
    if (!Platform.isAndroid) {
      log.info('Initializing SQLite FFI for non-Android platform');
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    } else {
      log.info('Using default SQLite for Android platform');
    }

    runApp(const MyApp());
    log.info('App started successfully');
  } catch (e, stackTrace) {
    Logger('main').severe('Failed to start app', e, stackTrace);
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text(
              'Failed to start app: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.primaryColor),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
