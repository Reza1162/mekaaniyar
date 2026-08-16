import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class OhmLawCalculator extends StatefulWidget {
  const OhmLawCalculator({super.key});
  @override
  State<OhmLawCalculator> createState() => _State();
}

class _State extends State<OhmLawCalculator> {
  final _v = TextEditingController();
  final _i = TextEditingController();
  final _r = TextEditingController();
  final _p = TextEditingController();
  String _result = '';

  void _calculate() {
    final v = double.tryParse(_v.text);
    final i = double.tryParse(_i.text);
    final r = double.tryParse(_r.text);
    final p = double.tryParse(_p.text);

    double? vv, ii, rr, pp;

    if (v != null && i != null) {
      vv = v; ii = i; rr = v / i; pp = v * i;
    } else if (v != null && r != null) {
      vv = v; rr = r; ii = v / r; pp = v * v / r;
    } else if (i != null && r != null) {
      ii = i; rr = r; vv = i * r; pp = i * i * r;
    } else if (p != null && v != null) {
      pp = p; vv = v; ii = p / v; rr = v * v / p;
    } else if (p != null && i != null) {
      pp = p; ii = i; vv = p / i; rr = p / (i * i);
    } else if (p != null && r != null) {
      pp = p; rr = r; vv = sqrt(p * r); ii = sqrt(p / r);
    } else {
      setState(() => _result = 'حداقل ۲ مقدار وارد کنید');
      return;
    }

    setState(() => _result =
        'ولتاژ (V): ${vv!.toStringAsFixed(3)} ولت\n'
        'جریان (I): ${ii!.toStringAsFixed(3)} آمپر\n'
        'مقاومت (R): ${rr!.toStringAsFixed(3)} اهم\n'
        'توان (P): ${pp!.toStringAsFixed(3)} وات');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قانون اهم')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('حداقل ۲ مقدار وارد کنید:', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          _field(_v, 'ولتاژ (V) — ولت'),
          _field(_i, 'جریان (I) — آمپر'),
          _field(_r, 'مقاومت (R) — اهم'),
          _field(_p, 'توان (P) — وات'),
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
