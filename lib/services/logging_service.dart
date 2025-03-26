import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:path/path.dart' as path;

class LoggingService {
  static LoggingService? _instance;
  static final Map<String, Logger> _loggers = {};
  static late File _logFile;
  static bool _initialized = false;

  factory LoggingService() {
    _instance ??= LoggingService._internal();
    return _instance!;
  }

  LoggingService._internal();

  static Future<void> initialize() async {
    if (_initialized) return;

    // Get the app's documents directory
    final dir = await path_provider.getApplicationDocumentsDirectory();
    final logDir = Directory(path.join(dir.path, 'logs'));
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    // Create or get the log file with today's date
    final today = DateTime.now().toIso8601String().split('T')[0];
    _logFile = File(path.join(logDir.path, 'calendar_app_$today.log'));

    // Configure the root logger
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) async {
      final logMessage =
          '${record.time} ${record.level.name} ${record.loggerName}: ${record.message}';

      // Write to file
      await _logFile.writeAsString(
        '$logMessage\n',
        mode: FileMode.append,
      );

      // In debug mode, also print to console
      assert(() {
        print(logMessage);
        return true;
      }());
    });

    _initialized = true;
  }

  static Logger getLogger(String name) {
    if (!_loggers.containsKey(name)) {
      _loggers[name] = Logger(name);
    }
    return _loggers[name]!;
  }

  static Future<List<String>> getLogs({int lastLines = 100}) async {
    if (!await _logFile.exists()) return [];

    final lines = await _logFile.readAsLines();
    return lines.length <= lastLines
        ? lines
        : lines.sublist(lines.length - lastLines);
  }

  static Future<void> clearLogs() async {
    if (await _logFile.exists()) {
      await _logFile.delete();
    }
  }

  static Future<String> getLogFilePath() async {
    return _logFile.path;
  }
}
