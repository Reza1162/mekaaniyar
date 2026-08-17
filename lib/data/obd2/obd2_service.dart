import 'dart:async';
import 'dart:convert';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'obd2_pids.dart';
import 'dtc_decoder.dart';

enum Obd2Status { disconnected, connecting, initializing, ready, error }

/// Talks to a classic-Bluetooth ELM327 OBD2 dongle using standard AT
/// commands and Mode 01 (live data) / Mode 03 (stored codes) / Mode 04
/// (clear codes) requests, per the SAE J1979 standard used by all
/// consumer OBD2 scan tools.
class Obd2Service {
  BluetoothConnection? _connection;
  final StreamController<Obd2Status> _statusController =
      StreamController.broadcast();
  Obd2Status _status = Obd2Status.disconnected;
  String _buffer = '';

  Stream<Obd2Status> get statusStream => _statusController.stream;
  Obd2Status get status => _status;

  void _setStatus(Obd2Status s) {
    _status = s;
    _statusController.add(s);
  }

  Future<List<BluetoothDevice>> getPairedDevices() async {
    return FlutterBluetoothSerial.instance.getBondedDevices();
  }

  Future<bool> connect(BluetoothDevice device) async {
    _setStatus(Obd2Status.connecting);
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _connection!.input!.listen(_onData).onDone(() {
        _setStatus(Obd2Status.disconnected);
      });
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
    await _connection?.close();
    _connection = null;
    _setStatus(Obd2Status.disconnected);
  }

  final Map<String, Completer<String>> _pending = {};
  String? _currentKey;

  void _onData(List<int> data) {
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
    if (_connection == null || !_connection!.isConnected) {
      throw Exception('اتصال برقرار نیست');
    }
    final key = DateTime.now().microsecondsSinceEpoch.toString();
    _currentKey = key;
    final completer = Completer<String>();
    _pending[key] = completer;
    _connection!.output.add(utf8.encode('$cmd\r'));
    await _connection!.output.allSent;
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

  /// Sends a Mode 01 PID request and returns decoded bytes after the
  /// two-byte echo header (mode+pid), or null if the vehicle didn't answer.
  Future<List<int>?> _queryModeBytes(String modeHex, String pidHex) async {
    final raw = await _sendRaw('$modeHex$pidHex');
    final hex = raw
        .replaceAll('\r', ' ')
        .replaceAll('\n', ' ')
        .replaceAll('>', '')
        .trim();
    if (hex.isEmpty || hex.toUpperCase().contains('NO DATA') || hex.toUpperCase().contains('ERROR')) {
      return null;
    }
    final tokens = hex.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final bytes = <int>[];
    for (final t in tokens) {
      final v = int.tryParse(t, radix: 16);
      if (v != null) bytes.add(v);
    }
    // Expected reply mode is request mode + 0x40 (e.g. 01 -> 41).
    final expectedMode = int.parse(modeHex, radix: 16) + 0x40;
    final idx = bytes.indexWhere((b) => b == expectedMode);
    if (idx == -1 || idx + 1 >= bytes.length) return null;
    return bytes.sublist(idx + 2); // skip mode + pid echo bytes
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
    final hex = raw.replaceAll('\r', ' ').replaceAll('\n', ' ').replaceAll('>', '').trim();
    if (hex.toUpperCase().contains('NO DATA')) return [];
    final tokens = hex.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final bytes = <int>[];
    for (final t in tokens) {
      final v = int.tryParse(t, radix: 16);
      if (v != null) bytes.add(v);
    }
    // Drop the leading mode-echo byte (0x43) and the count byte if present.
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
    _statusController.close();
    _connection?.close();
  }
}
