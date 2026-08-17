import 'package:flutter/material.dart';
import 'package:bluetooth_classic/models/device.dart';
import '../../data/obd2/obd2_service.dart';
import 'obd2_dashboard_page.dart';

class Obd2ConnectPage extends StatefulWidget {
  const Obd2ConnectPage({super.key});

  @override
  State<Obd2ConnectPage> createState() => _Obd2ConnectPageState();
}

class _Obd2ConnectPageState extends State<Obd2ConnectPage> {
  final _service = Obd2Service();
  List<Device> _devices = [];
  bool _loading = true;
  String? _connectingAddress;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _service.initPermissions();
      final devices = await _service.getPairedDevices();
      setState(() {
        _devices = devices;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'دسترسی به بلوتوث ممکن نشد. مطمئن شوید بلوتوث گوشی روشن است و دسترسی داده‌اید.';
      });
    }
  }

  Future<void> _connect(Device device) async {
    setState(() => _connectingAddress = device.address);
    final ok = await _service.connect(device);
    if (!mounted) return;
    setState(() => _connectingAddress = null);
    if (ok) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => Obd2DashboardPage(service: _service)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اتصال به دانگل OBD2 ناموفق بود. دوباره امتحان کنید.')),
      );
    }
  }

  @override
  void dispose() {
    if (_service.status != Obd2Status.ready) {
      _service.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اتصال OBD2'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'دانگل OBD2 (ELM327 بلوتوث) را ابتدا از تنظیمات بلوتوث گوشی پیر (pair) کنید، '
                    'سپس از این صفحه به آن متصل شوید. دانگل معمولاً به سوکت زیر فرمان خودرو وصل می‌شود '
                    'و باید سوییچ خودرو روشن باشد.',
                    style: TextStyle(fontSize: 12.5, height: 1.7),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                Expanded(
                  child: _devices.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bluetooth_disabled, size: 48, color: Colors.grey),
                              const SizedBox(height: 12),
                              const Text('هیچ دستگاه پیرشده‌ای پیدا نشد'),
                              const SizedBox(height: 4),
                              const Text('اول دانگل را از تنظیمات بلوتوث گوشی پیر کنید',
                                  style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _devices.length,
                          itemBuilder: (_, i) {
                            final d = _devices[i];
                            final connecting = _connectingAddress == d.address;
                            return ListTile(
                              leading: const Icon(Icons.bluetooth),
                              title: Text(d.name ?? 'دستگاه ناشناس'),
                              subtitle: Text(d.address ?? ''),
                              trailing: connecting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.chevron_left),
                              onTap: connecting ? null : () => _connect(d),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
