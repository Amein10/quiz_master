import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/quiz_service.dart';

class QuizRepository {
  final QuizService quizService;

  // Repository får QuizService udefra.
  // Det er simpel Dependency Injection, fordi klassen ikke selv skal oprette sin service.
  QuizRepository({required this.quizService});

  static const String customQuestionsKey = 'custom_questions';

  // Henter alle quizspørgsmål til appen.
  // Først hentes brugerens egne spørgsmål fra lokal storage.
  // Derefter hentes spørgsmål fra API'et.
  // Til sidst samles begge lister, så custom questions vises øverst.
  Future<List<dynamic>> getQuestions() async {
    final customQuestions = await getCustomQuestions();
    final apiQuestions = await quizService.fetchQuestions();

    return [
      ...customQuestions,
      ...apiQuestions,
    ];
  }

  // Gemmer et brugeroprettet spørgsmål lokalt på enheden.
  // SharedPreferences kan ikke gemme Map direkte, derfor konverteres spørgsmålet til JSON.
  Future<void> saveCustomQuestion(Map<String, dynamic> question) async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuestions = prefs.getStringList(customQuestionsKey) ?? [];

    final encodedQuestion = jsonEncode(question);
    savedQuestions.add(encodedQuestion);

    await prefs.setStringList(customQuestionsKey, savedQuestions);
  }

  // Henter alle brugeroprettede spørgsmål fra lokal storage.
  // Hvert spørgsmål er gemt som JSON-string og bliver derfor konverteret tilbage til Map.
  // Feltet "is_custom" tilføjes, så UI'et kan kende forskel på egne spørgsmål og API-spørgsmål.
  Future<List<dynamic>> getCustomQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuestions = prefs.getStringList(customQuestionsKey) ?? [];

    return savedQuestions.map((question) {
      final decodedQuestion = jsonDecode(question) as Map<String, dynamic>;

      decodedQuestion['is_custom'] = true;

      return decodedQuestion;
    }).toList();
  }

  // Sletter et brugeroprettet spørgsmål ud fra dets index i listen.
  // Der tjekkes først, at indexet findes, så appen ikke crasher ved ugyldigt index.
  Future<void> deleteCustomQuestion(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuestions = prefs.getStringList(customQuestionsKey) ?? [];

    final indexIsValid = index >= 0 && index < savedQuestions.length;

    if (!indexIsValid) {
      return;
    }

    savedQuestions.removeAt(index);

    await prefs.setStringList(customQuestionsKey, savedQuestions);
  }

  // Returnerer hvor mange brugeroprettede spørgsmål der findes.
  // Det bruges i QuizScreen til at vide, hvilke spørgsmål der må slettes.
  Future<int> getCustomQuestionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuestions = prefs.getStringList(customQuestionsKey) ?? [];

    return savedQuestions.length;
  }
}