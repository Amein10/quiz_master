import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Controller bruges til at læse og ændre teksten i navnefeltet.
  final TextEditingController nameController = TextEditingController();

  // Bruges til switches i settings-menuen.
  bool darkMode = false;
  bool motionEffects = true;

  @override
  void initState() {
    super.initState();

    loadSettings();
  }

  // Henter gemte indstillinger fra SharedPreferences.
  // Disse værdier gemmes lokalt på enheden og bevares efter appen lukkes.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nameController.text = prefs.getString('username') ?? '';

      darkMode = prefs.getBool('dark_mode') ?? false;

      motionEffects = prefs.getBool('motion_effects') ?? true;
    });
  }

  // Gemmer brugerens indstillinger lokalt på enheden.
  // ValueNotifiers opdateres samtidig, så resten af appen reagerer med det samme.
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'username',
      nameController.text.trim(),
    );

    await prefs.setBool(
      'dark_mode',
      darkMode,
    );

    await prefs.setBool(
      'motion_effects',
      motionEffects,
    );

    // Opdaterer globale notifiers.
    // Det gør at fx HomeScreen automatisk viser det nye navn.
    userNameNotifier.value = nameController.text.trim().isEmpty
        ? 'Guest'
        : nameController.text.trim();

    darkModeNotifier.value = darkMode;

    motionEffectsNotifier.value = motionEffects;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
      ),
    );
  }

  // Nulstiller kun app-indstillingerne.
  // Custom quiz-spørgsmål bliver ikke slettet.
  Future<void> resetSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('username');

    await prefs.setBool('dark_mode', false);

    await prefs.setBool('motion_effects', true);

    setState(() {
      nameController.clear();

      darkMode = false;

      motionEffects = true;
    });

    // Gendanner standardværdier i hele appen.
    userNameNotifier.value = 'Guest';

    darkModeNotifier.value = false;

    motionEffectsNotifier.value = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset'),
      ),
    );
  }

  @override
  void dispose() {
    // Controller skal dispose når skærmen lukkes.
    // Det forhindrer unødigt hukommelsesforbrug.
    nameController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),

      // ScrollView gør skærmen fleksibel på små enheder og ved åbent tastatur.
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            buildProfileCard(),

            const SizedBox(height: 20),

            buildSettingsCard(),
          ],
        ),
      ),
    );
  }

  // Profil-sektion øverst på siden.
  // Viser ikon og kort beskrivelse af settings-menuen.
  Widget buildProfileCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: const Padding(
        padding: EdgeInsets.all(24),

        child: Column(
          children: [
            Icon(
              Icons.person,
              size: 70,
              color: Colors.green,
            ),

            SizedBox(height: 12),

            Text(
              'Profile Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 6),

            Text(
              'Manage your quiz preferences',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Kortet der indeholder alle indstillinger.
  Widget buildSettingsCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            buildNameField(),

            const SizedBox(height: 20),

            buildDarkModeSwitch(),

            buildMotionEffectsSwitch(),

            const SizedBox(height: 20),

            buildSaveButton(),

            const SizedBox(height: 12),

            buildResetButton(),
          ],
        ),
      ),
    );
  }

  // Inputfelt til brugerens navn.
  Widget buildNameField() {
    return TextField(
      controller: nameController,
      decoration: const InputDecoration(
        labelText: 'Your name',
        border: OutlineInputBorder(),
      ),
    );
  }

  // Switch til dark mode.
  // Theme-systemet er simpelt, men viser hvordan brugerindstillinger kan ændre appens UI.
  Widget buildDarkModeSwitch() {
    return SwitchListTile(
      title: const Text('Dark mode'),
      subtitle: const Text('Change the app theme'),

      value: darkMode,

      onChanged: (value) {
        setState(() {
          darkMode = value;
        });
      },
    );
  }

  // Switch til motion effects.
  // Når den er slået til, kan accelerometeret ændre baggrundsfarven.
  Widget buildMotionEffectsSwitch() {
    return SwitchListTile(
      title: const Text('Motion effects'),
      subtitle: const Text(
        'Use accelerometer to change background color',
      ),

      value: motionEffects,

      onChanged: (value) {
        setState(() {
          motionEffects = value;
        });
      },
    );
  }

  // Knap der gemmer brugerens indstillinger.
  Widget buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,

      child: ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: const Text('Save settings'),
        onPressed: saveSettings,
      ),
    );
  }

  // Knap der nulstiller indstillingerne til standardværdier.
  Widget buildResetButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,

      child: OutlinedButton.icon(
        icon: const Icon(Icons.restart_alt),
        label: const Text('Reset settings'),
        onPressed: resetSettings,
      ),
    );
  }
}