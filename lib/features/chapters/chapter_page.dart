import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content_repository.dart';
import '../../data/bookmark_db.dart';
import '../../data/pro_manager.dart';
import '../pro/pro_page.dart';

class ChapterPage extends StatelessWidget {
  final Chapter chapter;
  const ChapterPage({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(chapter.color.replaceFirst('#', 'FF'), radix: 16));
    return Scaffold(
      appBar: AppBar(title: Text(chapter.title)),
      body: FutureBuilder<bool>(
        future: ProManager.isPro(),
        builder: (context, snap) {
          final isPro = snap.data ?? false;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: chapter.sections.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final sec = chapter.sections[i];
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
