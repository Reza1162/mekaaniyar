import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Vehicle {
  final String id;
  final String nickname; // e.g. "پژو ۲۰۶ من"
  final String modelKey; // matches a key in service_schedules.json, or 'custom'
  final int year;
  final int currentKm;

  Vehicle({
    required this.id,
    required this.nickname,
    required this.modelKey,
    required this.year,
    required this.currentKm,
  });

  Vehicle copyWith({String? nickname, int? year, int? currentKm}) => Vehicle(
        id: id,
        nickname: nickname ?? this.nickname,
        modelKey: modelKey,
        year: year ?? this.year,
        currentKm: currentKm ?? this.currentKm,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'modelKey': modelKey,
        'year': year,
        'currentKm': currentKm,
      };

  factory Vehicle.fromJson(Map<String, dynamic> j) => Vehicle(
        id: j['id'],
        nickname: j['nickname'],
        modelKey: j['modelKey'],
        year: j['year'],
        currentKm: j['currentKm'],
      );
}

class GarageRepository {
  static const _vehiclesKey = 'garage_vehicles_v1';
  static const _activeKey = 'garage_active_vehicle_v1';

  static Future<List<Vehicle>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_vehiclesKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => Vehicle.fromJson(e)).toList();
  }

  static Future<void> _saveAll(List<Vehicle> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _vehiclesKey, jsonEncode(vehicles.map((v) => v.toJson()).toList()));
  }

  static Future<Vehicle> add(Vehicle vehicle) async {
    final list = await getAll();
    list.add(vehicle);
    await _saveAll(list);
    final activeId = await getActiveVehicleId();
    if (activeId == null) await setActiveVehicleId(vehicle.id);
    return vehicle;
  }

  static Future<void> update(Vehicle vehicle) async {
    final list = await getAll();
    final idx = list.indexWhere((v) => v.id == vehicle.id);
    if (idx != -1) {
      list[idx] = vehicle;
      await _saveAll(list);
    }
  }

  static Future<void> remove(String id) async {
    final list = await getAll();
    list.removeWhere((v) => v.id == id);
    await _saveAll(list);
    final activeId = await getActiveVehicleId();
    if (activeId == id) {
      await setActiveVehicleId(list.isEmpty ? null : list.first.id);
    }
  }

  static Future<String?> getActiveVehicleId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeKey);
  }

  static Future<void> setActiveVehicleId(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove(_activeKey);
    } else {
      await prefs.setString(_activeKey, id);
    }
  }

  static Future<Vehicle?> getActiveVehicle() async {
    final id = await getActiveVehicleId();
    if (id == null) return null;
    final list = await getAll();
    try {
      return list.firstWhere((v) => v.id == id);
    } catch (_) {
      return null;
    }
  }
}
