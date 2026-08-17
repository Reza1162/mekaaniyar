import 'dart:convert';
import 'package:flutter/services.dart';

class LegalDoc {
  final String title;
  final String updated;
  final String content;
  LegalDoc({required this.title, required this.updated, required this.content});
  factory LegalDoc.fromJson(Map<String, dynamic> j) => LegalDoc(
        title: j['title'],
        updated: j['updated'],
        content: j['content'],
      );
}

class LegalRepository {
  static LegalDoc? _terms;
  static LegalDoc? _privacy;

  static Future<void> _ensureLoaded() async {
    if (_terms != null && _privacy != null) return;
    final raw = await rootBundle.loadString('assets/content/legal.json');
    final data = jsonDecode(raw);
    _terms = LegalDoc.fromJson(data['terms']);
    _privacy = LegalDoc.fromJson(data['privacy']);
  }

  static Future<LegalDoc> loadTerms() async {
    await _ensureLoaded();
    return _terms!;
  }

  static Future<LegalDoc> loadPrivacy() async {
    await _ensureLoaded();
    return _privacy!;
  }
}
