import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class UnitConverter extends StatefulWidget {
  const UnitConverter({super.key});
  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  int _category = 0;
  final _inputCtrl = TextEditingController();
  int _fromUnit = 0;
  int _toUnit = 1;
  String _result = '';

  final _categories = [
    {
      'name': 'فشار',
      'units': ['بار (bar)', 'PSI', 'kPa', 'atm'],
      'toBase': [1.0, 0.0689476, 0.01, 1.01325],
      'fromBase': [1.0, 14.5038, 100.0, 0.986923],
    },
    {
      'name': 'دما',
      'units': ['سلسیوس (°C)', 'فارنهایت (°F)', 'کلوین (K)'],
      'toBase': null,
      'fromBase': null,
    },
    {
      'name': 'توان',
      'units': ['اسب بخار (HP)', 'کیلووات (kW)', 'واط (W)'],
      'toBase': [1.0, 1.341, 0.001341],
      'fromBase': [1.0, 0.7457, 745.7],
    },
    {
      'name': 'گشتاور',
      'units': ['نیوتون‌متر (N.m)', 'کیلوگرم‌متر (kgf.m)', 'پوند‌فوت (lb.ft)'],
      'toBase': [1.0, 9.80665, 1.35582],
      'fromBase': [1.0, 0.10197, 0.73756],
    },
  ];

  void _convert() {
    final val = double.tryParse(_inputCtrl.text);
    if (val == null) return;
    final cat = _categories[_category];

    double result;
    if (_category == 1) {
      // دما — تبدیل خاص
      double celsius;
      if (_fromUnit == 0) celsius = val;
      else if (_fromUnit == 1) celsius = (val - 32) * 5 / 9;
      else celsius = val - 273.15;

      if (_toUnit == 0) result = celsius;
      else if (_toUnit == 1) result = celsius * 9 / 5 + 32;
      else result = celsius + 273.15;
    } else {
      final toBase = (cat['toBase'] as List)[_fromUnit] as double;
      final fromBase = (cat['fromBase'] as List)[_toUnit] as double;
      result = val * toBase * fromBase;
    }

    setState(() => _result = result.toStringAsFixed(4));
  }

  @override
  Widget build(BuildContext context) {
    final cat = _categories[_category];
    final units = cat['units'] as List<String>;

    return Scaffold(
      appBar: AppBar(title: const Text('تبدیل واحد')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('دسته:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(_categories.length, (i) {
              return ChoiceChip(
                label: Text(_categories[i]['name'] as String),
                selected: _category == i,
                onSelected: (_) => setState(() {
                  _category = i;
                  _fromUnit = 0;
                  _toUnit = 1;
                  _result = '';
                }),
                selectedColor: AppTheme.primary,
                labelStyle: TextStyle(color: _category == i ? Colors.white : null),
              );
            }),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _inputCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'مقدار',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _fromUnit,
                  decoration: const InputDecoration(
                    labelText: 'از',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(units.length, (i) =>
                    DropdownMenuItem(value: i, child: Text(units[i], overflow: TextOverflow.ellipsis))),
                  onChanged: (v) => setState(() => _fromUnit = v!),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_back, color: AppTheme.primary),
              ),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: _toUnit,
                  decoration: const InputDecoration(
                    labelText: 'به',
                    border: OutlineInputBorder(),
                  ),
                  items: List.generate(units.length, (i) =>
                    DropdownMenuItem(value: i, child: Text(units[i], overflow: TextOverflow.ellipsis))),
                  onChanged: (v) => setState(() => _toUnit = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: _convert, child: const Text('تبدیل')),
          ),
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('نتیجه', style: TextStyle(color: AppTheme.primary)),
                  const SizedBox(height: 8),
                  Text(_result,
                      style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary)),
                  Text(units[_toUnit],
                      style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
