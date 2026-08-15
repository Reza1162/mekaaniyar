import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'rpm_calculator.dart';
import 'unit_converter.dart';
import 'fuel_calculator.dart';
import 'gear_ratio_calculator.dart';
import 'injector_calculator.dart';
import 'timing_calculator.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'title': 'محاسبه دور موتور', 'subtitle': 'RPM از سرعت و دنده', 'icon': Icons.speed, 'page': const RpmCalculator()},
      {'title': 'تبدیل واحد', 'subtitle': 'فشار، دما، توان، گشتاور', 'icon': Icons.swap_horiz, 'page': const UnitConverter()},
      {'title': 'مصرف سوخت', 'subtitle': 'محاسبه مصرف واقعی', 'icon': Icons.local_gas_station, 'page': const FuelCalculator()},
      {'title': 'نسبت دنده', 'subtitle': 'محاسبه نسبت انتقال', 'icon': Icons.settings, 'page': const GearRatioCalculator()},
      {'title': 'محاسبه انژکتور', 'subtitle': 'دبی و زمان پاشش', 'icon': Icons.water_drop, 'page': const InjectorCalculator()},
      {'title': 'تایمینگ جرقه', 'subtitle': 'محاسبه پیش‌جرقه', 'icon': Icons.bolt, 'page': const TimingCalculator()},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('ابزارهای محاسباتی')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tools.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final t = tools[i];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryLight,
                child: Icon(t['icon'] as IconData, color: AppTheme.primary),
              ),
              title: Text(t['title'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(t['subtitle'] as String),
              trailing: const Icon(Icons.chevron_left, color: Colors.grey),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => t['page'] as Widget),
              ),
            ),
          );
        },
      ),
    );
  }
}
