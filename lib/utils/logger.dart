/// A simple logging utility for the application
class Logger {
  final String _tag;

  /// Create a logger with a specific tag
  Logger(this._tag);

  /// Log an informational message
  void info(String message) {
    _log('INFO', message);
  }

  /// Log a warning message
  void warning(String message) {
    _log('WARNING', message);
  }

  /// Log an error message
  void error(String message, [dynamic error]) {
    _log('ERROR', message + (error != null ? ': $error' : ''));
  }

  /// Log a debug message
  void debug(String message) {
    _log('DEBUG', message);
  }

  void _log(String level, String message) {
    // In a production app, you might want to use a proper logging package
    // like 'logger' or integrate with a crash reporting service
    // For now, we'll use a formatted print that can be easily replaced later
    final timestamp = DateTime.now().toIso8601String();
    // ignore: avoid_print
    print('[$timestamp] $level [$_tag] - $message');
  }
}
