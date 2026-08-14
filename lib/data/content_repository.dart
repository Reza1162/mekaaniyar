import 'dart:convert';
import 'package:flutter/services.dart';

class Chapter {
  final String id;
  final String title;
  final String icon;
  final String color;
  final String description;
  final bool isPro;
  final List<Section> sections;

  Chapter({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.isPro,
    required this.sections,
  });

  factory Chapter.fromJson(Map<String, dynamic> j) => Chapter(
        id: j['id'],
        title: j['title'],
        icon: j['icon'],
        color: j['color'],
        description: j['description'],
        isPro: j['isPro'] ?? false,
        sections: (j['sections'] as List).map((s) => Section.fromJson(s)).toList(),
      );
}

class Section {
  final String id;
  final String title;
  final String content;

  Section({required this.id, required this.title, required this.content});

  factory Section.fromJson(Map<String, dynamic> j) => Section(
        id: j['id'],
        title: j['title'],
        content: j['content'],
      );
}

class ContentRepository {
  static List<Chapter>? _chapters;

  static Future<List<Chapter>> loadChapters() async {
    if (_chapters != null) return _chapters!;
    final raw = await rootBundle.loadString('assets/content/chapters.json');
    final data = jsonDecode(raw);
    _chapters = (data['chapters'] as List).map((c) => Chapter.fromJson(c)).toList();
    return _chapters!;
  }

  static List<Chapter> get chapters => _chapters ?? [];

  static List<Map<String, String>> buildSearchIndex() {
    final index = <Map<String, String>>[];
    for (final ch in chapters) {
      for (final sec in ch.sections) {
        index.add({
          'chapterId': ch.id,
          'chapterTitle': ch.title,
          'sectionId': sec.id,
          'sectionTitle': sec.title,
          'content': sec.content,
        });
      }
    }
    return index;
  }
}
