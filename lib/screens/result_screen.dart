import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const ResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  // Beregner hvor mange procent brugeren fik korrekt.
  // Resultatet afrundes til et helt tal.
  int calculatePercentage() {
    if (totalQuestions == 0) {
      return 0;
    }

    return ((score / totalQuestions) * 100).round();
  }

  // Returnerer en kort feedbacktekst baseret på brugerens resultat.
  // Det gør resultatskærmen mere personlig og motiverende.
  String getResultMessage() {
    final percentage = calculatePercentage();

    if (percentage >= 80) {
      return 'Excellent work!';
    }

    if (percentage >= 50) {
      return 'Good job!';
    }

    return 'Keep practicing!';
  }

  // Returnerer en passende farve baseret på resultatet.
  // Grøn = godt resultat, orange = middel, rød = lav score.
  Color getResultColor() {
    final percentage = calculatePercentage();

    if (percentage >= 80) {
      return Colors.green;
    }

    if (percentage >= 50) {
      return Colors.orange;
    }

    return Colors.red;
  }

  // Sender brugeren tilbage til HomeScreen.
  // popUntil lukker alle quiz-skærme på én gang.
  void goBackToHome(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = calculatePercentage();

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Result'),
        centerTitle: true,
      ),

      // Resultatet vises centralt på skærmen i et Card.
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.all(30),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 80,
                  color: getResultColor(),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Quiz Finished!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Viser brugerens score.
                Text(
                  'Score: $score / $totalQuestions',
                  style: const TextStyle(fontSize: 22),
                ),

                const SizedBox(height: 12),

                // Viser procent-resultatet.
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: getResultColor(),
                  ),
                ),

                const SizedBox(height: 12),

                // Kort feedbacktekst baseret på resultatet.
                Text(
                  getResultMessage(),
                  style: TextStyle(
                    fontSize: 18,
                    color: getResultColor(),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      goBackToHome(context);
                    },
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}