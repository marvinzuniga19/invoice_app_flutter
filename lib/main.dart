import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/database_service.dart';
import 'services/settings_service.dart';
import 'providers/settings_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  await SettingsService.init();
  runApp(const ProviderScope(child: InvoiceApp()));
}

class InvoiceApp extends ConsumerWidget {
  const InvoiceApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch settings state
    final settingsAsync = ref.watch(settingsProvider);

    // settingsProvider is synchronous (returns object, not Future) in my implementation?
    // Let's check settings_provider.dart.
    // It returns SettingsState directly.

    final settings = settingsAsync;

    return MaterialApp(
      title: 'Invoice Generator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      home: settings.isFirstRun ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}
