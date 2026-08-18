import 'dart:convert';
import 'package:flutter/services.dart';

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
        id: j['id'],
        question: j['question'],
        options: List<String>.from(j['options']),
        correctIndex: j['correctIndex'],
        explanation: j['explanation'],
      );
}

class ChapterQuiz {
  final String chapterId;
  final List<QuizQuestion> questions;
  ChapterQuiz({required this.chapterId, required this.questions});

  factory ChapterQuiz.fromJson(Map<String, dynamic> j) => ChapterQuiz(
        chapterId: j['chapterId'],
        questions: (j['questions'] as List)
            .map((e) => QuizQuestion.fromJson(e))
            .toList(),
      );
}

class QuizRepository {
  static List<ChapterQuiz>? _quizzes;

  static Future<List<ChapterQuiz>> loadAll() async {
    if (_quizzes != null) return _quizzes!;
    final raw = await rootBundle.loadString('assets/content/quiz.json');
    final data = jsonDecode(raw);
    _quizzes = (data['quizzes'] as List)
        .map((e) => ChapterQuiz.fromJson(e))
        .toList();
    return _quizzes!;
  }

  static Future<ChapterQuiz?> forChapter(String chapterId) async {
    final all = await loadAll();
    try {
      return all.firstWhere((q) => q.chapterId == chapterId);
    } catch (_) {
      return null;
    }
  }
}
