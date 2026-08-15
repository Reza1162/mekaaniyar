import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class InjectorCalculator extends StatefulWidget {
  const InjectorCalculator({super.key});
  @override
  State<InjectorCalculator> createState() => _InjectorCalculatorState();
}

class _InjectorCalculatorState extends State<InjectorCalculator> {
  final _powerCtrl = TextEditingController();
  final _bsfeCtrl = TextEditingController(text: '0.35');
  final _cylCtrl = TextEditingController(text: '4');
  String _result = '';

  void _calculate() {
    final power = double.tryParse(_powerCtrl.text);
    final bsfe = double.tryParse(_bsfeCtrl.text);
    final cyl = double.tryParse(_cylCtrl.text);
    if (power == null || bsfe == null || cyl == null) return;
    final totalFuel = power * bsfe;
    final perInjector = totalFuel / cyl;
    final flowRate = perInjector / 0.8;
    setState(() => _result =
        'مصرف کل: ${totalFuel.toStringAsFixed(1)} kg/h\n'
        'مصرف هر سیلندر: ${perInjector.toStringAsFixed(1)} kg/h\n'
        'دبی انژکتور (با ۸۰٪ duty): ${flowRate.toStringAsFixed(1)} kg/h\n'
        'معادل: ${(flowRate / 0.75).toStringAsFixed(0)} cc/min');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محاسبه انژکتور')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('توان موتور (HP):'),
          const SizedBox(height: 8),
          TextField(controller: _powerCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 14),
          const Text('ضریب مصرف سوخت BSFC (kg/kWh) — پیش‌فرض ۰.۳۵:'),
          const SizedBox(height: 8),
          TextField(controller: _bsfeCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 14),
          const Text('تعداد سیلندر:'),
          const SizedBox(height: 8),
          TextField(controller: _cylCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _calculate, child: const Text('محاسبه')),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(_result,
                  style: const TextStyle(fontSize: 16, color: AppTheme.primary, height: 1.8)),
            ),
          ],
        ],
      ),
    );
  }
}
