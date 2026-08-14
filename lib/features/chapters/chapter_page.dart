import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content_repository.dart';

class ChapterPage extends StatelessWidget {
  final Chapter chapter;
  const ChapterPage({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(chapter.color.replaceFirst('#', 'FF'), radix: 16));
    return Scaffold(
      appBar: AppBar(title: Text(chapter.title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: chapter.sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final sec = chapter.sections[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(Icons.article_outlined, color: color),
              ),
              title: Text(sec.title, style: const TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_left, color: Colors.grey),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => SectionPage(section: sec, color: color)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SectionPage extends StatelessWidget {
  final Section section;
  final Color color;
  const SectionPage({super.key, required this.section, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      body: Markdown(
        data: section.content,
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
            border: Border(right: BorderSide(color: color, width: 4)),
          ),
          code: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
    );
  }
}
