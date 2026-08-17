import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'legal_page.dart';

/// Wraps the app's home screen and shows a one-time disclaimer the user
/// must accept before using the app. Acceptance is stored locally.
class DisclaimerGate extends StatefulWidget {
  final Widget child;
  const DisclaimerGate({super.key, required this.child});

  @override
  State<DisclaimerGate> createState() => _DisclaimerGateState();
}

class _DisclaimerGateState extends State<DisclaimerGate> {
  static const _key = 'disclaimer_accepted_v1';
  bool? _accepted;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _accepted = prefs.getBool(_key) ?? false);
  }

  Future<void> _accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    setState(() => _accepted = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_accepted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_accepted == false) {
      return _DisclaimerScreen(onAccept: _accept);
    }
    return widget.child;
  }
}

class _DisclaimerScreen extends StatelessWidget {
  final VoidCallback onAccept;
  const _DisclaimerScreen({required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 48, color: Colors.blueGrey),
              const SizedBox(height: 16),
              const Text('پیش از استفاده بخوانید',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'مکانیار یک منبع آموزشی است و جایگزین مراجعه به مکانیک متخصص یا نمایندگی مجاز نیست. '
                    'هرگونه تعمیر یا تغییر روی خودرو (به‌ویژه ریمپ ECU) با ریسک همراه است و مسئولیت آن با شماست. '
                    'قابلیت اتصال OBD2 صرفاً برای مشاهده‌ی اطلاعات خودرو طراحی شده و نباید برای دور زدن سیستم آلایندگی یا ایمنی استفاده شود.\n\n'
                    'با ادامه، شرایط استفاده و حریم خصوصی اپ را می‌پذیرید.',
                    style: TextStyle(fontSize: 14, height: 1.9),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LegalPage()),
                ),
                child: const Text('مطالعه‌ی کامل متن حقوقی'),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onAccept,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('متوجه شدم و می‌پذیرم'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
