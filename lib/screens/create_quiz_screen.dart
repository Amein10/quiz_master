import 'package:flutter/material.dart';

import '../repositories/quiz_repository.dart';
import '../services/quiz_service.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  // Controllers bruges til at læse teksten fra inputfelterne.
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerAController = TextEditingController();
  final TextEditingController answerBController = TextEditingController();
  final TextEditingController answerCController = TextEditingController();
  final TextEditingController answerDController = TextEditingController();

  // Repository bruges til at gemme brugerens egne spørgsmål lokalt.
  // QuizService sendes ind via simpel Dependency Injection.
  final QuizRepository quizRepository = QuizRepository(
    quizService: QuizService(),
  );

  String correctAnswer = 'A';

  // Tjekker om alle felter er udfyldt.
  // trim() fjerner mellemrum, så brugeren ikke kan gemme tomme svar.
  bool formIsValid() {
    return questionController.text.trim().isNotEmpty &&
        answerAController.text.trim().isNotEmpty &&
        answerBController.text.trim().isNotEmpty &&
        answerCController.text.trim().isNotEmpty &&
        answerDController.text.trim().isNotEmpty;
  }

  // Gemmer brugerens spørgsmål som et custom quiz-spørgsmål.
  // Spørgsmålet bygges i samme format som API-spørgsmålene,
  // så resten af appen kan bruge det på samme måde.
  Future<void> saveQuiz() async {
    if (!formIsValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields'),
        ),
      );
      return;
    }

    final Map<String, String> answers = {
      'A': answerAController.text.trim(),
      'B': answerBController.text.trim(),
      'C': answerCController.text.trim(),
      'D': answerDController.text.trim(),
    };

    final Map<String, dynamic> customQuestion = {
      'question': questionController.text.trim(),
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

    clearForm();
  }

  // Rydder formularen efter et spørgsmål er gemt.
  // Det gør det nemt for brugeren at oprette endnu et spørgsmål.
  void clearForm() {
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
    // Controllers skal dispose, når skærmen lukkes.
    // Det forhindrer unødigt hukommelsesforbrug.
    questionController.dispose();
    answerAController.dispose();
    answerBController.dispose();
    answerCController.dispose();
    answerDController.dispose();

    super.dispose();
  }

  // Genbrugelig widget til svarfelterne.
  // Den gør koden kortere, fordi Answer A-D bruger samme layout.
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

      // SingleChildScrollView sikrer, at formularen kan scrolles,
      // især når tastaturet åbnes eller skærmen er lille.
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

                // Dropdown bruges til at vælge, hvilket svar der er korrekt.
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
                    if (value == null) return;

                    setState(() {
                      correctAnswer = value;
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