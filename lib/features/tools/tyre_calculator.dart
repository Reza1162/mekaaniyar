import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TyreCalculator extends StatefulWidget {
  const TyreCalculator({super.key});
  @override
  State<TyreCalculator> createState() => _State();
}

class _State extends State<TyreCalculator> {
  final _w1 = TextEditingController(text: '185');
  final _a1 = TextEditingController(text: '65');
  final _r1 = TextEditingController(text: '15');
  final _w2 = TextEditingController(text: '195');
  final _a2 = TextEditingController(text: '60');
  final _r2 = TextEditingController(text: '15');
  String _result = '';

  double _diameter(double w, double a, double r) =>
      r * 25.4 + 2 * w * a / 100;

  double _circumference(double w, double a, double r) =>
      _diameter(w, a, r) * pi;

  void _calculate() {
    final w1 = double.tryParse(_w1.text);
    final a1 = double.tryParse(_a1.text);
    final r1 = double.tryParse(_r1.text);
    final w2 = double.tryParse(_w2.text);
    final a2 = double.tryParse(_a2.text);
    final r2 = double.tryParse(_r2.text);
    if (w1 == null || a1 == null || r1 == null || w2 == null || a2 == null || r2 == null) return;

    final d1 = _diameter(w1, a1, r1);
    final d2 = _diameter(w2, a2, r2);
    final c1 = _circumference(w1, a1, r1);
    final c2 = _circumference(w2, a2, r2);
    final diff = (d2 - d1) / d1 * 100;
    final speedDiff = (c2 - c1) / c1 * 100;

    setState(() => _result =
        'تایر اصلی:\n  قطر: ${d1.toStringAsFixed(1)} mm | محیط: ${(c1/1000).toStringAsFixed(3)} m\n\n'
        'تایر جدید:\n  قطر: ${d2.toStringAsFixed(1)} mm | محیط: ${(c2/1000).toStringAsFixed(3)} m\n\n'
        'اختلاف قطر: ${diff.toStringAsFixed(1)}٪\n'
        'اختلاف سرعت‌سنج: ${speedDiff.toStringAsFixed(1)}٪\n\n'
        '${diff.abs() > 3 ? "⚠️ اختلاف زیاد — ممکن است با گلگیر تماس داشته باشد" : "✅ اختلاف قابل قبول"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مقایسه سایز تایر')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('تایر اصلی:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _field(_w1, 'عرض')),
            const SizedBox(width: 8),
            Expanded(child: _field(_a1, 'نسبت')),
            const SizedBox(width: 8),
            Expanded(child: _field(_r1, 'رینگ')),
          ]),
          const SizedBox(height: 16),
          const Text('تایر جدید:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _field(_w2, 'عرض')),
            const SizedBox(width: 8),
            Expanded(child: _field(_a2, 'نسبت')),
            const SizedBox(width: 8),
            Expanded(child: _field(_r2, 'رینگ')),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _calculate, child: const Text('مقایسه')),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.primaryLight, borderRadius: BorderRadius.circular(14)),
              child: Text(_result, style: const TextStyle(fontSize: 14, height: 1.8, color: AppTheme.primary)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label) =>
      TextField(controller: c, keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()));
}
