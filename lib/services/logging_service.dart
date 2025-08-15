// lib/services/logging_service.dart
import 'package:logger/logger.dart';

class LoggingService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Nombre de méthodes à afficher dans la stack trace
      errorMethodCount: 8, // Nombre de méthodes pour les erreurs
      lineLength: 120, // Largeur des lignes
      colors: true, // Couleurs activées
      printEmojis: true, // Emojis activés
    ),
  );

  // Logger pour la production (sans couleurs, format simple)
  static final Logger _productionLogger = Logger(
    printer: SimplePrinter(printTime: true),
    output: MultiOutput([
      ConsoleOutput(),
      // Vous pouvez ajouter FileOutput() pour sauvegarder dans un fichier
    ]),
  );

  // Détermine quel logger utiliser selon l'environnement
  static Logger get logger {
    // En mode debug, utiliser le logger coloré
    bool isDebug = false;
    assert(isDebug = true); // Cette ligne ne s'exécute qu'en mode debug
    
    return isDebug ? _logger : _productionLogger;
  }

  // Méthodes pratiques pour different niveaux de log
  static void debug(String message) {
    logger.d(message);
  }

  static void info(String message) {
    logger.i(message);
  }

  static void warning(String message) {
    logger.w(message);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }
}

// Extension pour faciliter l'usage dans les classes
extension LoggingExtension on Object {
  void logDebug(String message) => LoggingService.debug('$runtimeType: $message');
  void logInfo(String message) => LoggingService.info('$runtimeType: $message');
  void logWarning(String message) => LoggingService.warning('$runtimeType: $message');
  void logError(String message, [dynamic error, StackTrace? stackTrace]) => 
      LoggingService.error('$runtimeType: $message', error, stackTrace);
}