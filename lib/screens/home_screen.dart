import 'package:flutter/material.dart';
import 'quiz_screen.dart';
import 'create_quiz_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Master'),
        centerTitle: true,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: isLandscape
              ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: menuButtons(context),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: menuButtons(context),
          ),
        ),
      ),
    );
  }

  List<Widget> menuButtons(BuildContext context) {
    return [
      ElevatedButton(
        child: const Text('Start Quiz'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QuizScreen()),
          );
        },
      ),

      const SizedBox(width: 20, height: 20),

      ElevatedButton(
        child: const Text('Create Quiz'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateQuizScreen()),
          );
        },
      ),

      const SizedBox(width: 20, height: 20),

      ElevatedButton(
        child: const Text('Settings'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
        },
      ),
    ];
  }
}