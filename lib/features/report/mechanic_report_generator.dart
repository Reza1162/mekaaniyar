import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:arabic_reshaper/arabic_reshaper.dart';
import '../garage/garage_repository.dart';
import '../garage/service_log_repository.dart';
import '../obd2/obd2_log_repository.dart';
import '../obd2/obd2_pids.dart';
import '../obd2/dtc_decoder.dart';

/// Builds a "report for the mechanic" PDF combining what's already
/// tracked in the app: vehicle info, service due-status, and the most
/// recent saved OBD2 session (readings + trouble codes).
///
/// Known limitation: the `pdf` package does not do Arabic/Persian glyph
/// shaping or full bidi reordering on its own. We reshape each line with
/// `arabic_reshaper` and reverse it for RTL display, which reads
/// correctly for plain Persian sentences but can misorder lines that mix
/// Persian with embedded Latin text/numbers. Good enough for a first
/// version; flagged here for future improvement.
class MechanicReportGenerator {
  static pw.Font? _font;
  static pw.Font? _fontBold;

  static Future<void> _loadFonts() async {
    if (_font != null) return;
    final regular = await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf');
    final bold = await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf');
    _font = pw.Font.ttf(regular);
    _fontBold = pw.Font.ttf(bold);
  }

  static String _shape(String text) {
    return ArabicReshaper().reshape(text).split('').reversed.join('');
  }

  static Future<File> generate(String vehicleId) async {
    await _loadFonts();

    final vehicles = await GarageRepository.getAll();
    final vehicle = vehicles.firstWhere((v) => v.id == vehicleId);
    final statuses = await ServiceLogRepository.statusFor(
        vehicle.id, vehicle.modelKey, vehicle.currentKm);
    final obd2Session = await Obd2LogRepository.latestForVehicle(vehicle.id);

    final doc = pw.Document();
    final theme = pw.ThemeData.withFont(base: _font!, bold: _fontBold!);

    doc.addPage(
      pw.MultiPage(
        theme: theme,
        textDirection: pw.TextDirection.rtl,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(_shape('گزارش خودرو — مکانیار'), style: const pw.TextStyle(fontSize: 20)),
          ),
          pw.SizedBox(height: 12),
          _sectionTitle('اطلاعات خودرو'),
          _kv('نام', vehicle.nickname),
          _kv('سال', vehicle.year.toString()),
          _kv('کیلومتر فعلی', '${vehicle.currentKm} km'),
          _kv('تاریخ گزارش', DateTime.now().toIso8601String().substring(0, 10)),
          pw.SizedBox(height: 16),
          _sectionTitle('وضعیت سرویس‌های دوره‌ای'),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(children: [
                _cell(_shape('آیتم'), isHeader: true),
                _cell(_shape('وضعیت'), isHeader: true),
              ]),
              ...statuses.map((s) => pw.TableRow(children: [
                    _cell(_shape(s.item.title)),
                    _cell(_shape(s.isOverdue
                        ? 'موعد گذشته'
                        : s.isDueSoon
                            ? 'به‌زودی (${s.kmRemaining} km مانده)'
                            : 'مناسب (${s.kmRemaining} km مانده)')),
                  ])),
            ],
          ),
          pw.SizedBox(height: 16),
          _sectionTitle('آخرین داده‌ی OBD2'),
          if (obd2Session == null)
            pw.Text(_shape('داده‌ای ذخیره نشده است.'), textDirection: pw.TextDirection.rtl)
          else ...[
            _kv('تاریخ خواندن', obd2Session.timestamp.toIso8601String().substring(0, 16).replaceFirst('T', ' ')),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              children: [
                pw.TableRow(children: [
                  _cell(_shape('پارامتر'), isHeader: true),
                  _cell(_shape('مقدار'), isHeader: true),
                ]),
                ...Obd2Pids.dashboardPids.where((p) => obd2Session.lastReadings[p.code] != null).map(
                      (p) => pw.TableRow(children: [
                        _cell(_shape(p.name)),
                        _cell('${obd2Session.lastReadings[p.code]!.toStringAsFixed(1)} ${p.unit}'),
                      ]),
                    ),
              ],
            ),
            pw.SizedBox(height: 10),
            if (obd2Session.dtcCodes.isEmpty)
              pw.Text(_shape('کد خطایی ثبت نشده.'), textDirection: pw.TextDirection.rtl)
            else ...[
              pw.Text(_shape('کدهای خطا:'), textDirection: pw.TextDirection.rtl),
              ...obd2Session.dtcCodes.map((c) => pw.Text(
                    '$c — ${_shape(DtcDecoder.describe(c))}',
                    textDirection: pw.TextDirection.rtl,
                  )),
            ],
          ],
          pw.SizedBox(height: 24),
          pw.Text(
            _shape('این گزارش توسط اپلیکیشن مکانیار تولید شده و صرفاً جنبه‌ی اطلاع‌رسانی دارد.'),
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/mekaaniyar_report_${vehicle.id}.pdf');
    await file.writeAsBytes(await doc.save());
    return file;
  }

  static pw.Widget _sectionTitle(String text) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 6),
        child: pw.Text(_shape(text), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      );

  static pw.Widget _kv(String k, String v) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 2),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(_shape(k), textDirection: pw.TextDirection.rtl),
            pw.Text(v, textDirection: pw.TextDirection.rtl),
          ],
        ),
      );

  static pw.Widget _cell(String text, {bool isHeader = false}) => pw.Padding(
        padding: const pw.EdgeInsets.all(6),
        child: pw.Text(
          text,
          textDirection: pw.TextDirection.rtl,
          style: pw.TextStyle(fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal, fontSize: 10),
        ),
      );
}
