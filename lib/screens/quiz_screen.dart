import 'package:flutter/material.dart';
import '../repositories/quiz_repository.dart';
import '../services/quiz_service.dart';
import 'question_detail_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final QuizRepository quizRepository = QuizRepository(
    quizService: QuizService(),
  );

  late Future<List<dynamic>> questions;

  @override
  void initState() {
    super.initState();
    questions = quizRepository.getQuestions();
  }

  String cleanText(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&rsquo;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Quiz Questions'),
        centerTitle: true,
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

          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Choose a question to start the quiz',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: quizQuestions.length,
                  itemBuilder: (context, index) {
                    final question = quizQuestions[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          cleanText(question['question']),
                          style: const TextStyle(fontSize: 15),
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuestionDetailScreen(
                                questions: quizQuestions,
                                currentIndex: index,
                                score: 0,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}