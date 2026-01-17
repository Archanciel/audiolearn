// lib/services/settings_data_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class HelpDataService {
  static final HelpDataService _instance = HelpDataService._internal();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Singleton pattern
  factory HelpDataService() {
    return _instance;
  }

  HelpDataService._internal();

  // Initialize SharedPreferences
  Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  // Getter pour accéder aux préférences (optionnel)
  SharedPreferences get prefs {
    if (!_isInitialized) {
      throw Exception(
          'HelpDataService not initialized. Call initialize() first.');
    }
    return _prefs;
  }

  // Vos constantes
  static const String _lastHelpCategoryIdKey = 'last_help_category_id';
  static const String _lastHelpSectionIdKey = 'last_help_section_id';
  static const String _lastHelpStepNumberKey = 'last_help_step_number';

  // Méthodes pour la position dans l'aide
  Future<void> saveLastHelpPosition({
    required String categoryId,
    required String sectionId,
    required int stepNumber,
  }) async {
    await _prefs.setString(_lastHelpCategoryIdKey, categoryId);
    await _prefs.setString(_lastHelpSectionIdKey, sectionId);
    await _prefs.setInt(_lastHelpStepNumberKey, stepNumber);
  }

  String? getLastHelpCategoryId() {
    return _prefs.getString(_lastHelpCategoryIdKey);
  }

  String? getLastHelpSectionId() {
    return _prefs.getString(_lastHelpSectionIdKey);
  }

  int? getLastHelpStepNumber() {
    return _prefs.getInt(_lastHelpStepNumberKey);
  }

  Future<void> clearLastHelpPosition() async {
    await _prefs.remove(_lastHelpCategoryIdKey);
    await _prefs.remove(_lastHelpSectionIdKey);
    await _prefs.remove(_lastHelpStepNumberKey);
  }

  bool hasLastHelpPosition() {
    return _prefs.containsKey(_lastHelpCategoryIdKey) &&
        _prefs.containsKey(_lastHelpSectionIdKey) &&
        _prefs.containsKey(_lastHelpStepNumberKey);
  }
}
