import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'dart:math';

class RpmCalculator extends StatefulWidget {
  const RpmCalculator({super.key});
  @override
  State<RpmCalculator> createState() => _RpmCalculatorState();
}

class _RpmCalculatorState extends State<RpmCalculator> {
  final _speedCtrl = TextEditingController();
  final _tyreSizeCtrl = TextEditingController(text: '185/65R15');
  double? _result;
  int _selectedGear = 0;

  final List<Map<String, dynamic>> _commonGearRatios = [
    {'name': 'دنده ۱', 'ratio': 3.545},
    {'name': 'دنده ۲', 'ratio': 1.904},
    {'name': 'دنده ۳', 'ratio': 1.310},
    {'name': 'دنده ۴', 'ratio': 0.969},
    {'name': 'دنده ۵', 'ratio': 0.815},
  ];

  double _parseTyreCircumference(String size) {
    try {
      final parts = size.replaceAll('R', '/').split('/');
      final width = double.parse(parts[0]);
      final aspect = double.parse(parts[1]) / 100;
      final rimInch = double.parse(parts[2]);
      final rimMm = rimInch * 25.4;
      final tyreHeight = width * aspect;
      final diameter = rimMm + 2 * tyreHeight;
      return diameter * pi / 1000;
    } catch (_) {
      return 1.87;
    }
  }

  void _calculate() {
    final speed = double.tryParse(_speedCtrl.text);
    if (speed == null) return;
    final circumference = _parseTyreCircumference(_tyreSizeCtrl.text);
    final gearRatio = _commonGearRatios[_selectedGear]['ratio'] as double;
    const finalDriveRatio = 4.06;
    final rpm = (speed / 3.6) / circumference * 60 * gearRatio * finalDriveRatio;
    setState(() => _result = rpm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محاسبه دور موتور')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('سایز تایر:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _tyreSizeCtrl,
            decoration: const InputDecoration(
              labelText: 'سایز تایر (مثال: 185/65R15)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('دنده:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(_commonGearRatios.length, (i) {
              return ChoiceChip(
                label: Text(_commonGearRatios[i]['name']),
                selected: _selectedGear == i,
                onSelected: (_) => setState(() => _selectedGear = i),
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(color: _selectedGear == i ? Colors.white : null),
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _speedCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'سرعت (km/h)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text('محاسبه'),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('دور موتور تخمینی',
                      style: TextStyle(color: AppTheme.primary)),
                  const SizedBox(height: 8),
                  Text('${_result!.toStringAsFixed(0)} RPM',
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                  const SizedBox(height: 8),
                  Text(
                    _result! > 6000
                        ? '⚠️ بالاتر از محدوده ایمن'
                        : _result! > 4000
                            ? 'دور بالا'
                            : _result! > 2000
                                ? 'دور اقتصادی'
                                : 'دور پایین',
                    style: TextStyle(
                        color: _result! > 6000 ? Colors.red : AppTheme.primary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
