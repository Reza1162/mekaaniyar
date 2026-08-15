import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TimingCalculator extends StatefulWidget {
  const TimingCalculator({super.key});
  @override
  State<TimingCalculator> createState() => _TimingCalculatorState();
}

class _TimingCalculatorState extends State<TimingCalculator> {
  final _rpmCtrl = TextEditingController();
  final _baseTimingCtrl = TextEditingController(text: '10');
  String _result = '';

  void _calculate() {
    final rpm = double.tryParse(_rpmCtrl.text);
    final base = double.tryParse(_baseTimingCtrl.text);
    if (rpm == null || base == null) return;
    final advance = base + (rpm - 800) * 0.005;
    final maxAdvance = advance.clamp(base, base + 20);
    setState(() => _result =
        'پیش‌جرقه پایه: ${base.toStringAsFixed(1)}°\n'
        'پیش‌جرقه محاسبه‌شده: ${maxAdvance.toStringAsFixed(1)}° BTDC\n'
        '\nتوجه: این مقدار تخمینی است.\n'
        'برای تنظیم دقیق از تایمینگ لایت استفاده کنید.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محاسبه تایمینگ جرقه')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _rpmCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'دور موتور (RPM)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _baseTimingCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'پیش‌جرقه پایه (درجه)',
              border: OutlineInputBorder(),
            ),
          ),
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
                  style: const TextStyle(fontSize: 15, color: AppTheme.primary, height: 1.8)),
            ),
          ],
        ],
      ),
    );
  }
}
