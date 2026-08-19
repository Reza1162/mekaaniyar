/// Placeholder IAP implementation committed to the repo so the project
/// analyzes/builds locally without CI's store-selection step.
///
/// CI always overwrites this file before building -- see
/// store_variants/iap_service_bazaar.dart and
/// store_variants/iap_service_myket.dart, and the
/// "انتخاب پیاده‌سازی پرداخت" step in .github/workflows/build.yml.
///
/// If you build locally in Termux without going through GitHub
/// Actions, copy the variant you want yourself first, e.g.:
///   cp store_variants/iap_service_bazaar.dart lib/data/iap_service.dart
library;

enum IapStore { none }

class IapService {
  static Future<IapStore> detectStore() async => IapStore.none;
  static Future<bool> purchasePro() async => false;
  static Future<bool> restorePurchase() async => false;
}
