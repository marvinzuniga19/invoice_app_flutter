import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/company.dart';
import '../services/database_service.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  static const String _settingsBoxName = 'settings';
  static const String _isFirstRunKey = 'isFirstRun';
  static const String _themeModeKey = 'themeMode';

  @override
  SettingsState build() {
    // We can Initialize/Read from Hive synchronously here if the box is open.
    // DatabaseService.init() and generic init() in main opens boxes.
    final box = Hive.box(_settingsBoxName);
    final isFirstRun = box.get(_isFirstRunKey, defaultValue: true);
    final themeModeString = box.get(_themeModeKey, defaultValue: 'system');
    final company = DatabaseService.getCompany();

    ThemeMode themeMode;
    switch (themeModeString) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return SettingsState(
      isFirstRun: isFirstRun,
      company: company,
      themeMode: themeMode,
    );
  }

  Future<void> setFirstRunCompleted() async {
    final box = Hive.box(_settingsBoxName);
    await box.put(_isFirstRunKey, false);

    // Update state
    state = state.copyWith(isFirstRun: false);
  }

  Future<void> updateCompany(Company company) async {
    await DatabaseService.saveCompany(company);
    state = state.copyWith(company: company);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final box = Hive.box(_settingsBoxName);
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      default:
        modeString = 'system';
    }
    await box.put(_themeModeKey, modeString);
    state = state.copyWith(themeMode: mode);
  }
}

class SettingsState {
  final bool isFirstRun;
  final Company company;
  final ThemeMode themeMode;

  SettingsState({
    required this.isFirstRun,
    required this.company,
    required this.themeMode,
  });

  SettingsState copyWith({
    bool? isFirstRun,
    Company? company,
    ThemeMode? themeMode,
  }) {
    return SettingsState(
      isFirstRun: isFirstRun ?? this.isFirstRun,
      company: company ?? this.company,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
