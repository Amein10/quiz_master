import '../services/quiz_service.dart';

class QuizRepository {
  final QuizService quizService;

  QuizRepository({required this.quizService});

  Future<List<dynamic>> getQuestions() {
    return quizService.fetchQuestions();
  }
}