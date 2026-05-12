import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ValueNotifiers bruges til at dele simple globale værdier i appen.
// Når værdien ændres, opdateres widgets automatisk via ValueListenableBuilder.

// Holder styr på om dark mode er slået til.
final ValueNotifier<bool> darkModeNotifier = ValueNotifier(false);

// Holder styr på om accelerometer-effekter er aktiveret.
final ValueNotifier<bool> motionEffectsNotifier = ValueNotifier(true);

// Holder styr på brugerens navn.
final ValueNotifier<String> userNameNotifier = ValueNotifier('Guest');

// Henter appens gemte indstillinger fra SharedPreferences.
// Metoden kaldes ved app-start i main.dart,
// så appen starter med de korrekte værdier.
Future<void> loadAppSettings() async {
  final prefs = await SharedPreferences.getInstance();

  // Henter dark mode-indstillingen.
  // Hvis værdien ikke findes endnu, bruges false som standard.
  darkModeNotifier.value =
      prefs.getBool('dark_mode') ?? false;

  // Henter indstillingen for motion effects.
  // Standard er true, så accelerometer-effekten er aktiv.
  motionEffectsNotifier.value =
      prefs.getBool('motion_effects') ?? true;

  // Henter brugerens navn.
  // Hvis der ikke er gemt et navn, bruges "Guest".
  userNameNotifier.value =
      prefs.getString('username') ?? 'Guest';
}