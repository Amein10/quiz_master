import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<bool> darkModeNotifier = ValueNotifier(false);
final ValueNotifier<bool> motionEffectsNotifier = ValueNotifier(true);
final ValueNotifier<String> userNameNotifier = ValueNotifier('Guest');

Future<void> loadAppSettings() async {
  final prefs = await SharedPreferences.getInstance();

  darkModeNotifier.value = prefs.getBool('dark_mode') ?? false;
  motionEffectsNotifier.value = prefs.getBool('motion_effects') ?? true;
  userNameNotifier.value = prefs.getString('username') ?? 'Guest';
}