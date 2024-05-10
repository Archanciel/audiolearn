import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {
  @override
  Future<bool> setBool(String key, bool value) {
    return Future.value(true); // Simulate successful save
  }

  @override
  bool? getBool(String key) {
    return true; // Return a default value to simulate the first run
  }  
}
