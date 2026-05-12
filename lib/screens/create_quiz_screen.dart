import 'package:flutter/material.dart';
import '../repositories/quiz_repository.dart';
import '../services/quiz_service.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final questionController = TextEditingController();
  final answerAController = TextEditingController();
  final answerBController = TextEditingController();
  final answerCController = TextEditingController();
  final answerDController = TextEditingController();

  final QuizRepository quizRepository = QuizRepository(
    quizService: QuizService(),
  );

  String correctAnswer = 'A';

  Future<void> saveQuiz() async {
    if (questionController.text.isEmpty ||
        answerAController.text.isEmpty ||
        answerBController.text.isEmpty ||
        answerCController.text.isEmpty ||
        answerDController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields'),
        ),
      );
      return;
    }

    final answers = {
      'A': answerAController.text,
      'B': answerBController.text,
      'C': answerCController.text,
      'D': answerDController.text,
    };

    final customQuestion = {
      'question': questionController.text,
      'correct_answer': answers[correctAnswer],
      'incorrect_answers': answers.entries
          .where((entry) => entry.key != correctAnswer)
          .map((entry) => entry.value)
          .toList(),
    };

    await quizRepository.saveCustomQuestion(customQuestion);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quiz question saved'),
      ),
    );

    questionController.clear();
    answerAController.clear();
    answerBController.clear();
    answerCController.clear();
    answerDController.clear();

    setState(() {
      correctAnswer = 'A';
    });
  }

  @override
  void dispose() {
    questionController.dispose();
    answerAController.dispose();
    answerBController.dispose();
    answerCController.dispose();
    answerDController.dispose();
    super.dispose();
  }

  Widget answerField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Answer $label',
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade50,
      appBar: AppBar(
        title: const Text('Create Quiz'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.add_circle_outline,
                  size: 70,
                  color: Colors.green,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Create your own question',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: questionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Question',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                answerField('A', answerAController),
                answerField('B', answerBController),
                answerField('C', answerCController),
                answerField('D', answerDController),

                const SizedBox(height: 10),

                const Text(
                  'Correct answer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                DropdownButton<String>(
                  value: correctAnswer,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'A', child: Text('Answer A')),
                    DropdownMenuItem(value: 'B', child: Text('Answer B')),
                    DropdownMenuItem(value: 'C', child: Text('Answer C')),
                    DropdownMenuItem(value: 'D', child: Text('Answer D')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      correctAnswer = value!;
                    });
                  },
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Question'),
                    onPressed: saveQuiz,
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