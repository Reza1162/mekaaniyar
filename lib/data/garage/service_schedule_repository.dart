import 'dart:convert';
import 'package:flutter/services.dart';

class ServiceTemplateItem {
  final String title;
  final int intervalKm;
  final int intervalMonths;
  ServiceTemplateItem({
    required this.title,
    required this.intervalKm,
    required this.intervalMonths,
  });
  factory ServiceTemplateItem.fromJson(Map<String, dynamic> j) =>
      ServiceTemplateItem(
        title: j['title'],
        intervalKm: j['intervalKm'],
        intervalMonths: j['intervalMonths'],
      );
}

class ServiceModelTemplate {
  final String key;
  final String title;
  final List<ServiceTemplateItem> items;
  ServiceModelTemplate({required this.key, required this.title, required this.items});
  factory ServiceModelTemplate.fromJson(Map<String, dynamic> j) =>
      ServiceModelTemplate(
        key: j['key'],
        title: j['title'],
        items: (j['items'] as List)
            .map((e) => ServiceTemplateItem.fromJson(e))
            .toList(),
      );
}

class ServiceScheduleRepository {
  static List<ServiceModelTemplate>? _models;

  static Future<List<ServiceModelTemplate>> loadModels() async {
    if (_models != null) return _models!;
    final raw = await rootBundle.loadString('assets/content/service_schedules.json');
    final data = jsonDecode(raw);
    _models = (data['models'] as List)
        .map((e) => ServiceModelTemplate.fromJson(e))
        .toList();
    return _models!;
  }

  static Future<ServiceModelTemplate> forModelKey(String key) async {
    final models = await loadModels();
    return models.firstWhere((m) => m.key == key, orElse: () => models.last);
  }
}
