import 'package:flutter/material.dart';
import '../../data/bookmark_db.dart';
import '../../data/content_repository.dart';
import '../chapters/chapter_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  List<Map<String, dynamic>> _bookmarked = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ids = await BookmarkDB.getAll();
    final result = <Map<String, dynamic>>[];
    for (final ch in ContentRepository.chapters) {
      for (final sec in ch.sections) {
        if (ids.contains(sec.id)) {
          result.add({
            'chapter': ch,
            'section': sec,
          });
        }
      }
    }
    setState(() => _bookmarked = result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('بوک‌مارک‌ها')),
      body: _bookmarked.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bookmark_border, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text('هنوز بوک‌مارکی ندارید',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  const Text('روی آیکون بوک‌مارک در هر بخش بزنید',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _bookmarked.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final ch = _bookmarked[i]['chapter'] as Chapter;
                final sec = _bookmarked[i]['section'] as Section;
                final color = Color(int.parse(ch.color.replaceFirst('#', 'FF'), radix: 16));
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withOpacity(0.1),
                      child: Icon(Icons.bookmark, color: color, size: 18),
                    ),
                    title: Text(sec.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(ch.title,
                        style: const TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SectionPage(section: sec, color: color),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
