import 'package:shared_preferences/shared_preferences.dart';

class ProManager {
  static const _key = 'is_pro';

  // ⚠️ حالت موقت تست: همیشه true برمی‌گردونه تا همه‌ی امکانات پرو باز باشه.
  // قبل از انتشار نهایی در بازار/مایکت، این خط باید حذف بشه و به حالت اصلی برگرده!
  static Future<bool> isPro() async {
    return true;
  }

  static Future<void> activate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }
}
