import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../data/motorcycle_repository.dart';

class MotorcyclePage extends StatefulWidget {
  const MotorcyclePage({super.key});
  @override
  State<MotorcyclePage> createState() => _MotorcyclePageState();
}

class _MotorcyclePageState extends State<MotorcyclePage> {
  List<MotoChapter> _chapters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    MotorcycleRepository.load().then((c) => setState(() {
          _chapters = c;
          _loading = false;
        }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موتورسیکلت'),
        backgroundColor: const Color(0xFFE65100),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: _chapters.map((ch) {
                final color = Color(int.parse(ch.color.replaceFirst('#', 'FF'), radix: 16));
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(ch.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    ...ch.sections.map((sec) => Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withOpacity(0.1),
                              child: Icon(Icons.two_wheeler, color: color, size: 20),
                            ),
                            title: Text(sec.title,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _MotoSectionPage(section: sec, color: color),
                              ),
                            ),
                          ),
                        )),
                  ],
                );
              }).toList(),
            ),
    );
  }
}

class _MotoSectionPage extends StatelessWidget {
  final MotoSection section;
  final Color color;
  const _MotoSectionPage({required this.section, required this.color});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section.title),
        backgroundColor: const Color(0xFFE65100),
      ),
      body: Markdown(
        data: section.content,
        padding: const EdgeInsets.all(16),
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(fontFamily: 'Vazir', fontSize: 20, fontWeight: FontWeight.bold),
          h2: const TextStyle(fontFamily: 'Vazir', fontSize: 16, fontWeight: FontWeight.bold),
          p: const TextStyle(fontFamily: 'Vazir', fontSize: 14, height: 1.8),
          tableHead: const TextStyle(fontFamily: 'Vazir', fontWeight: FontWeight.bold),
          tableBody: const TextStyle(fontFamily: 'Vazir', fontSize: 13),
          blockquoteDecoration: BoxDecoration(
            color: const Color(0xFFE65100).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border(right: BorderSide(color: color, width: 4)),
          ),
        ),
      ),
    );
  }
}
