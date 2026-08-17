import 'package:flutter/material.dart';
import '../../data/obd2/obd2_service.dart';
import '../../data/obd2/dtc_decoder.dart';
import 'freeze_frame_page.dart';

class DtcPage extends StatefulWidget {
  final Obd2Service service;
  const DtcPage({super.key, required this.service});

  @override
  State<DtcPage> createState() => _DtcPageState();
}

class _DtcPageState extends State<DtcPage> {
  List<String>? _codes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _read();
  }

  Future<void> _read() async {
    setState(() => _loading = true);
    final codes = await widget.service.readDtcs();
    if (!mounted) return;
    setState(() {
      _codes = codes;
      _loading = false;
    });
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('پاک کردن کدهای خطا'),
        content: const Text(
          'کدهای خطا فقط زمانی باید پاک شوند که علت واقعی مشکل رفع شده باشد. '
          'پاک کردن بدون رفع علت باعث پنهان‌ماندن مشکل می‌شود و ممکن است مانیتورهای '
          'آماده‌بودن خودرو (readiness) هم ریست شود. ادامه می‌دهید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('پاک کن'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await widget.service.clearDtcs();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'کدهای خطا پاک شدند' : 'پاک کردن ناموفق بود')),
    );
    _read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کدهای خطا (DTC)'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _read),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_codes == null || _codes!.isEmpty)
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, size: 48, color: Colors.green),
                      SizedBox(height: 12),
                      Text('هیچ کد خطایی ثبت نشده است'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _codes!.length,
                  itemBuilder: (_, i) {
                    final code = _codes![i];
                    return ListTile(
                      leading: const Icon(Icons.warning_amber, color: Colors.orange),
                      title: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DtcDecoder.describe(code)),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FreezeFramePage(service: widget.service, code: code),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: (_codes != null && _codes!.isNotEmpty)
          ? FloatingActionButton.extended(
              onPressed: _confirmClear,
              icon: const Icon(Icons.delete_outline),
              label: const Text('پاک کردن کدها'),
            )
          : null,
    );
  }
}
