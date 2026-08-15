import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/pro_manager.dart';

class ProPage extends StatelessWidget {
  const ProPage({super.key});

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
                    onPressed: () async {
                      // اینجا درگاه پرداخت وصل می‌شود
                      // فعلاً برای تست:
                      await ProManager.activate();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('نسخه حرفه‌ای فعال شد')),
                      );
                      Navigator.of(context).pop();
                    },
                    child: const Text('خرید و فعال‌سازی'),
                  ),
                ),
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
