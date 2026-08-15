import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/diagnostic_repository.dart';

class DiagnosticPage extends StatefulWidget {
  const DiagnosticPage({super.key});

  @override
  State<DiagnosticPage> createState() => _DiagnosticPageState();
}

class _DiagnosticPageState extends State<DiagnosticPage> {
  List<DiagTree> _trees = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trees = await DiagnosticRepository.load();
    setState(() {
      _trees = trees;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عیب‌یاب خودرو')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primary),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'علامت خودرو را انتخاب کنید تا مشکل را تشخیص دهیم',
                          style: TextStyle(color: AppTheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                ...List.generate(_trees.length, (i) {
                  final tree = _trees[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryLight,
                        child: const Icon(Icons.search, color: AppTheme.primary),
                      ),
                      title: Text(tree.title,
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DiagnosticFlowPage(tree: tree),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}

class DiagnosticFlowPage extends StatefulWidget {
  final DiagTree tree;
  const DiagnosticFlowPage({super.key, required this.tree});

  @override
  State<DiagnosticFlowPage> createState() => _DiagnosticFlowPageState();
}

class _DiagnosticFlowPageState extends State<DiagnosticFlowPage> {
  final List<Map<String, dynamic>> _history = [];
  DiagNode? _currentNode;
  DiagResult? _result;

  @override
  void initState() {
    super.initState();
    _currentNode = DiagNode(
      question: widget.tree.question,
      options: widget.tree.options,
    );
  }

  void _selectOption(DiagOption option) {
    setState(() {
      _history.add({
        'question': _currentNode!.question,
        'answer': option.text,
      });

      if (option.result != null) {
        _result = option.result;
        _currentNode = null;
      } else if (option.next != null) {
        if (option.next!.result != null) {
          _result = option.next!.result;
          _currentNode = null;
        } else {
          _currentNode = option.next;
        }
      }
    });
  }

  void _reset() {
    setState(() {
      _history.clear();
      _result = null;
      _currentNode = DiagNode(
        question: widget.tree.question,
        options: widget.tree.options,
      );
    });
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }

  String _severityLabel(String severity) {
    switch (severity) {
      case 'critical':
        return 'اورژانسی — فوری تعمیر شود';
      case 'high':
        return 'مهم — هر چه زودتر';
      case 'medium':
        return 'متوسط — در اولین فرصت';
      default:
        return 'کم — نظارت کافیه';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tree.title),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'شروع مجدد',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // تاریخچه سوال‌ها
          if (_history.isNotEmpty) ...[
            ...List.generate(_history.length, (i) {
              final h = _history[i];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.help_outline,
                            size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(h['question'],
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check,
                            size: 16, color: AppTheme.primary),
                        const SizedBox(width: 6),
                        Text(h['answer'],
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),
            const Divider(),
            const SizedBox(height: 12),
          ],

          // سوال فعلی
          if (_currentNode != null && _result == null) ...[
            Text(
              _currentNode!.question!,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...List.generate(_currentNode!.options!.length, (i) {
              final opt = _currentNode!.options![i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: () => _selectOption(opt),
                  style: OutlinedButton.styleFrom(
                    alignment: AlignmentDirectional.centerStart,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(opt.text, textAlign: TextAlign.right),
                ),
              );
            }),
          ],

          // نتیجه
          if (_result != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _severityColor(_result!.severity).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _severityColor(_result!.severity), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.car_repair,
                          color: _severityColor(_result!.severity)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _result!.title,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _severityColor(_result!.severity)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _severityColor(_result!.severity),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _severityLabel(_result!.severity),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(_result!.description,
                      style: const TextStyle(fontSize: 14, height: 1.6)),
                  const SizedBox(height: 16),
                  const Text('اقدامات لازم:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...List.generate(_result!.actions.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Text('${i + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(_result!.actions[i],
                                style: const TextStyle(height: 1.5)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('عیب‌یابی مجدد'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
