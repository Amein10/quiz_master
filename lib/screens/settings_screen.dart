import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController nameController = TextEditingController();

  bool darkMode = false;
  bool motionEffects = true;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  // Henter gemte indstillinger fra enheden.
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nameController.text = prefs.getString('username') ?? '';
      darkMode = prefs.getBool('dark_mode') ?? false;
      motionEffects = prefs.getBool('motion_effects') ?? true;
    });
  }

  // Gemmer alle brugerens indstillinger lokalt.
  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('username', nameController.text);
    await prefs.setBool('dark_mode', darkMode);
    await prefs.setBool('motion_effects', motionEffects);

    userNameNotifier.value =
    nameController.text.isEmpty ? 'Guest' : nameController.text;
    darkModeNotifier.value = darkMode;
    motionEffectsNotifier.value = motionEffects;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings saved'),
      ),
    );
  }

  // Nulstiller kun brugerindstillingerne, ikke quiz-spørgsmål.
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
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
            ),

            const SizedBox(height: 20),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Your name',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    SwitchListTile(
                      title: const Text('Dark mode'),
                      subtitle: const Text('Change the app theme'),
                      value: darkMode,
                      onChanged: (value) {
                        setState(() {
                          darkMode = value;
                        });
                      },
                    ),

                    SwitchListTile(
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
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Save settings'),
                        onPressed: saveSettings,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Reset settings'),
                        onPressed: resetSettings,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}