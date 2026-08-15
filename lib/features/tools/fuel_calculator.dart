import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FuelCalculator extends StatefulWidget {
  const FuelCalculator({super.key});
  @override
  State<FuelCalculator> createState() => _FuelCalculatorState();
}

class _FuelCalculatorState extends State<FuelCalculator> {
  final _distanceCtrl = TextEditingController();
  final _fuelCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _consumption = '';
  String _cost = '';

  void _calculate() {
    final distance = double.tryParse(_distanceCtrl.text);
    final fuel = double.tryParse(_fuelCtrl.text);
    final price = double.tryParse(_priceCtrl.text);
    if (distance == null || fuel == null || distance == 0) return;
    final consumption = fuel / distance * 100;
    setState(() {
      _consumption = consumption.toStringAsFixed(1);
      if (price != null) {
        _cost = (fuel * price).toStringAsFixed(0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('محاسبه مصرف سوخت')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _distanceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'مسافت طی شده (km)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _fuelCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'سوخت مصرف شده (لیتر)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'قیمت هر لیتر (تومان) — اختیاری',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _calculate, child: const Text('محاسبه')),
          ),
          if (_consumption.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('$_consumption لیتر در ۱۰۰ کیلومتر',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                  if (_cost.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('هزینه سوخت: $_cost تومان',
                        style: const TextStyle(color: Colors.grey)),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    double.parse(_consumption) < 7
                        ? '✅ مصرف عالی'
                        : double.parse(_consumption) < 10
                            ? '👍 مصرف نرمال'
                            : double.parse(_consumption) < 13
                                ? '⚠️ مصرف بالا'
                                : '🔴 مصرف خیلی بالا — بررسی کنید',
                    style: TextStyle(
                      color: double.parse(_consumption) > 13
                          ? Colors.red
                          : AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
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
