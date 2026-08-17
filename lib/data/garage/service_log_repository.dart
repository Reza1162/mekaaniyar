import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'service_schedule_repository.dart';

class ServiceRecord {
  final String itemTitle;
  final int lastDoneKm;
  final DateTime lastDoneDate;
  ServiceRecord({
    required this.itemTitle,
    required this.lastDoneKm,
    required this.lastDoneDate,
  });

  Map<String, dynamic> toJson() => {
        'itemTitle': itemTitle,
        'lastDoneKm': lastDoneKm,
        'lastDoneDate': lastDoneDate.toIso8601String(),
      };

  factory ServiceRecord.fromJson(Map<String, dynamic> j) => ServiceRecord(
        itemTitle: j['itemTitle'],
        lastDoneKm: j['lastDoneKm'],
        lastDoneDate: DateTime.parse(j['lastDoneDate']),
      );
}

class ServiceStatus {
  final ServiceTemplateItem item;
  final ServiceRecord? record;
  final int currentKm;
  ServiceStatus({required this.item, required this.record, required this.currentKm});

  /// Km remaining until due (negative means overdue).
  int get kmRemaining {
    if (record == null) return 0; // never logged -> treat as due now
    return (record!.lastDoneKm + item.intervalKm) - currentKm;
  }

  DateTime? get dueDate {
    if (record == null) return null;
    return DateTime(
      record!.lastDoneDate.year,
      record!.lastDoneDate.month + item.intervalMonths,
      record!.lastDoneDate.day,
    );
  }

  bool get isOverdue {
    if (record == null) return true;
    final kmOver = kmRemaining <= 0;
    final dateOver = dueDate != null && DateTime.now().isAfter(dueDate!);
    return kmOver || dateOver;
  }

  bool get isDueSoon {
    if (isOverdue) return false;
    return kmRemaining <= 1000; // within 1000 km of due
  }
}

class ServiceLogRepository {
  static String _key(String vehicleId) => 'service_log_$vehicleId';

  static Future<Map<String, ServiceRecord>> _load(String vehicleId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(vehicleId));
    if (raw == null) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, ServiceRecord.fromJson(v)));
  }

  static Future<void> _save(String vehicleId, Map<String, ServiceRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(vehicleId),
      jsonEncode(records.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }

  static Future<void> markDone(
      String vehicleId, String itemTitle, int km, DateTime date) async {
    final records = await _load(vehicleId);
    records[itemTitle] = ServiceRecord(itemTitle: itemTitle, lastDoneKm: km, lastDoneDate: date);
    await _save(vehicleId, records);
  }

  static Future<List<ServiceStatus>> statusFor(
      String vehicleId, String modelKey, int currentKm) async {
    final template = await ServiceScheduleRepository.forModelKey(modelKey);
    final records = await _load(vehicleId);
    return template.items
        .map((item) => ServiceStatus(
              item: item,
              record: records[item.title],
              currentKm: currentKm,
            ))
        .toList();
  }
}
