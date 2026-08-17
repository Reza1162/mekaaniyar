import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/obd2/obd2_service.dart';
import '../../data/obd2/obd2_pids.dart';
import 'dtc_page.dart';

class Obd2DashboardPage extends StatefulWidget {
  final Obd2Service service;
  const Obd2DashboardPage({super.key, required this.service});

  @override
  State<Obd2DashboardPage> createState() => _Obd2DashboardPageState();
}

class _LogRow {
  final DateTime time;
  final Map<String, double?> values;
  _LogRow(this.time, this.values);
}

class _Obd2DashboardPageState extends State<Obd2DashboardPage> {
  Timer? _timer;
  final Map<String, double?> _values = {};
  final List<double> _rpmHistory = [];
  final List<_LogRow> _log = [];
  static const _maxHistory = 30;
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
    setState(() {
      _values.addAll(result);
      final rpm = result[Obd2Pids.rpm.code] ?? 0;
      _rpmHistory.add(rpm);
      if (_rpmHistory.length > _maxHistory) _rpmHistory.removeAt(0);
      _log.add(_LogRow(DateTime.now(), Map.of(result)));
    });
  }

  Future<void> _exportCsv() async {
    if (_log.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هنوز داده‌ای برای خروجی گرفتن وجود ندارد')),
      );
      return;
    }
    final headers = ['زمان', ...Obd2Pids.dashboardPids.map((p) => '${p.name} (${p.unit})')];
    final rows = <List<String>>[headers];
    for (final row in _log) {
      rows.add([
        row.time.toIso8601String(),
        ...Obd2Pids.dashboardPids.map((p) => row.values[p.code]?.toStringAsFixed(1) ?? ''),
      ]);
    }
    final csv = rows.map((r) => r.map(_csvEscape).join(',')).join('\n');
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/mekaaniyar_obd2_log_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    if (!mounted) return;
    await Share.shareXFiles([XFile(file.path)], text: 'گزارش OBD2 مکانیار');
  }

  String _csvEscape(String v) => v.contains(',') ? '"$v"' : v;

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
            icon: const Icon(Icons.ios_share),
            tooltip: 'خروجی CSV',
            onPressed: _exportCsv,
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_rpmHistory.isNotEmpty) _buildChart(),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
                    Text(pid.name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('روند دور موتور', style: TextStyle(fontSize: 12, color: Colors.grey)),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < _rpmHistory.length; i++)
                        FlSpot(i.toDouble(), _rpmHistory[i]),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
