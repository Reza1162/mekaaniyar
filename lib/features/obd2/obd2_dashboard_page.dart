import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/obd2/obd2_service.dart';
import '../../data/obd2/obd2_pids.dart';
import 'dtc_page.dart';

class Obd2DashboardPage extends StatefulWidget {
  final Obd2Service service;
  const Obd2DashboardPage({super.key, required this.service});

  @override
  State<Obd2DashboardPage> createState() => _Obd2DashboardPageState();
}

class _Obd2DashboardPageState extends State<Obd2DashboardPage> {
  Timer? _timer;
  final Map<String, double?> _values = {};
  bool _polling = true;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_polling) _poll();
    });
  }

  Future<void> _poll() async {
    final result = await widget.service.readAll(Obd2Pids.dashboardPids);
    if (!mounted) return;
    setState(() => _values.addAll(result));
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('داشبورد زنده OBD2'),
        actions: [
          IconButton(
            icon: Icon(_polling ? Icons.pause : Icons.play_arrow),
            onPressed: () => setState(() => _polling = !_polling),
          ),
          IconButton(
            icon: const Icon(Icons.error_outline),
            tooltip: 'کدهای خطا',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => DtcPage(service: widget.service)),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: Obd2Pids.dashboardPids.length,
        itemBuilder: (_, i) {
          final pid = Obd2Pids.dashboardPids[i];
          final value = _values[pid.code];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(pid.name,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                Text(
                  value == null ? '—' : value.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(pid.unit, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
