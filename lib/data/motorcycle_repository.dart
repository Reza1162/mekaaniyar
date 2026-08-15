import 'dart:convert';
import 'package:flutter/services.dart';

class MotoSection {
  final String id;
  final String title;
  final String content;
  MotoSection({required this.id, required this.title, required this.content});
  factory MotoSection.fromJson(Map<String, dynamic> j) =>
      MotoSection(id: j['id'], title: j['title'], content: j['content']);
}

class MotoChapter {
  final String id;
  final String title;
  final String color;
  final List<MotoSection> sections;
  MotoChapter({required this.id, required this.title, required this.color, required this.sections});
  factory MotoChapter.fromJson(Map<String, dynamic> j) => MotoChapter(
        id: j['id'],
        title: j['title'],
        color: j['color'],
        sections: (j['sections'] as List).map((s) => MotoSection.fromJson(s)).toList());
}

class MotorcycleRepository {
  static List<MotoChapter>? _chapters;

  static Future<List<MotoChapter>> load() async {
    if (_chapters != null) return _chapters!;
    final raw = await rootBundle.loadString('assets/content/motorcycle.json');
    final data = jsonDecode(raw);
    _chapters = (data['chapters'] as List).map((c) => MotoChapter.fromJson(c)).toList();
    return _chapters!;
  }
}
