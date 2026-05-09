import 'package:flutter/material.dart';
import '../services/quiz_service.dart';
import 'question_detail_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {

  final QuizService quizService = QuizService();

  late Future<List<dynamic>> questions;

  @override
  void initState() {
    super.initState();
    questions = quizService.fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Questions'),
      ),

      body: FutureBuilder<List<dynamic>>(
        future: questions,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading questions'),
            );
          }

          final quizQuestions = snapshot.data!;

          return ListView.builder(
            itemCount: quizQuestions.length,

            itemBuilder: (context, index) {

              final question = quizQuestions[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  title: Text(question['question']),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuestionDetailScreen(question: question),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}