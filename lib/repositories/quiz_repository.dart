import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/quiz_service.dart';

class QuizRepository {
  final QuizService quizService;

  QuizRepository({required this.quizService});

  Future<List<dynamic>> getQuestions() async {
    final customQuestions = await getCustomQuestions();
    final apiQuestions = await quizService.fetchQuestions();

    return [
      ...customQuestions,
      ...apiQuestions,
    ];
  }

  Future<void> saveCustomQuestion(Map<String, dynamic> question) async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuestions = prefs.getStringList('custom_questions') ?? [];

    savedQuestions.add(jsonEncode(question));

    await prefs.setStringList('custom_questions', savedQuestions);
  }

  Future<List<dynamic>> getCustomQuestions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuestions = prefs.getStringList('custom_questions') ?? [];

    return savedQuestions.map((question) {
      final decodedQuestion = jsonDecode(question);
      decodedQuestion['is_custom'] = true;
      return decodedQuestion;
    }).toList();
  }

  Future<void> deleteCustomQuestion(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuestions = prefs.getStringList('custom_questions') ?? [];

    if (index >= 0 && index < savedQuestions.length) {
      savedQuestions.removeAt(index);
      await prefs.setStringList('custom_questions', savedQuestions);
    }
  }

  Future<int> getCustomQuestionCount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedQuestions = prefs.getStringList('custom_questions') ?? [];

    return savedQuestions.length;
  }
}