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
  // Repository bruges til at hente quizspørgsmål.
  // Det skjuler om spørgsmålene kommer fra API'et eller lokal storage.
  final QuizRepository quizRepository = QuizRepository(
    quizService: QuizService(),
  );

  late Future<List<dynamic>> questions;

  // Bruges til at finde ud af hvilke spørgsmål der er brugeroprettede.
  // Custom questions vises øverst og kan slettes.
  int customQuestionCount = 0;

  @override
  void initState() {
    super.initState();

    loadQuestions();
    loadCustomQuestionCount();
  }

  // Henter alle spørgsmål til skærmen.
  // Repository samler både custom questions og API questions i én liste.
  void loadQuestions() {
    questions = quizRepository.getQuestions();
  }

  // Henter antal brugeroprettede spørgsmål.
  // Det bruges til at vise delete-knap kun på egne spørgsmål.
  Future<void> loadCustomQuestionCount() async {
    final count = await quizRepository.getCustomQuestionCount();

    setState(() {
      customQuestionCount = count;
    });
  }

  // API'et returnerer nogle gange HTML-tegn som &quot; og &#039;.
  // Denne metode gør teksten mere læsbar i brugergrænsefladen.
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

  // Genindlæser spørgsmålene efter fx sletning af et custom question.
  // setState sikrer, at FutureBuilder bygger listen igen.
  Future<void> refreshQuestions() async {
    setState(() {
      questions = quizRepository.getQuestions();
    });

    await loadCustomQuestionCount();
  }

  // Sletter et brugeroprettet spørgsmål.
  // Efter sletning vises en besked, og listen opdateres.
  Future<void> deleteQuestion(int index) async {
    await quizRepository.deleteCustomQuestion(index);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Question deleted'),
      ),
    );

    await refreshQuestions();
  }

  // Viser en bekræftelsesdialog inden et spørgsmål slettes.
  // Det forhindrer, at brugeren sletter et spørgsmål ved et uheld.
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

  // Åbner quiz-skærmen for det valgte spørgsmål.
  // Hele listen sendes med, så brugeren kan fortsætte til næste spørgsmål.
  void openQuestion(List<dynamic> quizQuestions, int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Quiz Questions'),
        centerTitle: true,
      ),

      // FutureBuilder bruges, fordi spørgsmålene hentes asynkront.
      // Mens data hentes, vises en loading spinner.
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

          if (quizQuestions.isEmpty) {
            return const Center(
              child: Text('No questions found'),
            );
          }

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

                    // Custom questions ligger øverst i listen.
                    // Derfor kan vi bruge index til at tjekke, om spørgsmålet er custom.
                    final isCustomQuestion = index < customQuestionCount;

                    return questionCard(
                      question: question,
                      index: index,
                      isCustomQuestion: isCustomQuestion,
                      quizQuestions: quizQuestions,
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

  // Bygger et enkelt spørgsmål i listen.
  // Custom questions får orange ikon og delete-knap.
  // API questions får grønt ikon og pil frem.
  Widget questionCard({
    required dynamic question,
    required int index,
    required bool isCustomQuestion,
    required List<dynamic> quizQuestions,
  }) {
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
          backgroundColor:
          isCustomQuestion ? Colors.orange.shade100 : Colors.green.shade100,
          child: Text('${index + 1}'),
        ),

        title: Text(
          cleanText(question['question'].toString()),
          style: const TextStyle(fontSize: 15),
        ),

        subtitle: Text(
          isCustomQuestion ? 'Custom question' : 'API question',
        ),

        trailing: isCustomQuestion
            ? IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            showDeleteDialog(index);
          },
        )
            : const Icon(Icons.arrow_forward),

        onTap: () {
          openQuestion(quizQuestions, index);
        },
      ),
    );
  }
}