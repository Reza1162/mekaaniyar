import 'package:flutter/material.dart';
import '../../data/quiz_repository.dart';
import '../../data/quiz_score_repository.dart';

class QuizSessionPage extends StatefulWidget {
  final ChapterQuiz quiz;
  final String chapterTitle;
  final Color color;
  const QuizSessionPage({
    super.key,
    required this.quiz,
    required this.chapterTitle,
    required this.color,
  });

  @override
  State<QuizSessionPage> createState() => _QuizSessionPageState();
}

class _QuizSessionPageState extends State<QuizSessionPage> {
  int _index = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;
  bool _finished = false;

  QuizQuestion get _current => widget.quiz.questions[_index];

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
      if (i == _current.correctIndex) _score++;
    });
  }

  void _next() {
    if (_index + 1 >= widget.quiz.questions.length) {
      QuizScoreRepository.reportScore(widget.quiz.chapterId, _score);
      setState(() => _finished = true);
    } else {
      setState(() {
        _index++;
        _selected = null;
        _answered = false;
      });
    }
  }

  void _restart() {
    setState(() {
      _index = 0;
      _score = 0;
      _selected = null;
      _answered = false;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildResult();

    final total = widget.quiz.questions.length;
    return Scaffold(
      appBar: AppBar(
        title: Text('کویز ${widget.chapterTitle}'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_index + 1) / total,
            color: widget.color,
            backgroundColor: widget.color.withOpacity(0.15),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('سوال ${_index + 1} از $total',
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(_current.question,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, height: 1.5)),
            const SizedBox(height: 20),
            ..._current.options.asMap().entries.map((entry) {
              final i = entry.key;
              final text = entry.value;
              Color? bg;
              Color? border = Colors.grey.shade300;
              IconData? icon;
              if (_answered) {
                if (i == _current.correctIndex) {
                  bg = Colors.green.withOpacity(0.1);
                  border = Colors.green;
                  icon = Icons.check_circle;
                } else if (i == _selected) {
                  bg = Colors.red.withOpacity(0.08);
                  border = Colors.red;
                  icon = Icons.cancel;
                }
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => _select(i),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: bg,
                      border: Border.all(color: border!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
                        if (icon != null) Icon(icon, color: border, size: 20),
                      ],
                    ),
                  ),
                ),
              );
            }),
            if (_answered) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_current.explanation, style: const TextStyle(fontSize: 12.5, height: 1.7)),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(_index + 1 >= total ? 'مشاهده‌ی نتیجه' : 'سوال بعدی'),
                  ),
                ),
              ),
            ] else
              const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final total = widget.quiz.questions.length;
    final percent = (_score / total * 100).round();
    final good = percent >= 70;
    return Scaffold(
      appBar: AppBar(title: Text('نتیجه‌ی کویز ${widget.chapterTitle}')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                good ? Icons.emoji_events : Icons.school_outlined,
                size: 64,
                color: good ? Colors.amber.shade700 : widget.color,
              ),
              const SizedBox(height: 16),
              Text('$_score از $total پاسخ درست',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('$percent٪', style: TextStyle(fontSize: 15, color: widget.color)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('بازگشت'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _restart,
                      child: const Text('دوباره تلاش کن'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
