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
  // Standard baggrundsfarve for HomeScreen.
  // Farven ændres midlertidigt, hvis brugeren roterer eller ryster enheden.
  Color backgroundColor = Colors.blueGrey.shade50;

  // Subscription bruges til at lytte til accelerometeret.
  // Den gemmes i en variabel, så vi senere kan stoppe den i dispose().
  StreamSubscription? accelerometerSubscription;

  // Holder styr på om sensor-effekten allerede er aktiv.
  // Det forhindrer, at baggrundsfarven skifter frem og tilbage meget hurtigt.
  bool sensorIsActive = false;

  @override
  void initState() {
    super.initState();

    startAccelerometerListener();
  }

  // Starter en listener til enhedens accelerometer.
  // Accelerometeret giver X, Y og Z værdier, som ændrer sig når enheden bevæges.
  // Her bruges de værdier til at ændre baggrundsfarven på HomeScreen.
  void startAccelerometerListener() {
    accelerometerSubscription = accelerometerEventStream().listen((event) {
      final double movement = event.x.abs() + event.y.abs() + event.z.abs();

      setState(() {
        updateBackgroundFromMotion(movement);
      });
    });
  }

  // Opdaterer baggrundsfarven baseret på bevægelse.
  // Hvis Motion Effects er slået fra i Settings, bliver baggrunden normal.
  // Hvis bevægelsen er høj nok, skiftes baggrunden til grøn.
  void updateBackgroundFromMotion(double movement) {
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
  }

  @override
  void dispose() {
    // Stopper accelerometer-listeneren, når skærmen lukkes.
    // Det er vigtigt, så appen ikke fortsætter med at lytte i baggrunden.
    accelerometerSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MediaQuery bruges til at tjekke om enheden er i portrait eller landscape.
    // Det gør det muligt at vise et responsivt layout.
    final bool isLandscape =
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

          // I landscape vises kun knapperne vandret.
          // SingleChildScrollView sikrer, at layoutet ikke crasher på små skærme.
          child: isLandscape
              ? buildLandscapeLayout(context)

          // I portrait vises en mere komplet startside med logo, titel og tekst.
              : buildPortraitLayout(context),
        ),
      ),
    );
  }

  // Layout til portrait mode.
  // Her får brugeren en fuld startside med ikon, titel, velkomsttekst og menu.
  Widget buildPortraitLayout(BuildContext context) {
    return Column(
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

        // Viser brugerens gemte navn fra app_settings.dart.
        // Når navnet ændres i Settings, opdateres teksten automatisk.
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
    );
  }

  // Layout til landscape mode.
  // Her vises knapperne vandret, så skærmpladsen udnyttes bedre.
  Widget buildLandscapeLayout(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: menuButtons(context),
      ),
    );
  }

  // Samler menu-knapperne ét sted.
  // De samme knapper genbruges både i portrait og landscape.
  List<Widget> menuButtons(BuildContext context) {
    return [
      menuButton(
        icon: Icons.play_arrow,
        label: 'Start Quiz',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QuizScreen()),
          );
        },
      ),

      const SizedBox(width: 20, height: 20),

      menuButton(
        icon: Icons.add,
        label: 'Create Quiz',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
          );
        },
      ),

      const SizedBox(width: 20, height: 20),

      menuButton(
        icon: Icons.settings,
        label: 'Settings',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
    ];
  }

  // Genbrugelig knap-widget.
  // Det gør koden renere, fordi alle menu-knapper har samme størrelse og design.
  Widget menuButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 220,
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }
}