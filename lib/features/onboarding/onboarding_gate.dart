import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingGate extends StatefulWidget {
  final Widget child;
  const OnboardingGate({super.key, required this.child});

  @override
  State<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<OnboardingGate> {
  static const _key = 'onboarding_seen_v1';
  bool? _seen;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _seen = prefs.getBool(_key) ?? false);
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    setState(() => _seen = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_seen == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_seen == false) {
      return _OnboardingScreen(onFinish: _finish);
    }
    return widget.child;
  }
}

class _Slide {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  _Slide(this.icon, this.title, this.description, this.color);
}

class _OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const _OnboardingScreen({required this.onFinish});

  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static final _slides = [
    _Slide(
      Icons.menu_book_outlined,
      'مرجع فنی کامل خودرو',
      'موتور، گیربکس، برق، ترمز و تعلیق — از مبانی ساده تا مباحث تخصصی، همه به فارسی و قابل جستجو.',
      const Color(0xFF1565C0),
    ),
    _Slide(
      Icons.garage_outlined,
      'گاراژ من',
      'خودروی خودت رو ثبت کن تا مکانیار خودش یادآوری سرویس‌های دوره‌ای (روغن، تسمه تایم، لنت) رو بهت بده.',
      const Color(0xFF2E7D32),
    ),
    _Slide(
      Icons.bluetooth_connected,
      'اتصال به کامپیوتر خودرو',
      'با یک دانگل OBD2 ارزون، مستقیم به کامپیوتر خودرو وصل شو و دور موتور، دما و کدهای خطا رو زنده ببین.',
      const Color(0xFF00897B),
    ),
    _Slide(
      Icons.quiz_outlined,
      'دانشت رو محک بزن',
      'با کویزهای هر فصل، دانش فنی‌ت رو تست کن و بهترین امتیازت رو ثبت کن.',
      const Color(0xFFEF6C00),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _slides.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: widget.onFinish,
                child: const Text('رد شدن'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final s = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: s.color.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(s.icon, size: 56, color: s.color),
                        ),
                        const SizedBox(height: 28),
                        Text(s.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(s.description,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, height: 1.8, color: Colors.grey)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page ? _slides[_page].color : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: _slides[_page].color),
                  onPressed: () {
                    if (isLast) {
                      widget.onFinish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Text(isLast ? 'شروع کن' : 'بعدی',
                        style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
