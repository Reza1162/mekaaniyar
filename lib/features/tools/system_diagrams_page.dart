import 'package:flutter/material.dart';
import 'flow_diagram_view.dart';

class SystemDiagramsPage extends StatelessWidget {
  const SystemDiagramsPage({super.key});

  static final List<SystemDiagram> _diagrams = [
    SystemDiagram(
      title: 'چرخه‌ی سیستم خنک‌کاری',
      description: 'مسیر گردش مایع خنک‌کننده بین موتور و رادیاتور، به کنترل ترموستات.',
      color: Colors.blue,
      isLoop: true,
      nodes: [
        FlowNode('واترپمپ', Icons.water_drop_outlined, note: 'پمپاژ مایع'),
        FlowNode('بلوک موتور', Icons.settings_suggest, note: 'جذب گرما'),
        FlowNode('ترموستات', Icons.thermostat, note: 'کنترل مسیر'),
        FlowNode('رادیاتور', Icons.grid_view, note: 'دفع گرما'),
        FlowNode('فن رادیاتور', Icons.air, note: 'کمک به خنک‌سازی'),
      ],
    ),
    SystemDiagram(
      title: 'سیستم هیدرولیک ترمز',
      description: 'مسیر انتقال فشار از پدال تا کالیپر/کاسه‌چرخ هر چرخ.',
      color: Colors.red,
      nodes: [
        FlowNode('پدال ترمز', Icons.touch_app, note: 'نیروی راننده'),
        FlowNode('بوستر خلأ', Icons.compress, note: 'تقویت نیرو'),
        FlowNode('سیلندر اصلی', Icons.opacity, note: 'تولید فشار'),
        FlowNode('توزیع‌کننده', Icons.call_split, note: 'تقسیم به ۴ چرخ'),
        FlowNode('کالیپر/کاسه', Icons.album, note: 'فشردن لنت'),
      ],
    ),
    SystemDiagram(
      title: 'سیستم شارژ باتری',
      description: 'مسیر تولید و تنظیم برق برای شارژ باتری و تغذیه مصرف‌کننده‌ها.',
      color: Colors.amber.shade800,
      nodes: [
        FlowNode('موتور', Icons.settings, note: 'نیروی محرکه'),
        FlowNode('آلترناتور', Icons.electric_bolt, note: 'تولید برق AC'),
        FlowNode('رگولاتور', Icons.tune, note: 'یکسوسازی + تنظیم ولتاژ'),
        FlowNode('باتری', Icons.battery_charging_full, note: 'ذخیره برق'),
        FlowNode('مصرف‌کننده‌ها', Icons.lightbulb_outline, note: 'چراغ، رادیو...'),
      ],
    ),
    SystemDiagram(
      title: 'چرخه‌ی سیستم کولر گازی',
      description: 'چرخه‌ی تراکم و انبساط گاز مبرد برای خنک‌کردن کابین.',
      color: Colors.teal,
      isLoop: true,
      nodes: [
        FlowNode('کمپرسور', Icons.compress, note: 'فشرده‌سازی گاز'),
        FlowNode('کندانسور', Icons.grid_view, note: 'مایع‌شدن گاز'),
        FlowNode('فیلتر درایر', Icons.filter_alt_outlined, note: 'خشک‌کردن/فیلتر'),
        FlowNode('شیر انبساط', Icons.change_history, note: 'افت فشار ناگهانی'),
        FlowNode('اواپراتور', Icons.ac_unit, note: 'جذب گرمای کابین'),
      ],
    ),
    SystemDiagram(
      title: 'مسیر سوخت‌رسانی (انژکتوری)',
      description: 'مسیر انتقال بنزین از باک تا سوپاپ ورودی سیلندر.',
      color: Colors.orange.shade800,
      nodes: [
        FlowNode('باک سوخت', Icons.local_gas_station, note: 'ذخیره بنزین'),
        FlowNode('پمپ بنزین', Icons.opacity, note: 'ایجاد فشار'),
        FlowNode('فیلتر سوخت', Icons.filter_alt_outlined, note: 'حذف ناخالصی'),
        FlowNode('ریل سوخت', Icons.linear_scale, note: 'توزیع به انژکتورها'),
        FlowNode('انژکتور', Icons.water_drop, note: 'پاشش داخل سیلندر'),
      ],
    ),
    SystemDiagram(
      title: 'مدار روغن‌کاری موتور',
      description: 'مسیر گردش روغن برای روان‌کاری و خنک‌کاری قطعات متحرک موتور.',
      color: Colors.brown,
      isLoop: true,
      nodes: [
        FlowNode('کارتر روغن', Icons.oil_barrel, note: 'مخزن ذخیره'),
        FlowNode('پمپ روغن', Icons.settings_input_component, note: 'ایجاد فشار'),
        FlowNode('فیلتر روغن', Icons.filter_alt_outlined, note: 'حذف ذرات'),
        FlowNode('گالری روغن', Icons.linear_scale, note: 'توزیع در موتور'),
        FlowNode('یاتاقان‌ها/سوپاپ', Icons.settings, note: 'روان‌کاری قطعات'),
      ],
    ),
    SystemDiagram(
      title: 'سیستم جرقه‌زنی (آتش‌زنی)',
      description: 'مسیر تولید و انتقال جرقه از باتری تا شمع، در سیستم‌های مدرن کویل مستقیم.',
      color: Colors.deepPurple,
      nodes: [
        FlowNode('باتری', Icons.battery_charging_full, note: 'منبع ولتاژ ۱۲ ولت'),
        FlowNode('ECU', Icons.memory, note: 'تعیین زمان جرقه'),
        FlowNode('کویل آتش‌زنی', Icons.bolt, note: 'تبدیل به ولتاژ بالا'),
        FlowNode('شمع', Icons.flash_on, note: 'ایجاد جرقه در سیلندر'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دیاگرام سیستم‌های خودرو')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _diagrams.length,
        itemBuilder: (_, i) {
          final d = _diagrams[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: d.color)),
                  const SizedBox(height: 8),
                  FlowDiagramView(diagram: d),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
