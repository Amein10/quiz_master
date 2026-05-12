import 'package:flutter/material.dart';
import 'result_screen.dart';

class QuestionDetailScreen extends StatefulWidget {
  final List<dynamic> questions;
  final int currentIndex;
  final int score;

  const QuestionDetailScreen({
    super.key,
    required this.questions,
    required this.currentIndex,
    required this.score,
  });

  @override
  State<QuestionDetailScreen> createState() => _QuestionDetailScreenState();
}

class _QuestionDetailScreenState extends State<QuestionDetailScreen> {
  late List<String> answers;
  String selectedAnswer = '';
  bool hasAnswered = false;
  late int currentScore;

  @override
  void initState() {
    super.initState();

    currentScore = widget.score;

    final question = widget.questions[widget.currentIndex];

    answers = [
      question['correct_answer'].toString(),
      ...List<String>.from(question['incorrect_answers']),
    ];

    answers.shuffle();
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

  void checkAnswer(String answer) {
    if (hasAnswered) return;

    final correctAnswer =
    widget.questions[widget.currentIndex]['correct_answer'].toString();

    setState(() {
      selectedAnswer = answer;
      hasAnswered = true;

      if (answer == correctAnswer) {
        currentScore++;
      }
    });
  }

  Color getAnswerColor(String answer) {
    final correctAnswer =
    widget.questions[widget.currentIndex]['correct_answer'].toString();

    if (!hasAnswered) return Colors.white;

    if (answer == correctAnswer) return Colors.green.shade100;

    if (answer == selectedAnswer) return Colors.red.shade100;

    return Colors.white;
  }

  void goToNextQuestion() {
    final nextIndex = widget.currentIndex + 1;

    if (nextIndex < widget.questions.length) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuestionDetailScreen(
            questions: widget.questions,
            currentIndex: nextIndex,
            score: currentScore,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            score: currentScore,
            totalQuestions: widget.questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[widget.currentIndex];
    final correctAnswer = question['correct_answer'].toString();

    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Quiz'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question ${widget.currentIndex + 1} of ${widget.questions.length}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 16),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Text(
                    cleanText(question['question'].toString()),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ...answers.asMap().entries.map((entry) {
                final index = entry.key;
                final answer = entry.value;
                final letter = String.fromCharCode(65 + index);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: getAnswerColor(answer),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        checkAnswer(answer);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Text(letter),
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Text(
                                cleanText(answer),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              if (hasAnswered)
                Text(
                  selectedAnswer == correctAnswer
                      ? 'Correct!'
                      : 'Wrong! Correct answer: ${cleanText(correctAnswer)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: selectedAnswer == correctAnswer
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

              const SizedBox(height: 20),

              if (hasAnswered)
                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: Text(
                      widget.currentIndex == widget.questions.length - 1
                          ? 'Show Result'
                          : 'Next Question',
                    ),
                    onPressed: goToNextQuestion,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}