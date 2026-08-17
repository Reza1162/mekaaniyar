import 'package:flutter/material.dart';
import '../../data/garage/garage_repository.dart';
import 'vehicle_form_page.dart';
import 'vehicle_detail_page.dart';

class GaragePage extends StatefulWidget {
  const GaragePage({super.key});

  @override
  State<GaragePage> createState() => _GaragePageState();
}

class _GaragePageState extends State<GaragePage> {
  List<Vehicle> _vehicles = [];
  String? _activeId;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vehicles = await GarageRepository.getAll();
    final activeId = await GarageRepository.getActiveVehicleId();
    if (!mounted) return;
    setState(() {
      _vehicles = vehicles;
      _activeId = activeId;
      _loading = false;
    });
  }

  Future<void> _addVehicle() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const VehicleFormPage()),
    );
    if (added == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _vehicles.isEmpty
              ? _buildEmpty()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _vehicles.length,
                  itemBuilder: (_, i) {
                    final v = _vehicles[i];
                    final isActive = v.id == _activeId;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: isActive
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey.shade300,
                          child: Icon(Icons.directions_car,
                              color: isActive ? Colors.white : Colors.grey.shade600),
                        ),
                        title: Text(v.nickname, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${v.year} · ${v.currentKm} کیلومتر'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () async {
                          await GarageRepository.setActiveVehicleId(v.id);
                          if (!mounted) return;
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => VehicleDetailPage(vehicle: v)),
                          );
                          _load();
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addVehicle,
        icon: const Icon(Icons.add),
        label: const Text('افزودن خودرو'),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.garage_outlined, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          const Text('هنوز خودرویی اضافه نکردی'),
          const SizedBox(height: 4),
          const Text('با افزودن خودرو، یادآوری سرویس‌های دوره‌ای رو فعال کن',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _addVehicle,
            icon: const Icon(Icons.add),
            label: const Text('افزودن خودرو'),
          ),
        ],
      ),
    );
  }
}
