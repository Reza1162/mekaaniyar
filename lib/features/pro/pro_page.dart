import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/pro_manager.dart';
import '../../data/iap_service.dart';

class ProPage extends StatefulWidget {
  const ProPage({super.key});

  @override
  State<ProPage> createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  bool _purchasing = false;
  bool _storeChecked = false;
  IapStore _store = IapStore.none;

  @override
  void initState() {
    super.initState();
    _checkStore();
  }

  Future<void> _checkStore() async {
    final store = await IapService.detectStore();
    if (!mounted) return;
    setState(() {
      _store = store;
      _storeChecked = true;
    });
  }

  Future<void> _purchase() async {
    setState(() => _purchasing = true);
    final ok = await IapService.purchasePro();
    if (!mounted) return;
    setState(() => _purchasing = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نسخه حرفه‌ای فعال شد')),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_store == IapStore.none
              ? 'برای خرید باید از طریق اپلیکیشن بازار یا مایکت وارد شده باشید'
              : 'خرید ناموفق بود یا لغو شد'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('نسخه حرفه‌ای')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFF0D47A1)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: const [
                Icon(Icons.workspace_premium, color: Colors.amber, size: 48),
                SizedBox(height: 12),
                Text('مکانیار حرفه‌ای',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('دسترسی کامل به تمام فصل‌ها',
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _FeatureRow(text: 'گیربکس اتوماتیک — کامل'),
          const _FeatureRow(text: 'برق خودرو و ECU — کامل'),
          const _FeatureRow(text: 'انتقال حرکت و دیفرانسیل'),
          const _FeatureRow(text: 'تعلیق، فرمان و آلاینمنت'),
          const _FeatureRow(text: 'ترمز، ABS و ESP'),
          const _FeatureRow(text: 'هیبرید و خودروهای برقی'),
          const _FeatureRow(text: 'بوک‌مارک نامحدود'),
          const _FeatureRow(text: 'آپدیت محتوای رایگان'),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary, width: 2),
            ),
            child: Column(
              children: [
                const Text('خرید یکجا',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text(
                  '— تومان',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary),
                ),
                const SizedBox(height: 4),
                const Text('بدون اشتراک ماهانه',
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _purchasing ? null : _purchase,
                    child: _purchasing
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('خرید و فعال‌سازی'),
                  ),
                ),
                if (_storeChecked && _store == IapStore.none) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'برای خرید، این اپ را از کافه‌بازار یا مایکت نصب کرده باشید',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: Colors.orange),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String text;
  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
          const SizedBox(width: 10),
          Text(text),
        ],
      ),
    );
  }
}
