import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/company.dart';
import '../services/database_service.dart';

part 'settings_provider.g.dart';

@riverpod
class Settings extends _$Settings {
  static const String _settingsBoxName = 'settings';
  static const String _isFirstRunKey = 'isFirstRun';

  @override
  SettingsState build() {
    // We can Initialize/Read from Hive synchronously here if the box is open.
    // DatabaseService.init() and generic init() in main opens boxes.
    final box = Hive.box(_settingsBoxName);
    final isFirstRun = box.get(_isFirstRunKey, defaultValue: true);
    final company = DatabaseService.getCompany();

    return SettingsState(isFirstRun: isFirstRun, company: company);
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
}

class SettingsState {
  final bool isFirstRun;
  final Company company;

  SettingsState({required this.isFirstRun, required this.company});

  SettingsState copyWith({bool? isFirstRun, Company? company}) {
    return SettingsState(
      isFirstRun: isFirstRun ?? this.isFirstRun,
      company: company ?? this.company,
    );
  }
}
