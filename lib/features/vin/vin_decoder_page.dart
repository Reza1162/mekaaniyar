import 'package:flutter/material.dart';
import '../../data/vin_decoder.dart';

class VinDecoderPage extends StatefulWidget {
  const VinDecoderPage({super.key});

  @override
  State<VinDecoderPage> createState() => _VinDecoderPageState();
}

class _VinDecoderPageState extends State<VinDecoderPage> {
  final _controller = TextEditingController();
  VinInfo? _result;
  bool _attempted = false;

  void _decode() {
    setState(() {
      _attempted = true;
      _result = VinDecoder.decode(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('رمزگشایی شماره شاسی (VIN)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'شماره شاسی (VIN) ۱۷ رقمی/حرفی معمولاً روی برگه سبز، زیر شیشه جلو (سمت راننده) یا داخل درگاه درب راننده حک شده.',
              style: TextStyle(fontSize: 12.5, color: Colors.grey, height: 1.7),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              maxLength: 17,
              decoration: const InputDecoration(
                labelText: 'شماره VIN',
                hintText: 'مثلاً NAAJ11AA0J1234567',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _decode,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('رمزگشایی'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_attempted) _buildResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildResult() {
    final r = _result!;
    if (!r.validFormat) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Text(
          'فرمت VIN معتبر نیست. باید دقیقاً ۱۷ کاراکتر باشد و شامل حروف I، O، Q نباشد.',
          style: TextStyle(color: Colors.red),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('سازنده', r.manufacturer.isEmpty ? 'در پایگاه ما ثبت نشده' : r.manufacturer),
            const SizedBox(height: 8),
            _row(
              'سال تولید احتمالی',
              r.possibleYears.isEmpty
                  ? 'قابل تشخیص نیست'
                  : r.possibleYears.map((y) => y.toString()).join(' یا '),
            ),
            if (r.possibleYears.length > 1) ...[
              const SizedBox(height: 8),
              const Text(
                'چون این کد هر ۳۰ سال تکرار می‌شود، برای تشخیص دقیق سال، به ظاهر و مشخصات خودرو هم توجه کنید.',
                style: TextStyle(fontSize: 11.5, color: Colors.grey),
              ),
            ],
            if (r.manufacturer.isEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'این کد سازنده هنوز در پایگاه‌ی محلی مکانیار ثبت نشده. برای استعلام دقیق‌تر می‌توانید از سایت‌های '
                'رسمی رمزگشایی VIN یا کارشناس رسمی همان برند کمک بگیرید.',
                style: TextStyle(fontSize: 12, color: Colors.orange),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.left,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
