import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../app_settings.dart';
import 'quiz_screen.dart';
import 'create_quiz_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Color backgroundColor = Colors.blueGrey.shade50;
  StreamSubscription? accelerometerSubscription;

  bool sensorIsActive = false;

  @override
  void initState() {
    super.initState();

    // Lytter til accelerometeret på enheden.
    // Sensoren bruges til at ændre baggrundsfarven,
    // hvis Motion Effects er slået til i Settings.
    accelerometerSubscription = accelerometerEventStream().listen((event) {
      double movement = event.x.abs() + event.y.abs() + event.z.abs();

      setState(() {
        if (!motionEffectsNotifier.value) {
          backgroundColor = Colors.blueGrey.shade50;
          sensorIsActive = false;
          return;
        }

        if (movement > 15 && !sensorIsActive) {
          backgroundColor = Colors.green.shade100;
          sensorIsActive = true;
        } else if (movement <= 15 && sensorIsActive) {
          backgroundColor = Colors.blueGrey.shade50;
          sensorIsActive = false;
        }
      });
    });
  }

  @override
  void dispose() {
    // Stopper sensor-listeneren, når skærmen lukkes.
    accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tjekker om mobilen er i landscape eller portrait.
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Quiz Master'),
        centerTitle: true,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),

          // Landscape: knapper ved siden af hinanden.
          // ScrollView forhindrer overflow på små skærme.
          child: isLandscape
              ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: menuButtons(context),
            ),
          )

          // Portrait: komplet startside med titel, navn og knapper.
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.quiz,
                size: 80,
                color: Colors.green,
              ),

              const SizedBox(height: 20),

              const Text(
                'Quiz Master',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              ValueListenableBuilder<String>(
                valueListenable: userNameNotifier,
                builder: (context, userName, child) {
                  return Text(
                    'Welcome, $userName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              const Text(
                'Test your knowledge with fun questions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 40),

              ...menuButtons(context),

              const SizedBox(height: 30),

              const Text(
                'Rotate or shake the device to change background color',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Menu-knapperne bruges både i portrait og landscape.
  List<Widget> menuButtons(BuildContext context) {
    return [
      SizedBox(
        width: 220,
        height: 50,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Quiz'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuizScreen()),
            );
          },
        ),
      ),

      const SizedBox(width: 20, height: 20),

      SizedBox(
        width: 220,
        height: 50,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Create Quiz'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
            );
          },
        ),
      ),

      const SizedBox(width: 20, height: 20),

      SizedBox(
        width: 220,
        height: 50,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
      ),
    ];
  }
}