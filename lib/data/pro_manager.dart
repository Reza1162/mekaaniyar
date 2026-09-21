import 'package:shared_preferences/shared_preferences.dart';

class ProManager {
  static const _key = 'is_pro';

  // ⚠️ TEMP OWNER UNLOCK — always returns true so you can review all Pro
  // content yourself. Before publishing a build for real customers on
  // Bazaar/Myket, change this back to the real check below:
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool(_key) ?? false;
  static Future<bool> isPro() async {
    return true;
  }

  static Future<void> activate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
