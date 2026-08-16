import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'rpm_calculator.dart';
import 'unit_converter.dart';
import 'fuel_calculator.dart';
import 'gear_ratio_calculator.dart';
import 'injector_calculator.dart';
import 'timing_calculator.dart';
import 'compression_ratio.dart';
import 'ohm_law.dart';
import 'belt_pulley.dart';
import 'battery_calculator.dart';
import 'tyre_calculator.dart';
import 'engine_displacement.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'title': 'محاسبه دور موتور', 'subtitle': 'RPM از سرعت و دنده', 'icon': Icons.speed, 'color': Colors.blue, 'page': const RpmCalculator()},
      {'title': 'تبدیل واحد', 'subtitle': 'فشار، دما، توان، گشتاور', 'icon': Icons.swap_horiz, 'color': Colors.teal, 'page': const UnitConverter()},
      {'title': 'مصرف سوخت', 'subtitle': 'محاسبه مصرف واقعی + هزینه', 'icon': Icons.local_gas_station, 'color': Colors.orange, 'page': const FuelCalculator()},
      {'title': 'نسبت دنده', 'subtitle': 'محاسبه نسبت انتقال', 'icon': Icons.settings, 'color': Colors.purple, 'page': const GearRatioCalculator()},
      {'title': 'محاسبه انژکتور', 'subtitle': 'دبی و زمان پاشش', 'icon': Icons.water_drop, 'color': Colors.cyan, 'page': const InjectorCalculator()},
      {'title': 'تایمینگ جرقه', 'subtitle': 'محاسبه پیش‌جرقه', 'icon': Icons.bolt, 'color': Colors.amber, 'page': const TimingCalculator()},
      {'title': 'نسبت تراکم', 'subtitle': 'محاسبه Compression Ratio', 'icon': Icons.compress, 'color': Colors.red, 'page': const CompressionRatioCalculator()},
      {'title': 'قانون اهم', 'subtitle': 'ولتاژ، جریان، مقاومت، توان', 'icon': Icons.electric_bolt, 'color': Colors.indigo, 'page': const OhmLawCalculator()},
      {'title': 'تسمه و پولی', 'subtitle': 'نسبت و طول تسمه', 'icon': Icons.rotate_right, 'color': Colors.brown, 'page': const BeltPulleyCalculator()},
      {'title': 'تست باتری', 'subtitle': 'وضعیت از روی ولتاژ', 'icon': Icons.battery_charging_full, 'color': Colors.green, 'page': const BatteryCalculator()},
      {'title': 'مقایسه سایز تایر', 'subtitle': 'اختلاف قطر و سرعت‌سنج', 'icon': Icons.tire_repair, 'color': Colors.grey, 'page': const TyreCalculator()},
      {'title': 'حجم موتور', 'subtitle': 'از Bore و Stroke', 'icon': Icons.engineering, 'color': Colors.deepOrange, 'page': const EngineDisplacementCalculator()},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('ابزارهای محاسباتی')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: tools.length,
        itemBuilder: (context, i) {
          final t = tools[i];
          final color = t['color'] as Color;
          return InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => t['page'] as Widget),
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border(right: BorderSide(color: color, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(t['icon'] as IconData, color: color, size: 28),
                  const Spacer(),
                  Text(t['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(t['subtitle'] as String,
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
