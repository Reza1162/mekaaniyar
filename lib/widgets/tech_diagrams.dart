import 'package:flutter/material.dart';

/// One box in a horizontal flow diagram.
class FlowItem {
  final String label;
  final String? sublabel;
  final Color color;
  const FlowItem(this.label, {this.sublabel, this.color = const Color(0xFF5A7CA0)});
}

/// A simple, theme-friendly horizontal flow diagram built with native
/// widgets (no SVG, no external assets) so Persian text always renders
/// correctly using the app's own fonts.
class FlowDiagram extends StatelessWidget {
  final List<FlowItem> items;
  final String? caption;
  const FlowDiagram({super.key, required this.items, this.caption});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            reverse: true, // start scrolled to the right for RTL content
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _FlowBox(item: items[i]),
                  if (i != items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.arrow_back, size: 18, color: Colors.grey.shade500),
                    ),
                ],
              ],
            ),
          ),
          if (caption != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Text(
                caption!,
                textAlign: TextAlign.center,
                style: TextStyle(fontFamily: 'Vazir', fontSize: 12, color: Colors.grey.shade700),
              ),
            ),
        ],
      ),
    );
  }
}

class _FlowBox extends StatelessWidget {
  final FlowItem item;
  const _FlowBox({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: item.color.withOpacity(0.12),
        border: Border.all(color: item.color.withOpacity(0.55)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Vazir',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: item.color.withOpacity(0.95),
            ),
          ),
          if (item.sublabel != null) ...[
            const SizedBox(height: 3),
            Text(
              item.sublabel!,
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Vazir', fontSize: 10.5, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }
}

/// چرخه چهار زمانه موتور بنزینی
class FourStrokeDiagram extends StatelessWidget {
  const FourStrokeDiagram({super.key});
  @override
  Widget build(BuildContext context) {
    return const FlowDiagram(
      items: [
        FlowItem('مکش', sublabel: 'سوپاپ ورودی باز', color: Color(0xFF3B7A57)),
        FlowItem('تراکم', sublabel: 'هر دو سوپاپ بسته', color: Color(0xFF5A7CA0)),
        FlowItem('انبساط', sublabel: 'قدرت / احتراق', color: Color(0xFFB2691A)),
        FlowItem('تخلیه', sublabel: 'سوپاپ خروجی باز', color: Color(0xFFB23A3A)),
      ],
    );
  }
}

/// سیستم خنک‌کاری موتور
class CoolingSystemDiagram extends StatelessWidget {
  const CoolingSystemDiagram({super.key});
  @override
  Widget build(BuildContext context) {
    return const FlowDiagram(
      caption: 'مسیر برگشت: پمپ آب دوباره مایع را به موتور می‌فرستد — منبع انبساط انبساط حرارتی را جبران می‌کند',
      items: [
        FlowItem('موتور', sublabel: 'تولید حرارت', color: Color(0xFFC97A5E)),
        FlowItem('ترموستات', sublabel: '۸۲-۹۵°C', color: Color(0xFFC99A3B)),
        FlowItem('رادیاتور', sublabel: 'دفع حرارت', color: Color(0xFF5A7CA0)),
        FlowItem('فن', sublabel: 'خنک‌کاری اضافه', color: Color(0xFF5A7CA0)),
        FlowItem('پمپ آب', sublabel: 'گردش مایع', color: Color(0xFF2C3E50)),
      ],
    );
  }
}

/// سیستم توربوشارژ
class TurboSystemDiagram extends StatelessWidget {
  const TurboSystemDiagram({super.key});
  @override
  Widget build(BuildContext context) {
    return const FlowDiagram(
      caption: 'Wastegate فشار بوست را با هدایت بخشی از گاز اگزوز به دور توربین کنترل می‌کند',
      items: [
        FlowItem('اگزوز موتور', sublabel: 'گاز داغ', color: Color(0xFFC97A5E)),
        FlowItem('توربین', sublabel: '۹۰۰-۱۰۰۰°C', color: Color(0xFFC97A5E)),
        FlowItem('کمپرسور', sublabel: 'فشرده‌سازی هوا', color: Color(0xFF5A7CA0)),
        FlowItem('اینترکولر', sublabel: 'خنک‌کردن هوا', color: Color(0xFF5A7CA0)),
        FlowItem('منیفولد ورودی', sublabel: 'ورود به سیلندر', color: Color(0xFF3B7A57)),
      ],
    );
  }
}
