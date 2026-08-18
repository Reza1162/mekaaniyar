import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Obd2Session {
  final String id;
  final String? vehicleId; // null if no vehicle was selected in garage
  final DateTime timestamp;
  final Map<String, double?> lastReadings; // pid code -> value
  final List<String> dtcCodes;

  Obd2Session({
    required this.id,
    required this.vehicleId,
    required this.timestamp,
    required this.lastReadings,
    required this.dtcCodes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicleId': vehicleId,
        'timestamp': timestamp.toIso8601String(),
        'lastReadings': lastReadings.map((k, v) => MapEntry(k, v)),
        'dtcCodes': dtcCodes,
      };

  factory Obd2Session.fromJson(Map<String, dynamic> j) => Obd2Session(
        id: j['id'],
        vehicleId: j['vehicleId'],
        timestamp: DateTime.parse(j['timestamp']),
        lastReadings: Map<String, double?>.from(j['lastReadings']),
        dtcCodes: List<String>.from(j['dtcCodes']),
      );
}

class Obd2LogRepository {
  static const _key = 'obd2_sessions_v1';
  static const _maxSessions = 50; // cap so local storage doesn't grow unbounded

  static Future<List<Obd2Session>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Obd2Session.fromJson(e)).toList();
  }

  static Future<void> save(Obd2Session session) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.insert(0, session);
    if (list.length > _maxSessions) {
      list.removeRange(_maxSessions, list.length);
    }
    await prefs.setString(_key, jsonEncode(list.map((s) => s.toJson()).toList()));
  }

  static Future<List<Obd2Session>> forVehicle(String vehicleId) async {
    final all = await getAll();
    return all.where((s) => s.vehicleId == vehicleId).toList();
  }

  static Future<Obd2Session?> latestForVehicle(String vehicleId) async {
    final sessions = await forVehicle(vehicleId);
    return sessions.isEmpty ? null : sessions.first;
  }

  static Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.removeWhere((s) => s.id == id);
    await prefs.setString(_key, jsonEncode(list.map((s) => s.toJson()).toList()));
  }
}
