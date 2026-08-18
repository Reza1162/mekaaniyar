import 'package:flutter/material.dart';

class Obd2ConnectorDiagram extends StatelessWidget {
  const Obd2ConnectorDiagram({super.key});

  static const Map<int, String> _pinLabels = {
    2: 'J1850 Bus+',
    4: 'زمین بدنه',
    5: 'زمین سیگنال',
    6: 'CAN High',
    7: 'K-Line (ISO9141)',
    10: 'J1850 Bus-',
    14: 'CAN Low',
    15: 'L-Line (ISO9141)',
    16: '+12V باتری',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('دیاگرام سوکت OBD2')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'نمای رو‌به‌رو از سوکت OBD2 روی خودرو (نگاه از سمت داشبورد به بیرون)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            AspectRatio(
              aspectRatio: 1.8,
              child: CustomPaint(
                painter: _ConnectorPainter(),
                child: Container(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _pinLabels.entries
                    .map((e) => ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue.withOpacity(0.1),
                            child: Text('${e.key}', style: const TextStyle(fontSize: 12)),
                          ),
                          title: Text(e.value),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = Colors.blueGrey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    final fill = Paint()..color = Colors.blueGrey.shade50;

    // Trapezoid outline approximating the real D-shaped OBD2 shroud.
    final path = Path()
      ..moveTo(size.width * 0.08, size.height * 0.15)
      ..lineTo(size.width * 0.92, size.height * 0.15)
      ..lineTo(size.width * 0.98, size.height * 0.85)
      ..lineTo(size.width * 0.02, size.height * 0.85)
      ..close();
    canvas.drawPath(path, fill);
    canvas.drawPath(path, outline);

    // Two rows of 8 pins each (16 total), numbered left-to-right,
    // top row first -- matching the real SAE J1962 layout.
    const cols = 8;
    final rowY = [size.height * 0.38, size.height * 0.62];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    int pin = 1;
    for (final y in rowY) {
      for (int c = 0; c < cols; c++) {
        final x = size.width * (0.13 + c * (0.76 / (cols - 1)));
        canvas.drawCircle(Offset(x, y), 6, Paint()..color = Colors.blueGrey.shade700);
        textPainter.text = TextSpan(
          text: '$pin',
          style: const TextStyle(fontSize: 9, color: Colors.black87),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + 10));
        pin++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
