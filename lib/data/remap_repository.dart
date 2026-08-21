import 'dart:convert';
import 'package:flutter/services.dart';

class RemapSection {
  final String id;
  final String title;
  final String content;
  RemapSection({required this.id, required this.title, required this.content});
  factory RemapSection.fromJson(Map<String, dynamic> j) => RemapSection(
        id: j['id'], title: j['title'], content: j['content']);
}

class RemapCategory {
  final String id;
  final String title;
  final bool isPro;
  final List<RemapSection> sections;
  RemapCategory({required this.id, required this.title, required this.isPro, required this.sections});
  factory RemapCategory.fromJson(Map<String, dynamic> j) => RemapCategory(
        id: j['id'],
        title: j['title'],
        isPro: j['isPro'] ?? false,
        sections: (j['sections'] as List).map((s) => RemapSection.fromJson(s)).toList());
}

class RemapRepository {
  static List<RemapCategory>? _categories;

  static Future<List<RemapCategory>> load() async {
    if (_categories != null) return _categories!;
    final raw = await rootBundle.loadString('assets/content/remap.json');
    final data = jsonDecode(raw);
    _categories = (data['categories'] as List).map((c) => RemapCategory.fromJson(c)).toList();
    return _categories!;
  }
}
