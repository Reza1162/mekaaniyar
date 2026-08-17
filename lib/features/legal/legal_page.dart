import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../data/legal_repository.dart';

class LegalPage extends StatefulWidget {
  final int initialTab;
  const LegalPage({super.key, this.initialTab = 0});

  @override
  State<LegalPage> createState() => _LegalPageState();
}

class _LegalPageState extends State<LegalPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LegalDoc? _terms;
  LegalDoc? _privacy;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 2, vsync: this, initialIndex: widget.initialTab);
    _load();
  }

  Future<void> _load() async {
    final terms = await LegalRepository.loadTerms();
    final privacy = await LegalRepository.loadPrivacy();
    if (!mounted) return;
    setState(() {
      _terms = terms;
      _privacy = privacy;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حقوقی و حریم خصوصی'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'شرایط استفاده'),
            Tab(text: 'حریم خصوصی'),
          ],
        ),
      ),
      body: (_terms == null || _privacy == null)
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDoc(_terms!),
                _buildDoc(_privacy!),
              ],
            ),
    );
  }

  Widget _buildDoc(LegalDoc doc) {
    return Markdown(
      data: doc.content,
      padding: const EdgeInsets.all(16),
      styleSheet: MarkdownStyleSheet(
        h1: const TextStyle(
            fontFamily: 'Vazir', fontSize: 19, fontWeight: FontWeight.bold),
        h2: const TextStyle(
            fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold),
        p: const TextStyle(fontFamily: 'Vazir', fontSize: 14, height: 1.9),
        strong: const TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
        listBullet: const TextStyle(fontFamily: 'Vazir', fontSize: 14),
      ),
    );
  }
}
