/// Decodes raw DTC bytes (from Mode 03/07) into standard code strings like
/// "P0301", and provides short Persian descriptions for the most common
/// generic (SAE-standardized) powertrain codes. This is all public,
/// standardized reference data used by every OBD2 scan tool.
class DtcInfo {
  final String code;
  final String description;
  DtcInfo(this.code, this.description);
}

class DtcDecoder {
  static const _firstCharMap = ['P', 'C', 'B', 'U'];

  /// Decodes two raw bytes into a DTC string, e.g. [0x03, 0x01] -> "P0301".
  static String decodeBytes(int highByte, int lowByte) {
    final firstTwoBits = (highByte >> 6) & 0x03;
    final digit2 = (highByte >> 4) & 0x03;
    final digit3 = highByte & 0x0F;
    final digit4 = (lowByte >> 4) & 0x0F;
    final digit5 = lowByte & 0x0F;
    final letter = _firstCharMap[firstTwoBits];
    return '$letter$digit2${digit3.toRadixString(16)}'
            '${digit4.toRadixString(16)}${digit5.toRadixString(16)}'
        .toUpperCase();
  }

  /// Parses a raw hex response body (pairs of bytes) from Mode 03 into a
  /// list of DTC strings.
  static List<String> parseResponse(List<int> bytes) {
    final codes = <String>[];
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      if (bytes[i] == 0 && bytes[i + 1] == 0) continue;
      codes.add(decodeBytes(bytes[i], bytes[i + 1]));
    }
    return codes;
  }

  /// Short Persian description for common generic (SAE-standard) codes.
  /// Manufacturer-specific codes (P1xxx and similar) are not covered here
  /// since their meaning varies by automaker.
  static String describe(String code) {
    return _descriptions[code] ??
        'کد عمومی OBD2 — برای معنی دقیق به کتابچه‌ی خودرو یا مکانیک مراجعه کنید';
  }

  static const _descriptions = {
    'P0100': 'خرابی مدار سنسور جریان هوا (MAF)',
    'P0101': 'عملکرد خارج از محدوده سنسور MAF',
    'P0113': 'ولتاژ بالا در سنسور دمای هوای ورودی',
    'P0115': 'خرابی مدار سنسور دمای آب موتور',
    'P0117': 'ولتاژ پایین سنسور دمای آب موتور',
    'P0120': 'خرابی مدار سنسور موقعیت دریچه گاز',
    'P0125': 'زمان رسیدن به دمای کارکرد موتور بیش از حد طول کشیده',
    'P0128': 'دمای ترموستات پایین‌تر از حد نرمال',
    'P0130': 'خرابی مدار سنسور اکسیژن (بانک ۱، حسگر ۱)',
    'P0171': 'مخلوط سوخت/هوا بیش از حد رقیق (بانک ۱)',
    'P0172': 'مخلوط سوخت/هوا بیش از حد غلیظ (بانک ۱)',
    'P0201': 'خرابی مدار انژکتور سیلندر ۱',
    'P0217': 'داغ‌کردن بیش از حد موتور',
    'P0230': 'خرابی مدار اصلی پمپ بنزین',
    'P0300': 'میس‌فایر (جرقه‌نزدن) نامشخص در چند سیلندر',
    'P0301': 'میس‌فایر در سیلندر ۱',
    'P0302': 'میس‌فایر در سیلندر ۲',
    'P0303': 'میس‌فایر در سیلندر ۳',
    'P0304': 'میس‌فایر در سیلندر ۴',
    'P0325': 'خرابی مدار سنسور ضربه (Knock Sensor)',
    'P0335': 'خرابی مدار سنسور موقعیت میل‌لنگ',
    'P0340': 'خرابی مدار سنسور موقعیت میل‌بادامک',
    'P0400': 'جریان بازگشت گاز اگزوز (EGR) نامناسب',
    'P0420': 'راندمان کاتالیزور پایین‌تر از حد استاندارد (بانک ۱)',
    'P0440': 'خرابی سیستم تهویه بخارات سوخت (EVAP)',
    'P0442': 'نشتی کوچک در سیستم EVAP',
    'P0455': 'نشتی بزرگ در سیستم EVAP',
    'P0500': 'خرابی مدار سنسور سرعت خودرو',
    'P0505': 'خرابی سیستم کنترل دور آرام (Idle)',
    'P0562': 'ولتاژ سیستم پایین‌تر از حد نرمال',
    'P0601': 'خطای حافظه داخلی ماژول کنترل (ECU)',
    'P0700': 'خطای گزارش‌شده از گیربکس (نیاز به بررسی کدهای گیربکس)',
    'P0016': 'عدم تطابق زمان‌بندی میل‌لنگ و میل‌بادامک (بانک ۱، حسگر ۱)',
    'P0135': 'خرابی گرم‌کن سنسور اکسیژن (بانک ۱، حسگر ۱)',
    'P0141': 'خرابی گرم‌کن سنسور اکسیژن (بانک ۱، حسگر ۲)',
    'P0715': 'خرابی سنسور دور ورودی گیربکس',
    'P0720': 'خرابی سنسور دور خروجی گیربکس',
    'P0730': 'نسبت دنده نامناسب در گیربکس',
    'P0741': 'خرابی کلاچ کانورتور گشتاور (Torque Converter)',
    'P0750': 'خرابی سولنوید دنده A',
    'P0755': 'خرابی سولنوید دنده B',
  };
}
