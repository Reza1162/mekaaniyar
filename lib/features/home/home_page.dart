import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/content_repository.dart';
import '../chapters/chapter_page.dart';
import '../search/search_page.dart';
import '../bookmarks/bookmarks_page.dart';
import '../diagnostic/diagnostic_page.dart';
import '../tools/tools_page.dart';
import '../remap/remap_page.dart';
import '../motorcycle/motorcycle_page.dart';
import '../legal/legal_page.dart';
import '../obd2/obd2_connect_page.dart';
import '../garage/garage_page.dart';
import '../quiz/quiz_hub_page.dart';
import '../../data/garage/notification_service.dart';

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
    NotificationService.requestPermission();
    NotificationService.scheduleWeeklyCheckIn();
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
        title: const Text('مکانیک یار'),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_outlined),
            tooltip: 'کویز دانش',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const QuizHubPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'legal') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LegalPage()),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'legal',
                child: Text('شرایط استفاده و حریم خصوصی'),
              ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _tab,
              children: [
                _buildChapters(),
                const DiagnosticPage(),
                const GaragePage(),
                const ToolsPage(),
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
            icon: Icon(Icons.garage_outlined),
            selectedIcon: Icon(Icons.garage),
            label: 'گاراژ',
          ),
          NavigationDestination(
            icon: Icon(Icons.calculate_outlined),
            selectedIcon: Icon(Icons.calculate),
            label: 'ابزارها',
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
    final totalSections =
        _chapters.fold<int>(0, (sum, c) => sum + c.sections.length);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(totalSections)),
        SliverToBoxAdapter(child: _buildSpecialCards()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text('فصل‌های آموزشی',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800)),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _ChapterCard(chapter: _chapters[i]),
              childCount: _chapters.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.92,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RemapPage())),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFF880E4F), Color(0xFFAD1457)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.memory, color: Colors.white, size: 28),
                        SizedBox(height: 6),
                        Text('ریمپ ECU',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MotorcyclePage())),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFE65100), Color(0xFFF4511E)]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.two_wheeler,
                            color: Colors.white, size: 28),
                        SizedBox(height: 6),
                        Text('موتورسیکلت',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const Obd2ConnectPage())),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bluetooth_connected,
                      color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('اتصال OBD2',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        Text('اتصال زنده به کامپیوتر خودرو',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_left, color: Colors.white70),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int totalSections) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF0D47A1)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('مکانیک یار',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('دستیار فنی هر مکانیک',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _statChip(Icons.menu_book, '${_chapters.length} فصل'),
                    const SizedBox(width: 8),
                    _statChip(Icons.article_outlined, '$totalSections مبحث'),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.car_repair, color: Colors.white, size: 40),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final Chapter chapter;
  const _ChapterCard({required this.chapter});

  static const Map<String, IconData> _iconMap = {
    'engine': Icons.settings_suggest,
    'gearbox': Icons.sync_alt,
    'electrical': Icons.electric_bolt,
    'transmission': Icons.settings_input_component,
    'suspension': Icons.height,
    'brakes': Icons.album,
    'ev': Icons.electric_car,
    'iran': Icons.directions_car,
    'table': Icons.table_chart,
    'car_repair': Icons.build_circle_outlined,
    'bodywork': Icons.build_circle_outlined,
    'hvac': Icons.ac_unit,
    'tires': Icons.trip_origin,
  };

  @override
  Widget build(BuildContext context) {
    final color =
        Color(int.parse(chapter.color.replaceFirst('#', 'FF'), radix: 16));
    final icon = _iconMap[chapter.icon] ?? Icons.menu_book_outlined;
    return InkWell(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => ChapterPage(chapter: chapter))),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.10), color.withOpacity(0.02)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AnimatedChapterIcon(icon: icon, color: color),
                if (chapter.isPro)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium,
                            color: Colors.white, size: 11),
                        SizedBox(width: 3),
                        Text('حرفه‌ای',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(chapter.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5)),
            const SizedBox(height: 5),
            Text(chapter.description,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.article_outlined, size: 13, color: color.withOpacity(0.7)),
                const SizedBox(width: 4),
                Text('${chapter.sections.length} مبحث',
                    style: TextStyle(
                        fontSize: 10.5,
                        color: color.withOpacity(0.85),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Animated icon badge for chapter cards: a soft, continuously breathing
/// glow ring behind the icon plus a gentle one-time scale/fade entrance —
/// pure Flutter animation, no external assets or network needed.
class _AnimatedChapterIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  const _AnimatedChapterIcon({required this.icon, required this.color});

  @override
  State<_AnimatedChapterIcon> createState() => _AnimatedChapterIconState();
}

class _AnimatedChapterIconState extends State<_AnimatedChapterIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;
  late final Animation<double> _entrance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    // One-time entrance: pop in with a slight overshoot the first time
    // this card appears on screen.
    _entrance = CurvedAnimation(parent: _controller, curve: const Interval(0, 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.75, end: 1.0),
      duration: const Duration(milliseconds: 450),
      curve: Curves.elasticOut,
      builder: (context, entranceScale, child) => Transform.scale(
        scale: entranceScale,
        child: child,
      ),
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          final glowStrength = 0.25 + (_glow.value * 0.35);
          final ringScale = 1.0 + (_glow.value * 0.18);
          return SizedBox(
            width: 44,
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: ringScale,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.color.withOpacity(glowStrength * 0.25),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withOpacity(glowStrength),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 22),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
