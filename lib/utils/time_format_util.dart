// lib/utils/time_format_util.dart
class TimeFormatUtil {
  /// Normalise une valeur en secondes à 1 décimale (dixième), via arrondi.
  static double normalizeToTenths(double seconds) {
    if (!seconds.isFinite) return 0.0;
    final int tenthsTotal = (seconds * 10).round();
    return tenthsTotal / 10.0;
  }

  /// Format h:mm:ss.t en se basant sur des dixièmes entiers
  static String formatSeconds(double seconds) {
    if (!seconds.isFinite) seconds = 0.0;
    // Quantification à 0.1 s
    final int tenthsTotal = (seconds * 10).round();
    final int totalSeconds = tenthsTotal ~/ 10; // partie entière en secondes
    final int tenths = tenthsTotal % 10; // reste en dixièmes 0..9
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int secs = totalSeconds % 60;
    final String mm =
        hours > 0 ? minutes.toString().padLeft(2, '0') : '$minutes';
    final String ss = secs.toString().padLeft(2, '0');
    final String h = hours > 0 ? '$hours:' : '';
    return '$h$mm:$ss.$tenths';
  }

  /// Même formatage à partir d'une Duration
  static String formatDuration(Duration d) {
    // d.inMilliseconds → convertir proprement en dixièmes
    final int tenthsTotal = (d.inMilliseconds / 100).round();
    return formatSeconds(tenthsTotal / 10.0);
  }

  /// Parse flexible : "h:mm:ss.t", "mm:ss.t", "ss.t" ou "123.4".
  /// Retourne une valeur normalisée au dixième.
  static double parseFlexible(String input) {
    final s = input.trim();
    if (s.isEmpty) return 0.0;

    // ✅ Détecter et mémoriser le signe négatif
    bool isNegative = s.startsWith('-');
    String workingString = isNegative ? s.substring(1) : s;

    // Pas de colon → nombre brut, puis normaliser
    if (!workingString.contains(':')) {
      final v = double.tryParse(workingString) ?? 0.0;
      final result = normalizeToTenths(v);
      return isNegative ? -result : result;
    }

    try {
      double total = 0.0;
      // Sépare la partie fractionnaire, en gardant uniquement les chiffres
      final parts = workingString.split('.');
      final main = parts[0];
      double frac = 0.0;
      if (parts.length > 1 && parts[1].isNotEmpty) {
        final digits = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.isNotEmpty) {
          // On accepte plus d'un chiffre et on le considère comme décimales,
          // puis normalisation globale au dixième plus bas
          frac = double.tryParse('0.$digits') ?? 0.0;
        }
      }

      final mmss = main.split(':');
      if (mmss.length == 3) {
        final h = int.tryParse(mmss[0]) ?? 0;
        final m = int.tryParse(mmss[1]) ?? 0;
        final sec = int.tryParse(mmss[2]) ?? 0;
        total = h * 3600 + m * 60 + sec + frac;
      } else if (mmss.length == 2) {
        final m = int.tryParse(mmss[0]) ?? 0;
        final sec = int.tryParse(mmss[1]) ?? 0;
        total = m * 60 + sec + frac;
      } else {
        final sec = int.tryParse(mmss[0]) ?? 0;
        total = sec + frac;
      }

      final result = normalizeToTenths(total);
      // ✅ Appliquer le signe négatif au résultat final
      return isNegative ? -result : result;
    } catch (_) {
      return 0.0;
    }
  }

  /// Utilitaire pratique : ajouter/soustraire des dixièmes sans perte.
  static double addTenths(double seconds, int deltaTenths) {
    final int t = (seconds * 10).round() + deltaTenths;
    return t / 10.0;
  }

  /// Arrondir une valeur en secondes au dixième le plus proche.
  /// (561.741 * 10).round() / 10 = 561.7
  /// (561.75 * 10).round() / 10 = 561.8  
  /// (561.749 * 10).round() / 10 = 561.7
  /// (561.751 * 10).round() / 10 = 561.8
  /// (561.79999 * 10).round() / 10 = 561.8
  static double roundToTenthOfSecond({
    required double toBeRounded,
  }) {
    return (toBeRounded * 10).round() / 10;
  }

}
