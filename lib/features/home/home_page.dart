import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content_repository.dart';
import '../chapters/chapter_page.dart';
import '../search/search_page.dart';
import '../bookmarks/bookmarks_page.dart';
import '../diagnostic/diagnostic_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Chapter> _chapters = [];
  bool _loading = true;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final chapters = await ContentRepository.loadChapters();
    setState(() {
      _chapters = chapters;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مکانیار'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _tab,
              children: [
                _buildChapters(),
                const BookmarksPage(),
              ],
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'فصل‌ها',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'عیب‌یاب',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'بوک‌مارک',
          ),
        ],
      ),
    );
  }

  Widget _buildChapters() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _ChapterCard(chapter: _chapters[i]),
              childCount: _chapters.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF0D47A1)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('مکانیار',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('دستیار فنی هر مکانیک',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.car_repair, color: Colors.white54, size: 48),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Chapter chapter;
  const _ChapterCard({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final color = Color(
        int.parse(chapter.color.replaceFirst('#', 'FF'), radix: 16));
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChapterPage(chapter: chapter)),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border(right: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.menu_book_outlined, color: color, size: 24),
            ),
            const Spacer(),
            Text(chapter.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            Text(chapter.description,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            if (chapter.isPro)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)),
                child: const Text('حرفه‌ای',
                    style: TextStyle(
                        color: AppTheme.accent,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
