import 'package:flutter/material.dart';

import 'app_settings.dart';
import 'screens/home_screen.dart';

// Appens startpunkt.
// main() kører først når appen åbnes.
void main() async {
  // Sikrer at Flutter er initialiseret,
  // før vi bruger async funktioner som SharedPreferences.
  WidgetsFlutterBinding.ensureInitialized();

  // Henter gemte app-indstillinger fra enheden.
  // Det gør at appen starter med de rigtige settings.
  await loadAppSettings();

  // Starter selve Flutter-applikationen.
  runApp(const QuizMasterApp());
}

// Root-widget for hele applikationen.
// Her konfigureres tema, navigation og globale app-indstillinger.
class QuizMasterApp extends StatelessWidget {
  const QuizMasterApp({super.key});

  @override
  Widget build(BuildContext context) {

    // ValueListenableBuilder lytter på darkModeNotifier.
    // Når dark mode ændres i Settings,
    // genbygges MaterialApp automatisk.
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,

      builder: (context, isDarkMode, child) {
        return MaterialApp(
          // Fjerner debug-banneret i øverste højre hjørne.
          debugShowCheckedModeBanner: false,

          title: 'Quiz Master',

          // Skifter mellem light og dark theme.
          themeMode:
          isDarkMode ? ThemeMode.dark : ThemeMode.light,

          // Standard lyst tema.
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
          ),

          // Dark theme.
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
          ),

          // Første skærm der vises når appen åbnes.
          home: const HomeScreen(),
        );
      },
    );
  }
}