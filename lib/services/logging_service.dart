// lib/services/logging_service.dart
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Optimized logging service that provides comprehensive logging in debug mode
/// and minimal logging in release mode for optimal performance.
class LoggingService {
  /// Check if we're running in release mode
  static const bool _isReleaseMode = kReleaseMode;
  
  /// Development logger with full features (colors, emojis, detailed stack traces)
  static final Logger _developmentLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,        // Number of methods to show in stack trace
      errorMethodCount: 8,   // Number of methods for errors
      lineLength: 120,       // Line width
      colors: true,          // Enable colors
      printEmojis: true,     // Enable emojis
    ),
  );

  /// Production logger with minimal output (critical errors only)
  static final Logger _productionLogger = Logger(
    printer: SimplePrinter(printTime: true),
    level: Level.error, // Only errors in production
    output: MultiOutput([
      ConsoleOutput(),
      // Optional: FileOutput() to save critical errors to file
    ]),
  );

  /// Returns the appropriate logger based on build mode
  static Logger get _activeLogger {
    return _isReleaseMode ? _productionLogger : _developmentLogger;
  }

  /// Debug logging - completely eliminated in release builds
  /// Use for detailed debugging information that's not needed in production
  static void debug(String message) {
    if (!_isReleaseMode) {
      _activeLogger.d(message);
    }
    // In release: this method does absolutely nothing
  }

  /// Info logging - completely eliminated in release builds
  /// Use for general information about application flow
  static void info(String message) {
    if (!_isReleaseMode) {
      _activeLogger.i(message);
    }
    // In release: this method does absolutely nothing
  }

  /// Warning logging - completely eliminated in release builds
  /// Use for potential issues that don't break functionality
  static void warning(String message) {
    if (!_isReleaseMode) {
      _activeLogger.w(message);
    }
    // In release: this method does absolutely nothing
  }

  /// Error logging - always logged, even in release builds
  /// Use for recoverable errors that should be tracked
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    // Errors are always logged, even in release
    _activeLogger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Critical error logging - always logged with forced output
  /// Use for unrecoverable errors that require immediate attention
  static void criticalError(String message, [dynamic error, StackTrace? stackTrace]) {
    // Force logging even in release mode for critical errors
    if (_isReleaseMode) {
      _productionLogger.e('[CRITICAL] $message', error: error, stackTrace: stackTrace);
    } else {
      _developmentLogger.e('[CRITICAL] $message', error: error, stackTrace: stackTrace);
    }
  }
}

/// Extension to provide convenient logging methods on any object
/// Automatically includes the class name in log messages
extension LoggingExtension on Object {
  /// Debug log with class name prefix
  void logDebug(String message) {
    if (!kReleaseMode) {
      LoggingService.debug('$runtimeType: $message');
    }
  }
  
  /// Info log with class name prefix
  void logInfo(String message) {
    if (!kReleaseMode) {
      LoggingService.info('$runtimeType: $message');
    }
  }
  
  /// Warning log with class name prefix
  void logWarning(String message) {
    if (!kReleaseMode) {
      LoggingService.warning('$runtimeType: $message');
    }
  }
  
  /// Error log with class name prefix - always executed
  void logError(String message, [dynamic error, StackTrace? stackTrace]) {
    LoggingService.error('$runtimeType: $message', error, stackTrace);
  }
  
  /// Critical error log with class name prefix - always executed
  void logCriticalError(String message, [dynamic error, StackTrace? stackTrace]) {
    LoggingService.criticalError('$runtimeType: $message', error, stackTrace);
  }
}