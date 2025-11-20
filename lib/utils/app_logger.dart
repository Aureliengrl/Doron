/// Classe utilitaire pour les logs de l'application
/// Fournit des méthodes de logging avec préfixes colorés
class AppLogger {
  /// Log de debug (détails techniques)
  static void debug(String message, String tag) {
    print('🔍 [$tag] $message');
  }

  /// Log d'information (événements normaux)
  static void info(String message, String tag) {
    print('ℹ️ [$tag] $message');
  }

  /// Log de succès (opérations réussies)
  static void success(String message, String tag) {
    print('✅ [$tag] $message');
  }

  /// Log d'avertissement (problèmes non critiques)
  static void warning(String message, String tag) {
    print('⚠️ [$tag] $message');
  }

  /// Log d'erreur (problèmes critiques)
  static void error(String message, String tag, dynamic error) {
    print('❌ [$tag] $message');
    if (error != null) {
      print('   Error details: $error');
    }
  }

  /// Log spécifique Firebase
  static void firebase(String message) {
    print('🔥 [Firebase] $message');
  }
}
