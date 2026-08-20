import 'package:myket_iap/myket_iap.dart';
import 'package:myket_iap/util/iab_result.dart';
import 'pro_manager.dart';

/// Myket in-app purchase handling.
///
/// This file is the Myket-only build variant. It's copied over
/// lib/data/iap_service.dart by CI when building the Myket APK -- see
/// the note in iap_service_bazaar.dart for why Bazaar and Myket can't
/// currently be bundled together in one APK.
///
/// IMPORTANT: fill in the RSA public key below from
/// پنل توسعه‌دهندگان مایکت → پرداخت درون‌برنامه‌ای.
/// Without a real key, purchase calls will fail — expected until you
/// paste in your own key.
class IapConfig {
  static const myketRsaKey = 'PUT_YOUR_MYKET_RSA_KEY_HERE';

  /// The product SKU created in the Myket developer panel for the
  /// "Pro" one-time purchase.
  static const proSku = 'mekaaniyar_pro';
}

enum IapStore { myket, none }

class IapService {
  static IapStore? _activeStore;

  static Future<IapStore> detectStore() async {
    if (_activeStore != null) return _activeStore!;
    try {
      final result = await MyketIAP.init(rsaKey: IapConfig.myketRsaKey)
          .timeout(const Duration(seconds: 6), onTimeout: () => null);
      _activeStore = (result?.isSuccess() ?? false) ? IapStore.myket : IapStore.none;
      return _activeStore!;
    } catch (_) {
      _activeStore = IapStore.none;
      return IapStore.none;
    }
  }

  static Future<bool> purchasePro() async {
    final store = await detectStore();
    if (store != IapStore.myket) return false;
    try {
      final result = await MyketIAP.launchPurchaseFlow(
        sku: IapConfig.proSku,
        payload: 'mekaaniyar-pro',
      ).timeout(const Duration(seconds: 30));
      final IabResult? iabResult = result[MyketIAP.RESULT];
      final success = iabResult != null && iabResult.isSuccess();
      if (success) await ProManager.activate();
      return success;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> restorePurchase() async {
    final store = await detectStore();
    if (store != IapStore.myket) return false;
    try {
      final result = await MyketIAP.getPurchase(sku: IapConfig.proSku, querySkuDetails: false)
          .timeout(const Duration(seconds: 10));
      final IabResult? iabResult = result[MyketIAP.RESULT];
      final owns = iabResult != null && iabResult.isSuccess();
      if (owns) await ProManager.activate();
      return owns;
    } catch (_) {
      return false;
    }
  }
}
