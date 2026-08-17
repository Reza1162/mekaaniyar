/// Standard OBD2 (SAE J1979) Mode 01 PID definitions and value decoders.
/// These are publicly standardized parameter IDs used by virtually every
/// OBD2 scan tool; no vehicle-specific or proprietary data is involved.
class ObdPid {
  final String code; // hex PID, e.g. "0C"
  final String name;
  final String unit;
  final double Function(List<int> bytes) decode;

  const ObdPid({
    required this.code,
    required this.name,
    required this.unit,
    required this.decode,
  });
}

class Obd2Pids {
  static final rpm = ObdPid(
    code: '0C',
    name: 'دور موتور',
    unit: 'RPM',
    decode: (b) => ((b[0] * 256) + b[1]) / 4,
  );

  static final speed = ObdPid(
    code: '0D',
    name: 'سرعت',
    unit: 'km/h',
    decode: (b) => b[0].toDouble(),
  );

  static final coolantTemp = ObdPid(
    code: '05',
    name: 'دمای آب موتور',
    unit: '°C',
    decode: (b) => b[0] - 40,
  );

  static final intakeTemp = ObdPid(
    code: '0F',
    name: 'دمای هوای ورودی',
    unit: '°C',
    decode: (b) => b[0] - 40,
  );

  static final throttlePos = ObdPid(
    code: '11',
    name: 'موقعیت دریچه گاز',
    unit: '%',
    decode: (b) => b[0] * 100 / 255,
  );

  static final engineLoad = ObdPid(
    code: '04',
    name: 'بار موتور',
    unit: '%',
    decode: (b) => b[0] * 100 / 255,
  );

  static final fuelLevel = ObdPid(
    code: '2F',
    name: 'سطح سوخت',
    unit: '%',
    decode: (b) => b[0] * 100 / 255,
  );

  static final maf = ObdPid(
    code: '10',
    name: 'جریان هوای ورودی (MAF)',
    unit: 'g/s',
    decode: (b) => ((b[0] * 256) + b[1]) / 100,
  );

  static final batteryVoltage = ObdPid(
    code: '42',
    name: 'ولتاژ باتری (ماژول)',
    unit: 'V',
    decode: (b) => ((b[0] * 256) + b[1]) / 1000,
  );

  /// PIDs shown on the live dashboard, in display order.
  static final List<ObdPid> dashboardPids = [
    rpm,
    speed,
    coolantTemp,
    engineLoad,
    throttlePos,
    intakeTemp,
    maf,
    fuelLevel,
    batteryVoltage,
  ];
}
