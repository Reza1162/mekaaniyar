import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content_repository.dart';
import '../../data/bookmark_db.dart';
import '../../data/pro_manager.dart';
import '../../data/quiz_repository.dart';
import '../pro/pro_page.dart';
import '../quiz/quiz_session_page.dart';

class ChapterPage extends StatefulWidget {
  final Chapter chapter;
  const ChapterPage({super.key, required this.chapter});

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  // Default to 'basic' so a new/casual user isn't hit with the full
  // technical section list right away; they can switch to 'advanced'
  // or 'all' deliberately.
  String _filter = 'basic';

  @override
  Widget build(BuildContext context) {
    final chapter = widget.chapter;
    final color = Color(int.parse(chapter.color.replaceFirst('#', 'FF'), radix: 16));
    final basicCount = chapter.sections.where((s) => s.level == 'basic').length;
    final advancedCount = chapter.sections.length - basicCount;
    final visibleSections = _filter == 'all'
        ? chapter.sections
        : chapter.sections.where((s) => s.level == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: Text(chapter.title)),
      floatingActionButton: FutureBuilder<ChapterQuiz?>(
        future: QuizRepository.forChapter(chapter.id),
        builder: (context, snap) {
          if (snap.data == null) return const SizedBox.shrink();
          final quiz = snap.data!;
          return FloatingActionButton.extended(
            backgroundColor: color,
            icon: const Icon(Icons.quiz_outlined),
            label: const Text('کویز این فصل'),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => QuizSessionPage(quiz: quiz, chapterTitle: chapter.title, color: color),
              ),
            ),
          );
        },
      ),
      body: Column(
        children: [
          if (advancedCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: _LevelChip(
                      label: 'پایه ($basicCount)',
                      selected: _filter == 'basic',
                      color: color,
                      onTap: () => setState(() => _filter = 'basic'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LevelChip(
                      label: 'تخصصی ($advancedCount)',
                      selected: _filter == 'advanced',
                      color: color,
                      onTap: () => setState(() => _filter = 'advanced'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _LevelChip(
                      label: 'همه',
                      selected: _filter == 'all',
                      color: color,
                      onTap: () => setState(() => _filter = 'all'),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: FutureBuilder<bool>(
              future: ProManager.isPro(),
              builder: (context, snap) {
                final isPro = snap.data ?? false;
                if (visibleSections.isEmpty) {
                  return const Center(child: Text('محتوایی در این سطح موجود نیست'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: visibleSections.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final sec = visibleSections[i];
                    final locked = chapter.isPro && !isPro;
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withOpacity(0.1),
                          child: Icon(
                            locked ? Icons.lock_outline : Icons.article_outlined,
                            color: locked ? Colors.grey : color,
                          ),
                        ),
                        title: Text(sec.title,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: locked ? Colors.grey : null)),
                        subtitle: sec.level == 'advanced'
                            ? const Text('تخصصی', style: TextStyle(fontSize: 11, color: Colors.orange))
                            : null,
                        trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                        onTap: () {
                          if (locked) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ProPage()),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SectionPage(section: sec, color: color),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _LevelChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}

class SectionPage extends StatefulWidget {
  final Section section;
  final Color color;
  const SectionPage({super.key, required this.section, required this.color});

  @override
  State<SectionPage> createState() => _SectionPageState();
}

class _SectionPageState extends State<SectionPage> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    BookmarkDB.isBookmarked(widget.section.id).then((v) {
      setState(() => _isBookmarked = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.section.title),
        actions: [
          IconButton(
            icon: Icon(_isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () async {
              await BookmarkDB.toggle(widget.section.id);
              setState(() => _isBookmarked = !_isBookmarked);
            },
          ),
        ],
      ),
      body: Markdown(
        data: widget.section.content,
        padding: const EdgeInsets.all(16),
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(fontFamily: 'Vazir', fontSize: 20, fontWeight: FontWeight.bold),
          h2: const TextStyle(fontFamily: 'Vazir', fontSize: 17, fontWeight: FontWeight.bold),
          h3: const TextStyle(fontFamily: 'Vazir', fontSize: 15, fontWeight: FontWeight.w600),
          p: const TextStyle(fontFamily: 'Vazir', fontSize: 14, height: 1.8),
          tableHead: const TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
          tableBody: const TextStyle(fontFamily: 'Vazir', fontSize: 13),
          blockquoteDecoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(8),
            border: Border(right: BorderSide(color: widget.color, width: 4)),
          ),
          code: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}
