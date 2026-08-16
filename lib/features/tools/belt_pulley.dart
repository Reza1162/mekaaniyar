import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BeltPulleyCalculator extends StatefulWidget {
  const BeltPulleyCalculator({super.key});
  @override
  State<BeltPulleyCalculator> createState() => _State();
}

class _State extends State<BeltPulleyCalculator> {
  final _d1 = TextEditingController();
  final _d2 = TextEditingController();
  final _rpm1 = TextEditingController();
  final _center = TextEditingController();
  String _result = '';

  void _calculate() {
    final d1 = double.tryParse(_d1.text);
    final d2 = double.tryParse(_d2.text);
    final rpm1 = double.tryParse(_rpm1.text);
    final center = double.tryParse(_center.text);
    if (d1 == null || d2 == null || rpm1 == null) return;

    final rpm2 = rpm1 * d1 / d2;
    final ratio = d2 / d1;

    String belt = '';
    if (center != null) {
      final beltLen = 2 * center + 3.1416 * (d1 + d2) / 2 + (d2 - d1) * (d2 - d1) / (4 * center);
      belt = '\nطول تسمه: ${beltLen.toStringAsFixed(0)} mm';
    }

    setState(() => _result =
        'دور پولی دوم: ${rpm2.toStringAsFixed(0)} RPM\n'
        'نسبت انتقال: ${ratio.toStringAsFixed(3)}\n'
        'نسبت کاهش: ${(1 / ratio).toStringAsFixed(3)}$belt');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محاسبه تسمه و پولی')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_d1, 'قطر پولی محرک (mm)'),
          _field(_d2, 'قطر پولی متحرک (mm)'),
          _field(_rpm1, 'دور پولی محرک (RPM)'),
          _field(_center, 'فاصله مراکز (mm) — اختیاری'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _calculate, child: const Text('محاسبه')),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(14)),
              child: Text(_result, style: const TextStyle(fontSize: 15, height: 2, color: AppTheme.primary)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(controller: c, keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())),
  );
}
