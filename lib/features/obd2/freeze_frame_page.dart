import 'package:flutter/material.dart';
import '../../data/obd2/obd2_service.dart';
import '../../data/obd2/obd2_pids.dart';

class FreezeFramePage extends StatefulWidget {
  final Obd2Service service;
  final String code;
  const FreezeFramePage({super.key, required this.service, required this.code});

  @override
  State<FreezeFramePage> createState() => _FreezeFramePageState();
}

class _FreezeFramePageState extends State<FreezeFramePage> {
  Map<String, double?>? _frame;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final frame = await widget.service.readFreezeFrame();
    if (!mounted) return;
    setState(() {
      _frame = frame;
      _loading = false;
    });
  }

  static const _framePids = [
    Obd2Pids.rpm,
    Obd2Pids.speed,
    Obd2Pids.coolantTemp,
    Obd2Pids.engineLoad,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('لحظه‌ی ثبت خطا: ${widget.code}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'این مقادیر مربوط به لحظه‌ای است که خودرو این کد خطا را ثبت کرده '
                    '(نه اکنون). برای عیب‌یابی دقیق‌تر مفید است.',
                    style: TextStyle(fontSize: 12.5, height: 1.7),
                  ),
                ),
                ..._framePids.map((pid) {
                  final value = _frame?[pid.code];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(pid.name),
                      trailing: Text(
                        value == null ? 'در دسترس نیست' : '${value.toStringAsFixed(1)} ${pid.unit}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
