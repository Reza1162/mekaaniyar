import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EngineDisplacementCalculator extends StatefulWidget {
  const EngineDisplacementCalculator({super.key});
  @override
  State<EngineDisplacementCalculator> createState() => _State();
}

class _State extends State<EngineDisplacementCalculator> {
  final _bore = TextEditingController();
  final _stroke = TextEditingController();
  final _cyl = TextEditingController(text: '4');
  String _result = '';

  void _calculate() {
    final bore = double.tryParse(_bore.text);
    final stroke = double.tryParse(_stroke.text);
    final cyl = double.tryParse(_cyl.text);
    if (bore == null || stroke == null || cyl == null) return;

    final singleVol = pi * (bore / 2) * (bore / 2) * stroke / 1000;
    final total = singleVol * cyl;
    final totalCC = total;
    final totalLiter = total / 1000;

    setState(() => _result =
        'حجم یک سیلندر: ${singleVol.toStringAsFixed(1)} cc\n'
        'حجم کل: ${totalCC.toStringAsFixed(0)} cc\n'
        'حجم کل: ${totalLiter.toStringAsFixed(3)} لیتر\n\n'
        '${totalCC < 800 ? "موتور کوچک (اسکوتر/موتور سیکلت)" : totalCC < 1400 ? "موتور کم‌حجم" : totalCC < 2000 ? "موتور معمولی" : totalCC < 3000 ? "موتور بزرگ" : "موتور خیلی بزرگ"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محاسبه حجم موتور')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_bore, 'قطر سیلندر - Bore (mm)'),
          _field(_stroke, 'کورس پیستون - Stroke (mm)'),
          _field(_cyl, 'تعداد سیلندر'),
          const SizedBox(height: 16),
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
