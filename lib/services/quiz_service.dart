import 'dart:convert';
import 'package:http/http.dart' as http;

class QuizService {

  Future<List<dynamic>> fetchQuestions() async {

    final url = Uri.parse(
      'https://opentdb.com/api.php?amount=10&type=multiple',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      return data['results'];

    } else {

      throw Exception('Failed to load questions');

    }
  }
}