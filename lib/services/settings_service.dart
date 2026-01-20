import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static const String _settingsBox = 'settings';
  static const String _isFirstRunKey = 'isFirstRun';

  static Future<void> init() async {
    await Hive.openBox(_settingsBox);
  }

  static bool get isFirstRun {
    final box = Hive.box(_settingsBox);
    return box.get(_isFirstRunKey, defaultValue: true);
  }

  static Future<void> setFirstRunCompleted() async {
    final box = Hive.box(_settingsBox);
    await box.put(_isFirstRunKey, false);
  }
}
