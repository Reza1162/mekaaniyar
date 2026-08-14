import 'package:flutter/material.dart';
import '../../data/content_repository.dart';
import '../chapters/chapter_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  List<Map<String, String>> _results = [];
  List<Map<String, String>> _index = [];

  @override
  void initState() {
    super.initState();
    _index = ContentRepository.buildSearchIndex();
  }

  void _search(String q) {
    if (q.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    final query = q.toLowerCase();
    setState(() {
      _results = _index.where((item) =>
        item['sectionTitle']!.contains(query) ||
        item['content']!.toLowerCase().contains(query) ||
        item['chapterTitle']!.contains(query)
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'جستجو... (مثلاً: کد P0301، روغن XU7)',
            hintStyle: TextStyle(color: Colors.white60),
            border: InputBorder.none,
          ),
          onChanged: _search,
        ),
      ),
      body: _results.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.search, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('جستجو در تمام محتوا', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = _results[i];
                final chapters = ContentRepository.chapters;
                final chapter = chapters.firstWhere((c) => c.id == r['chapterId']);
                final section = chapter.sections.firstWhere((s) => s.id == r['sectionId']);
                final color = Color(int.parse(chapter.color.replaceFirst('#', 'FF'), radix: 16));
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.article_outlined, color: color, size: 18)),
                    title: Text(r['sectionTitle']!, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(r['chapterTitle']!, style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => SectionPage(section: section, color: color)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
