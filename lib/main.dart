import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_page.dart';
import 'features/legal/disclaimer_gate.dart';
import 'features/onboarding/onboarding_gate.dart';

void main() {
  runApp(const MekaaniyarApp());
}

class MekaaniyarApp extends StatelessWidget {
  const MekaaniyarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مکانیار',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fa', 'IR'),
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const OnboardingGate(child: DisclaimerGate(child: HomePage())),
    );
  }
}
