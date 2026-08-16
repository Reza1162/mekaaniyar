import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CompressionRatioCalculator extends StatefulWidget {
  const CompressionRatioCalculator({super.key});
  @override
  State<CompressionRatioCalculator> createState() => _State();
}

class _State extends State<CompressionRatioCalculator> {
  final _bore = TextEditingController();
  final _stroke = TextEditingController();
  final _chamber = TextEditingController();
  final _gasket = TextEditingController(text: '1.2');
  final _gasketBore = TextEditingController();
  final _deck = TextEditingController(text: '0.5');
  String _result = '';

  void _calculate() {
    final bore = double.tryParse(_bore.text);
    final stroke = double.tryParse(_stroke.text);
    final chamber = double.tryParse(_chamber.text);
    final gasket = double.tryParse(_gasket.text);
    final gasketBore = double.tryParse(_gasketBore.text.isEmpty ? _bore.text : _gasketBore.text);
    final deck = double.tryParse(_deck.text);
    if (bore == null || stroke == null || chamber == null) return;

    final r = bore / 2;
    final sweptVol = pi * r * r * stroke / 1000;
    final chamberVol = chamber;
    final gasketVol = gasketBore != null && gasket != null
        ? pi * (gasketBore / 2) * (gasketBore / 2) * gasket / 1000
        : 0.0;
    final deckVol = deck != null ? pi * r * r * deck / 1000 : 0.0;
    final clearanceVol = chamberVol + gasketVol + deckVol;
    final cr = (sweptVol + clearanceVol) / clearanceVol;

    setState(() => _result =
        'حجم سیلندر: ${sweptVol.toStringAsFixed(2)} cc\n'
        'حجم فضای مرده: ${clearanceVol.toStringAsFixed(2)} cc\n'
        'نسبت تراکم: ${cr.toStringAsFixed(2)}:1\n\n'
        '${cr > 12 ? "⚠️ نیاز به بنزین اکتان بالا" : cr > 10 ? "✅ نرمال — بنزین معمولی" : "ℹ️ نسبت پایین"}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نسبت تراکم')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _field(_bore, 'قطر سیلندر - Bore (mm)'),
          _field(_stroke, 'کورس پیستون - Stroke (mm)'),
          _field(_chamber, 'حجم محفظه احتراق (cc)'),
          _field(_gasket, 'ضخامت واشر سرسیلندر (mm)'),
          _field(_gasketBore, 'قطر سوراخ واشر (mm) — اختیاری'),
          _field(_deck, 'فاصله پیستون تا سطح (mm)'),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _calculate, child: const Text('محاسبه')),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(_result, style: const TextStyle(fontSize: 15, height: 1.8, color: AppTheme.primary)),
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
