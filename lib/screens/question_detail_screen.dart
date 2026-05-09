import 'package:flutter/material.dart';

class QuestionDetailScreen extends StatelessWidget {
  final dynamic question;

  const QuestionDetailScreen({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final answers = [
      question['correct_answer'],
      ...question['incorrect_answers'],
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Question Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              question['question'],
              style: const TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 30),

            ...answers.map((answer) {
              return Card(
                child: ListTile(
                  title: Text(answer),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You chose: $answer'),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}