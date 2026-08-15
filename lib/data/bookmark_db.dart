import 'package:shared_preferences/shared_preferences.dart';

class BookmarkDB {
  static const _key = 'bookmarks';

  static Future<List<String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  static Future<void> toggle(String sectionId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (list.contains(sectionId)) {
      list.remove(sectionId);
    } else {
      list.add(sectionId);
    }
    await prefs.setStringList(_key, list);
  }

  static Future<bool> isBookmarked(String sectionId) async {
    final list = await getAll();
    return list.contains(sectionId);
  }
}
