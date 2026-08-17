import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BatteryCalculator extends StatefulWidget {
  const BatteryCalculator({super.key});
  @override
  State<BatteryCalculator> createState() => _State();
}

class _State extends State<BatteryCalculator> {
  final _voltage = TextEditingController();
  String _result = '';
  String _status = '';
  Color _color = AppTheme.primary;

  void _calculate() {
    final v = double.tryParse(_voltage.text);
    if (v == null) return;

    String status;
    int charge;
    Color color;

    if (v >= 12.7) { status = 'شارژ کامل ✅'; charge = 100; color = AppTheme.primary; }
    else if (v >= 12.5) { status = 'شارژ خوب'; charge = 90; color = AppTheme.primary; }
    else if (v >= 12.4) { status = 'شارژ متوسط'; charge = 75; color = Colors.green; }
    else if (v >= 12.2) { status = 'شارژ کم'; charge = 50; color = Colors.orange; }
    else if (v >= 12.0) { status = 'شارژ خیلی کم ⚠️'; charge = 25; color = Colors.orange; }
    else if (v >= 11.8) { status = 'تقریباً خالی 🔴'; charge = 10; color = Colors.red; }
    else { status = 'خالی — تعویض لازم 🔴'; charge = 0; color = Colors.red; }

    String action = '';
    if (v < 12.0) action = '\n→ باتری را شارژ کنید';
    if (v < 11.8) action = '\n→ باتری باید تعویض شود';
    if (v > 12.4 && v < 13.5) action = '\n→ دینام را تست کنید';
    if (v > 14.8) action = '\n→ ریگولاتور دینام خراب است!';

    setState(() {
      _status = status;
      _color = color;
      _result = 'شارژ تخمینی: $charge٪\nوضعیت: $status$action';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تست باتری')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(14)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('راهنمای اندازه‌گیری:', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                SizedBox(height: 8),
                Text('• موتور خاموش و ۳۰ دقیقه استراحت کرده باشد\n• مولتی‌متر روی DC Voltage\n• پروب قرمز روی + و مشکی روی -', style: TextStyle(color: AppTheme.primary, height: 1.6)),
              ],
            ),
          ),
          TextField(
            controller: _voltage,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'ولتاژ باتری (ولت)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _calculate, child: const Text('تشخیص وضعیت')),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: _color)),
              child: Text(_result, style: TextStyle(fontSize: 15, height: 1.8, color: _color, fontWeight: FontWeight.w600)),
            ),
          ],
        ],
      ),
    );
  }
}
