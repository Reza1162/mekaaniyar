import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'obd2_pids.dart';
import 'dtc_decoder.dart';

enum Obd2Status { disconnected, connecting, initializing, ready, error }

/// Standard Serial Port Profile UUID used by virtually every ELM327
/// Bluetooth Classic OBD2 dongle.
const _sppUuid = '00001101-0000-1000-8000-00805f9b34fb';

/// Talks to a classic-Bluetooth ELM327 OBD2 dongle using standard AT
/// commands and Mode 01 (live data) / Mode 02 (freeze frame) /
/// Mode 03 (stored codes) / Mode 04 (clear codes) requests, per the
/// SAE J1979 standard used by all consumer OBD2 scan tools.
class Obd2Service {
  final _plugin = BluetoothClassic();
  StreamSubscription? _dataSub;
  final StreamController<Obd2Status> _statusController = StreamController.broadcast();
  Obd2Status _status = Obd2Status.disconnected;
  String _buffer = '';
  bool _connected = false;

  Stream<Obd2Status> get statusStream => _statusController.stream;
  Obd2Status get status => _status;

  void _setStatus(Obd2Status s) {
    _status = s;
    _statusController.add(s);
  }

  Future<void> initPermissions() => _plugin.initPermissions();

  Future<List<Device>> getPairedDevices() => _plugin.getPairedDevices();

  Future<bool> connect(Device device) async {
    _setStatus(Obd2Status.connecting);
    try {
      await _plugin.connect(device.address, _sppUuid);
      _connected = true;
      _dataSub = _plugin.onDeviceDataReceived().listen(_onData);
      _setStatus(Obd2Status.initializing);
      final ok = await _initElm327();
      _setStatus(ok ? Obd2Status.ready : Obd2Status.error);
      return ok;
    } catch (_) {
      _setStatus(Obd2Status.error);
      return false;
    }
  }

  Future<void> disconnect() async {
    await _dataSub?.cancel();
    if (_connected) {
      await _plugin.disconnect();
      _connected = false;
    }
    _setStatus(Obd2Status.disconnected);
  }

  final Map<String, Completer<String>> _pending = {};
  String? _currentKey;

  void _onData(Uint8List data) {
    _buffer += utf8.decode(data, allowMalformed: true);
    if (_buffer.contains('>')) {
      final response = _buffer;
      _buffer = '';
      if (_currentKey != null && _pending.containsKey(_currentKey)) {
        _pending.remove(_currentKey)!.complete(response);
      }
    }
  }

  /// Sends a raw AT/OBD command and waits for the '>' prompt terminator.
  Future<String> _sendRaw(String cmd, {Duration timeout = const Duration(seconds: 4)}) async {
    if (!_connected) {
      throw Exception('اتصال برقرار نیست');
    }
    final key = DateTime.now().microsecondsSinceEpoch.toString();
    _currentKey = key;
    final completer = Completer<String>();
    _pending[key] = completer;
    await _plugin.write('$cmd\r');
    try {
      return await completer.future.timeout(timeout);
    } on TimeoutException {
      _pending.remove(key);
      return '';
    }
  }

  Future<bool> _initElm327() async {
    try {
      await _sendRaw('ATZ'); // reset
      await Future.delayed(const Duration(milliseconds: 500));
      await _sendRaw('ATE0'); // echo off
      await _sendRaw('ATL0'); // linefeeds off
      await _sendRaw('ATH0'); // headers off
      final resp = await _sendRaw('ATSP0'); // auto-detect protocol
      return true && resp != '';
    } catch (_) {
      return false;
    }
  }

  List<int> _parseHexBytes(String raw) {
    final hex = raw.replaceAll('\r', ' ').replaceAll('\n', ' ').replaceAll('>', '').trim();
    final tokens = hex.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final bytes = <int>[];
    for (final t in tokens) {
      final v = int.tryParse(t, radix: 16);
      if (v != null) bytes.add(v);
    }
    return bytes;
  }

  /// Sends a Mode 01 PID request and returns decoded bytes after the
  /// two-byte echo header (mode+pid), or null if the vehicle didn't answer.
  Future<List<int>?> _queryModeBytes(String modeHex, String pidHex) async {
    final raw = await _sendRaw('$modeHex$pidHex');
    if (raw.isEmpty ||
        raw.toUpperCase().contains('NO DATA') ||
        raw.toUpperCase().contains('ERROR')) {
      return null;
    }
    final bytes = _parseHexBytes(raw);
    final expectedMode = int.parse(modeHex, radix: 16) + 0x40;
    final idx = bytes.indexWhere((b) => b == expectedMode);
    if (idx == -1 || idx + 1 >= bytes.length) return null;
    return bytes.sublist(idx + 2); // skip mode + pid echo bytes
  }

  Future<double?> readFreezeFramePid(ObdPid pid) async {
    final raw = await _sendRaw('02${pid.code}00');
    if (raw.isEmpty || raw.toUpperCase().contains('NO DATA')) return null;
    final bytes = _parseHexBytes(raw);
    final idx = bytes.indexWhere((b) => b == 0x42);
    if (idx == -1 || idx + 2 >= bytes.length) return null;
    final dataBytes = bytes.sublist(idx + 3); // skip mode+pid+frame# echo
    try {
      return pid.decode(dataBytes);
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, double?>> readFreezeFrame() async {
    final pids = [Obd2Pids.rpm, Obd2Pids.speed, Obd2Pids.coolantTemp, Obd2Pids.engineLoad];
    final result = <String, double?>{};
    for (final p in pids) {
      result[p.code] = await readFreezeFramePid(p);
    }
    return result;
  }

  Future<double?> readPid(ObdPid pid) async {
    final bytes = await _queryModeBytes('01', pid.code);
    if (bytes == null || bytes.isEmpty) return null;
    try {
      return pid.decode(bytes);
    } catch (_) {
      return null;
    }
  }

  /// Reads a batch of PIDs sequentially (ELM327 dongles are single-channel
  /// and can't handle concurrent requests).
  Future<Map<String, double?>> readAll(List<ObdPid> pids) async {
    final result = <String, double?>{};
    for (final p in pids) {
      result[p.code] = await readPid(p);
    }
    return result;
  }

  /// Reads stored trouble codes (Mode 03).
  Future<List<String>> readDtcs() async {
    final raw = await _sendRaw('03');
    if (raw.toUpperCase().contains('NO DATA')) return [];
    final bytes = _parseHexBytes(raw);
    final startIdx = bytes.indexWhere((b) => b == 0x43);
    final dataBytes = startIdx == -1 ? bytes : bytes.sublist(startIdx + 1);
    return DtcDecoder.parseResponse(dataBytes);
  }

  /// Clears stored trouble codes (Mode 04). Caller must confirm with the
  /// user first since this also resets readiness monitors.
  Future<bool> clearDtcs() async {
    final raw = await _sendRaw('04');
    return !raw.toUpperCase().contains('ERROR');
  }

  void dispose() {
    _dataSub?.cancel();
    _statusController.close();
    if (_connected) {
      _plugin.disconnect();
    }
  }
}
