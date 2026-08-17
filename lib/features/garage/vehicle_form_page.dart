import 'package:flutter/material.dart';
import '../../data/garage/garage_repository.dart';
import '../../data/garage/service_schedule_repository.dart';

class VehicleFormPage extends StatefulWidget {
  final Vehicle? existing;
  const VehicleFormPage({super.key, this.existing});

  @override
  State<VehicleFormPage> createState() => _VehicleFormPageState();
}

class _VehicleFormPageState extends State<VehicleFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _kmCtrl = TextEditingController();
  List<ServiceModelTemplate> _models = [];
  String? _selectedModelKey;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadModels();
    final e = widget.existing;
    if (e != null) {
      _nicknameCtrl.text = e.nickname;
      _yearCtrl.text = e.year.toString();
      _kmCtrl.text = e.currentKm.toString();
      _selectedModelKey = e.modelKey;
    }
  }

  Future<void> _loadModels() async {
    final models = await ServiceScheduleRepository.loadModels();
    if (!mounted) return;
    setState(() {
      _models = models;
      _selectedModelKey ??= models.first.key;
      _loading = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final vehicle = Vehicle(
      id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      nickname: _nicknameCtrl.text.trim(),
      modelKey: _selectedModelKey!,
      year: int.parse(_yearCtrl.text),
      currentKm: int.parse(_kmCtrl.text),
    );
    if (widget.existing == null) {
      await GarageRepository.add(vehicle);
    } else {
      await GarageRepository.update(vehicle);
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _yearCtrl.dispose();
    _kmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.existing == null ? 'افزودن خودرو' : 'ویرایش خودرو')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nicknameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'اسم دلخواه',
                      hintText: 'مثلاً: پژو ۲۰۶ من',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'اجباری است' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedModelKey,
                    decoration: const InputDecoration(
                      labelText: 'مدل خودرو',
                      border: OutlineInputBorder(),
                    ),
                    items: _models
                        .map((m) => DropdownMenuItem(value: m.key, child: Text(m.title)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedModelKey = v),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _yearCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'سال ساخت',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (int.tryParse(v ?? '') == null) ? 'یک عدد معتبر وارد کن' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _kmCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'کیلومتر فعلی',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (int.tryParse(v ?? '') == null) ? 'یک عدد معتبر وارد کن' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('ذخیره'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
