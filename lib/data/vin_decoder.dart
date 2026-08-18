/// Offline VIN (Vehicle Identification Number) decoder.
///
/// Decodes what's reliably derivable from the VIN structure itself,
/// per the ISO 3779 / SAE J853 standard, without needing an internet
/// lookup:
/// - World Manufacturer Identifier (first 3 characters) -> manufacturer,
///   for a curated set of high-confidence entries only. Unknown codes
///   are reported as unknown rather than guessed.
/// - Model year (10th character), per the standard repeating 30-year
///   cycle table.
class VinInfo {
  final String manufacturer;
  final List<int> possibleYears; // usually 2 candidates (cycles 30 yrs apart)
  final bool validFormat;
  VinInfo({required this.manufacturer, required this.possibleYears, required this.validFormat});
}

class VinDecoder {
  // Curated, high-confidence WMI prefixes only. Deliberately not
  // exhaustive -- an unmatched code is reported as unknown rather than
  // guessed, to avoid presenting wrong info as fact.
  static const Map<String, String> _wmiTable = {
    'NAA': 'ایران خودرو (پژو ایران)',
    'KMH': 'هیوندای (کره جنوبی)',
    'KNA': 'کیا (کره جنوبی)',
    'KNM': 'رنو سامسونگ (کره جنوبی)',
    'JTD': 'تویوتا (ژاپن)',
    'JTE': 'تویوتا (ژاپن)',
    'JTM': 'تویوتا (ژاپن)',
    'JN1': 'نیسان (ژاپن)',
    'JN8': 'نیسان (ژاپن)',
    'JHM': 'هوندا (ژاپن)',
    'VF3': 'پژو (فرانسه)',
    'VF7': 'سیتروئن (فرانسه)',
    'VF1': 'رنو (فرانسه)',
    'WVW': 'فولکس‌واگن (آلمان)',
    'WV1': 'فولکس‌واگن تجاری (آلمان)',
    'WBA': 'بی‌ام‌و (آلمان)',
    'WDB': 'مرسدس‌بنز (آلمان)',
    'WDD': 'مرسدس‌بنز (آلمان)',
  };

  // Standard SAE/ISO model-year code table (10th VIN character),
  // repeating on a 30-year cycle.
  static const Map<String, List<int>> _yearTable = {
    'A': [1980, 2010], 'B': [1981, 2011], 'C': [1982, 2012], 'D': [1983, 2013],
    'E': [1984, 2014], 'F': [1985, 2015], 'G': [1986, 2016], 'H': [1987, 2017],
    'J': [1988, 2018], 'K': [1989, 2019], 'L': [1990, 2020], 'M': [1991, 2021],
    'N': [1992, 2022], 'P': [1993, 2023], 'R': [1994, 2024], 'S': [1995, 2025],
    'T': [1996, 2026], 'V': [1997, 2027], 'W': [1998, 2028], 'X': [1999, 2029],
    'Y': [2000, 2030], '1': [2001, 2031], '2': [2002, 2032], '3': [2003, 2033],
    '4': [2004, 2034], '5': [2005, 2035], '6': [2006, 2036], '7': [2007, 2037],
    '8': [2008, 2038], '9': [2009, 2039],
  };

  static bool isValidFormat(String vin) {
    final v = vin.trim().toUpperCase();
    if (v.length != 17) return false;
    // I, O, Q are never used in VINs to avoid confusion with 1/0.
    return RegExp(r'^[A-HJ-NPR-Z0-9]{17}$').hasMatch(v);
  }

  static VinInfo decode(String vin) {
    final v = vin.trim().toUpperCase();
    final valid = isValidFormat(v);
    if (!valid) {
      return VinInfo(manufacturer: '', possibleYears: [], validFormat: false);
    }
    final wmi = v.substring(0, 3);
    final manufacturer = _wmiTable[wmi] ?? '';
    final yearChar = v[9];
    final years = _yearTable[yearChar] ?? [];
    return VinInfo(manufacturer: manufacturer, possibleYears: years, validFormat: true);
  }
}
