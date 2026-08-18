import 'package:flutter/material.dart';
import '../../data/obd2/obd2_log_repository.dart';
import '../../data/obd2/obd2_pids.dart';
import '../../data/obd2/dtc_decoder.dart';
import '../../data/garage/garage_repository.dart';

class Obd2HistoryPage extends StatefulWidget {
  final String? vehicleId; // if set, shows only this vehicle's sessions
  const Obd2HistoryPage({super.key, this.vehicleId});

  @override
  State<Obd2HistoryPage> createState() => _Obd2HistoryPageState();
}

class _Obd2HistoryPageState extends State<Obd2HistoryPage> {
  List<Obd2Session> _sessions = [];
  Map<String, String> _vehicleNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = widget.vehicleId != null
        ? await Obd2LogRepository.forVehicle(widget.vehicleId!)
        : await Obd2LogRepository.getAll();
    final vehicles = await GarageRepository.getAll();
    if (!mounted) return;
    setState(() {
      _sessions = all;
      _vehicleNames = {for (final v in vehicles) v.id: v.nickname};
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تاریخچه OBD2')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('هنوز چیزی ذخیره نشده'),
                      SizedBox(height: 4),
                      Text('از داشبورد زنده OBD2، دکمه‌ی ذخیره را بزن',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  itemBuilder: (_, i) {
                    final s = _sessions[i];
                    final vehicleName = s.vehicleId != null ? _vehicleNames[s.vehicleId] : null;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ExpansionTile(
                        leading: Icon(
                          s.dtcCodes.isEmpty ? Icons.check_circle_outline : Icons.warning_amber,
                          color: s.dtcCodes.isEmpty ? Colors.green : Colors.orange,
                        ),
                        title: Text(_formatDate(s.timestamp)),
                        subtitle: Text(vehicleName ?? 'بدون خودروی مشخص'
                            '${s.dtcCodes.isNotEmpty ? ' · ${s.dtcCodes.length} کد خطا' : ' · بدون کد خطا'}'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ...Obd2Pids.dashboardPids.map((p) {
                                  final v = s.lastReadings[p.code];
                                  if (v == null) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(p.name, style: const TextStyle(fontSize: 12.5)),
                                        Text('${v.toStringAsFixed(1)} ${p.unit}',
                                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  );
                                }),
                                if (s.dtcCodes.isNotEmpty) ...[
                                  const Divider(),
                                  ...s.dtcCodes.map((c) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text('$c — ${DtcDecoder.describe(c)}',
                                            style: const TextStyle(fontSize: 12, color: Colors.orange)),
                                      )),
                                ],
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      await Obd2LogRepository.delete(s.id);
                                      _load();
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    label: const Text('حذف', style: TextStyle(color: Colors.red)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 60) return '${diff.inMinutes} دقیقه پیش';
    if (diff.inHours < 24) return '${diff.inHours} ساعت پیش';
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}'
        ' - ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
