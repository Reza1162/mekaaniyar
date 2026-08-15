import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GearRatioCalculator extends StatefulWidget {
  const GearRatioCalculator({super.key});
  @override
  State<GearRatioCalculator> createState() => _GearRatioCalculatorState();
}

class _GearRatioCalculatorState extends State<GearRatioCalculator> {
  final _driveCtrl = TextEditingController();
  final _drivenCtrl = TextEditingController();
  final _finalCtrl = TextEditingController(text: '4.06');
  String _result = '';

  void _calculate() {
    final drive = double.tryParse(_driveCtrl.text);
    final driven = double.tryParse(_drivenCtrl.text);
    final finalDrive = double.tryParse(_finalCtrl.text);
    if (drive == null || driven == null || finalDrive == null || drive == 0) return;
    final gearRatio = driven / drive;
    final totalRatio = gearRatio * finalDrive;
    setState(() => _result =
        'نسبت دنده: ${gearRatio.toStringAsFixed(3)}\nنسبت کل: ${totalRatio.toStringAsFixed(3)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محاسبه نسبت دنده')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('تعداد دندانه چرخ‌دنده محرک (Drive):'),
          const SizedBox(height: 8),
          TextField(controller: _driveCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 14),
          const Text('تعداد دندانه چرخ‌دنده متحرک (Driven):'),
          const SizedBox(height: 8),
          TextField(controller: _drivenCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder())),
          const SizedBox(height: 14),
          const Text('نسبت دیفرانسیل (Final Drive):'),
          const SizedBox(height: 8),
          TextField(controller: _finalCtrl, keyboardType: TextInputType.number,
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            ),
          ],
        ],
      ),
    );
  }
}
