import 'dart:convert';
import 'package:flutter/services.dart';

class DiagResult {
  final String title;
  final String severity;
  final String description;
  final List<String> actions;

  DiagResult({
    required this.title,
    required this.severity,
    required this.description,
    required this.actions,
  });

  factory DiagResult.fromJson(Map<String, dynamic> j) => DiagResult(
        title: j['title'],
        severity: j['severity'],
        description: j['description'],
        actions: List<String>.from(j['actions']),
      );
}

class DiagNode {
  final String? question;
  final List<DiagOption>? options;
  final DiagResult? result;

  DiagNode({this.question, this.options, this.result});

  factory DiagNode.fromJson(Map<String, dynamic> j) {
    if (j.containsKey('result')) {
      return DiagNode(result: DiagResult.fromJson(j['result']));
    }
    return DiagNode(
      question: j['question'],
      options: (j['options'] as List).map((o) => DiagOption.fromJson(o)).toList(),
    );
  }
}

class DiagOption {
  final String text;
  final DiagNode? next;
  final DiagResult? result;

  DiagOption({required this.text, this.next, this.result});

  factory DiagOption.fromJson(Map<String, dynamic> j) {
    return DiagOption(
      text: j['text'],
      next: j.containsKey('next') ? DiagNode.fromJson(j['next']) : null,
      result: j.containsKey('result') ? DiagResult.fromJson(j['result']) : null,
    );
  }
}

class DiagTree {
  final String id;
  final String title;
  final String icon;
  final String question;
  final List<DiagOption> options;

  DiagTree({
    required this.id,
    required this.title,
    required this.icon,
    required this.question,
    required this.options,
  });

  factory DiagTree.fromJson(Map<String, dynamic> j) => DiagTree(
        id: j['id'],
        title: j['title'],
        icon: j['icon'],
        question: j['question'],
        options: (j['options'] as List).map((o) => DiagOption.fromJson(o)).toList(),
      );
}

class DiagnosticRepository {
  static List<DiagTree>? _trees;

  static Future<List<DiagTree>> load() async {
    if (_trees != null) return _trees!;
    final raw = await rootBundle.loadString('assets/content/diagnostic.json');
    final data = jsonDecode(raw);
    _trees = (data['trees'] as List).map((t) => DiagTree.fromJson(t)).toList();
    return _trees!;
  }

  static List<DiagTree> get trees => _trees ?? [];
}
