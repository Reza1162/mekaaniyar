import 'package:flutter/material.dart';
import '../../data/garage/garage_repository.dart';
import '../../data/garage/service_log_repository.dart';
import '../../data/garage/notification_service.dart';
import 'vehicle_form_page.dart';

class VehicleDetailPage extends StatefulWidget {
  final Vehicle vehicle;
  const VehicleDetailPage({super.key, required this.vehicle});

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  late Vehicle _vehicle;
  List<ServiceStatus> _statuses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final statuses = await ServiceLogRepository.statusFor(
        _vehicle.id, _vehicle.modelKey, _vehicle.currentKm);
    if (!mounted) return;
    setState(() {
      _statuses = statuses;
      _loading = false;
    });
    for (final s in statuses) {
      if (s.isOverdue) {
        NotificationService.notifyOverdueItem(_vehicle.nickname, s.item.title);
      }
    }
  }

  Future<void> _updateKm() async {
    final ctrl = TextEditingController(text: _vehicle.currentKm.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('بروزرسانی کیلومتر'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'کیلومتر فعلی'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
          FilledButton(
            onPressed: () => Navigator.pop(context, int.tryParse(ctrl.text)),
            child: const Text('ثبت'),
          ),
        ],
      ),
    );
    if (result == null) return;
    final updated = _vehicle.copyWith(currentKm: result);
    await GarageRepository.update(updated);
    setState(() => _vehicle = updated);
    _load();
  }

  Future<void> _markDone(ServiceStatus status) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ثبت انجام سرویس'),
        content: Text('«${status.item.title}» در کیلومتر ${_vehicle.currentKm} انجام شد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('بله، انجام شد')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ServiceLogRepository.markDone(
        _vehicle.id, status.item.title, _vehicle.currentKm, DateTime.now());
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_vehicle.nickname),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final edited = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => VehicleFormPage(existing: _vehicle)),
              );
              if (edited == true) {
                final list = await GarageRepository.getAll();
                setState(() => _vehicle = list.firstWhere((v) => v.id == _vehicle.id));
                _load();
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.speed),
                      title: Text('${_vehicle.currentKm} کیلومتر'),
                      subtitle: const Text('کیلومتر فعلی'),
                      trailing: TextButton(onPressed: _updateKm, child: const Text('بروزرسانی')),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('وضعیت سرویس‌های دوره‌ای',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  ..._statuses.map((s) => _ServiceStatusTile(status: s, onMarkDone: () => _markDone(s))),
                ],
              ),
            ),
    );
  }
}

class _ServiceStatusTile extends StatelessWidget {
  final ServiceStatus status;
  final VoidCallback onMarkDone;
  const _ServiceStatusTile({required this.status, required this.onMarkDone});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    if (status.isOverdue) {
      color = Colors.red;
      label = status.record == null ? 'هنوز ثبت نشده' : 'موعد گذشته';
    } else if (status.isDueSoon) {
      color = Colors.orange;
      label = '${status.kmRemaining} کیلومتر مانده';
    } else {
      color = Colors.green;
      label = '${status.kmRemaining} کیلومتر مانده';
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(Icons.build, color: color, size: 18)),
        title: Text(status.item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(label, style: TextStyle(color: color)),
        trailing: TextButton(onPressed: onMarkDone, child: const Text('انجام شد')),
      ),
    );
  }
}
