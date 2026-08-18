import 'package:shared_preferences/shared_preferences.dart';

class QuizScoreRepository {
  static String _key(String chapterId) => 'quiz_best_score_$chapterId';

  static Future<int> bestScore(String chapterId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key(chapterId)) ?? 0;
  }

  static Future<void> reportScore(String chapterId, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_key(chapterId)) ?? 0;
    if (score > current) {
      await prefs.setInt(_key(chapterId), score);
    }
  }
}
