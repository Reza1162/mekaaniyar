import 'dart:async';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'pro_manager.dart';

/// Cafe Bazaar in-app purchase handling (Poolakey).
///
/// This file is the Bazaar-only build variant. It's copied over
/// lib/data/iap_service.dart by CI when building the Bazaar APK, so
/// that only Bazaar's native billing library gets bundled -- Bazaar's
/// (Poolakey) and Myket's billing SDKs both bundle an identical copy of
/// an old Google IAB AIDL stub class, which collides as a duplicate
/// class if both are included in the same APK. Building two separate
/// store-specific APKs is the standard way both vendors document
/// working around this.
///
/// IMPORTANT: fill in the RSA public key below from
/// پیشخوان توسعه‌دهندگان کافه‌بازار → اطلاعات برنامه → پرداخت درون‌برنامه‌ای.
/// Without a real key, purchase calls will fail — expected until you
/// paste in your own key.
class IapConfig {
  static const bazaarRsaKey = 'PUT_YOUR_BAZAAR_RSA_KEY_HERE';

  /// The product SKU created in the Bazaar developer panel for the
  /// "Pro" one-time purchase.
  static const proSku = 'mekaaniyar_pro';
}

enum IapStore { bazaar, none }

class IapService {
  static IapStore? _activeStore;

  static Future<IapStore> detectStore() async {
    if (_activeStore != null) return _activeStore!;

    // Poolakey's connect() is callback-based, not a returned bool, so we
    // wrap it in a Completer to await a single yes/no outcome.
    final bazaarConnected = Completer<bool>();
    try {
      await FlutterPoolakey.connect(
        IapConfig.bazaarRsaKey,
        onSucceed: () {
          if (!bazaarConnected.isCompleted) bazaarConnected.complete(true);
        },
        onFailed: () {
          if (!bazaarConnected.isCompleted) bazaarConnected.complete(false);
        },
        onDisconnected: () {
          if (!bazaarConnected.isCompleted) bazaarConnected.complete(false);
        },
      );
      final ok = await bazaarConnected.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      _activeStore = ok ? IapStore.bazaar : IapStore.none;
      return _activeStore!;
    } catch (_) {
      _activeStore = IapStore.none;
      return IapStore.none;
    }
  }

  static Future<bool> purchasePro() async {
    final store = await detectStore();
    if (store != IapStore.bazaar) return false;
    try {
      // Per Poolakey's own example, a completed (non-throwing) call to
      // purchase() means success -- it doesn't expose a separate
      // "check this field" success flag beyond that.
      await FlutterPoolakey.purchase(
        IapConfig.proSku,
        payload: 'mekaaniyar-pro',
      );
      await ProManager.activate();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> restorePurchase() async {
    final store = await detectStore();
    if (store != IapStore.bazaar) return false;
    try {
      final purchases = await FlutterPoolakey.getAllPurchasedProducts();
      final owns = purchases.any((p) => p.productId == IapConfig.proSku);
      if (owns) await ProManager.activate();
      return owns;
    } catch (_) {
      return false;
    }
  }
}
