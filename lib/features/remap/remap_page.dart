import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../core/theme/app_theme.dart';
import '../../data/remap_repository.dart';
import '../../data/pro_manager.dart';
import '../pro/pro_page.dart';

class RemapPage extends StatefulWidget {
  const RemapPage({super.key});
  @override
  State<RemapPage> createState() => _RemapPageState();
}

class _RemapPageState extends State<RemapPage> {
  List<RemapCategory> _categories = [];
  bool _loading = true;
  bool _isPro = false;

  @override
  void initState() {
    super.initState();
    Future.wait([
      RemapRepository.load(),
      ProManager.isPro(),
    ]).then((results) {
      setState(() {
        _categories = results[0] as List<RemapCategory>;
        _isPro = results[1] as bool;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ریمپ ECU'),
        backgroundColor: const Color(0xFF880E4F),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF880E4F).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF880E4F)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber, color: Color(0xFF880E4F)),
                          SizedBox(width: 10),
                          Text('هشدار مهم',
                              style: TextStyle(
                                  color: Color(0xFF880E4F),
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'این بخش فقط جنبه‌ی آموزشی دارد. ریمپ ECU ممکن است گارانتی خودرو را باطل کند و '
                        'با قوانین معاینه فنی/آلایندگی در تضاد باشد. همیشه backup بگیرید و مسئولیت اجرای '
                        'واقعی روی خودرو با شماست.',
                        style: TextStyle(color: Color(0xFF880E4F)),
                      ),
                    ],
                  ),
                ),
                ..._categories.map((cat) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Text(cat.title,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                              if (cat.isPro && !_isPro) ...[
                                const SizedBox(width: 6),
                                const Icon(Icons.lock_outline,
                                    size: 16, color: Colors.grey),
                              ],
                            ],
                          ),
                        ),
                        ...cat.sections.map((sec) {
                          final locked = cat.isPro && !_isPro;
                          return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0x1A880E4F),
                                  child: Icon(
                                      locked ? Icons.lock_outline : Icons.memory,
                                      color: locked
                                          ? Colors.grey
                                          : const Color(0xFF880E4F)),
                                ),
                                title: Text(sec.title,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: locked ? Colors.grey : null)),
                                trailing: const Icon(Icons.chevron_left,
                                    color: Colors.grey),
                                onTap: () {
                                  if (locked) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (_) => const ProPage()),
                                    );
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            _RemapSectionPage(section: sec),
                                      ),
                                    );
                                  }
                                },
                              ));
                        }),
                      ],
                    )),
              ],
            ),
    );
  }
}

class _RemapSectionPage extends StatelessWidget {
  final RemapSection section;
  const _RemapSectionPage({required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section.title),
        backgroundColor: const Color(0xFF880E4F),
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
        ),
      ),
    );
  }
}
