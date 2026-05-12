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
  int customQuestionCount = 0;

  @override
  void initState() {
    super.initState();

    questions = quizRepository.getQuestions();
    loadCustomQuestionCount();
  }

  Future<void> loadCustomQuestionCount() async {
    final count = await quizRepository.getCustomQuestionCount();

    setState(() {
      customQuestionCount = count;
    });
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

  Future<void> refreshQuestions() async {
    setState(() {
      questions = quizRepository.getQuestions();
    });

    await loadCustomQuestionCount();
  }

  Future<void> deleteQuestion(int index) async {
    await quizRepository.deleteCustomQuestion(index);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question deleted'),
      ),
    );

    await refreshQuestions();
  }

  void showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete question'),
          content: const Text('Are you sure you want to delete this question?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteQuestion(index);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
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

          final quizQuestions = snapshot.data ?? [];

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
                    final isCustomQuestion = index < customQuestionCount;

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
                          backgroundColor: isCustomQuestion
                              ? Colors.orange.shade100
                              : Colors.green.shade100,
                          child: Text('${index + 1}'),
                        ),
                        title: Text(
                          cleanText(question['question'].toString()),
                          style: const TextStyle(fontSize: 15),
                        ),
                        subtitle: isCustomQuestion
                            ? const Text('Custom question')
                            : const Text('API question'),
                        trailing: isCustomQuestion
                            ? IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDeleteDialog(index);
                          },
                        )
                            : const Icon(Icons.arrow_forward),
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