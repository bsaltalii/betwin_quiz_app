import 'dart:convert';
import 'package:http/http.dart' as http;

class TriviaService {
  final String baseUrl = 'https://the-trivia-api.com/api/questions';

  Future<List<Question>> fetchQuestions({
    required String limit,
    required String category,
    required String difficulty,
  }) async {
    try {
      final response = await http.get(Uri.parse(
          '$baseUrl?categories=$category&limit=$limit&difficulty=$difficulty'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return (data as List)
            .map((questionData) => Question.fromJson(questionData))
            .toList();
      } else {
        throw Exception(
            'Questions couldn\'t be fetched: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}

class Question {
  String category;
  String id;
  List<String> tags;
  String difficulty;
  List<String> regions;
  bool isNiche;
  String question;
  String correctAnswer;
  List<String> incorrectAnswers;
  String type;
  List<String>? shuffledOptions;

  Question({
    required this.category,
    required this.id,
    required this.tags,
    required this.difficulty,
    required this.regions,
    required this.isNiche,
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.type,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      category: json['category'],
      id: json['id'],
      tags: List<String>.from(json['tags']),
      difficulty: json['difficulty'],
      regions: List<String>.from(json['regions']),
      isNiche: json['isNiche'],
      question: json['question'],
      correctAnswer: json['correctAnswer'],
      incorrectAnswers: List<String>.from(json['incorrectAnswers']),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'id': id,
      'tags': tags,
      'difficulty': difficulty,
      'regions': regions,
      'isNiche': isNiche,
      'question': question,
      'correctAnswer': correctAnswer,
      'incorrectAnswers': incorrectAnswers,
      'type': type,
    };
  }

  void shuffleOptions() {
    shuffledOptions = List.from(incorrectAnswers)..add(correctAnswer);
    shuffledOptions?.shuffle();
  }
}
