import 'package:flutter/material.dart';
import '../../data/quiz_repository.dart';
import '../../data/content_repository.dart';
import '../../data/quiz_score_repository.dart';
import 'quiz_session_page.dart';

class QuizHubPage extends StatefulWidget {
  const QuizHubPage({super.key});

  @override
  State<QuizHubPage> createState() => _QuizHubPageState();
}

class _QuizHubPageState extends State<QuizHubPage> {
  List<ChapterQuiz> _quizzes = [];
  List<Chapter> _chapters = [];
  Map<String, int> _bestScores = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final quizzes = await QuizRepository.loadAll();
    final chapters = await ContentRepository.loadChapters();
    final scores = <String, int>{};
    for (final q in quizzes) {
      scores[q.chapterId] = await QuizScoreRepository.bestScore(q.chapterId);
    }
    if (!mounted) return;
    setState(() {
      _quizzes = quizzes;
      _chapters = chapters;
      _bestScores = scores;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('کویز دانش مکانیکی')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _quizzes.length,
              itemBuilder: (_, i) {
                final quiz = _quizzes[i];
                Chapter? chapter;
                try {
                  chapter = _chapters.firstWhere((c) => c.id == quiz.chapterId);
                } catch (_) {
                  chapter = null;
                }
                final title = chapter?.title ?? quiz.chapterId;
                final color = chapter != null
                    ? Color(int.parse(chapter.color.replaceFirst('#', 'FF'), radix: 16))
                    : Colors.blueGrey;
                final best = _bestScores[quiz.chapterId] ?? 0;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.12),
                      child: Icon(Icons.quiz_outlined, color: color),
                    ),
                    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${quiz.questions.length} سوال'
                        '${best > 0 ? ' · بهترین نتیجه: $best از ${quiz.questions.length}' : ''}'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizSessionPage(quiz: quiz, chapterTitle: title, color: color),
                      ),
                    ).then((_) => _load()),
                  ),
                );
              },
            ),
    );
  }
}
