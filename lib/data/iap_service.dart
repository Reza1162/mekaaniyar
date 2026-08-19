import 'dart:async';
import 'package:flutter_poolakey/flutter_poolakey.dart';
import 'package:myket_iap/myket_iap.dart';
import 'package:myket_iap/util/iab_result.dart';
import 'pro_manager.dart';

/// Unified in-app purchase handling for both major Iranian app stores.
///
/// IMPORTANT — before this works, you must fill in the two RSA public
/// keys below from your own developer panels:
/// - Bazaar: پیشخوان توسعه‌دهندگان کافه‌بازار → اطلاعات برنامه → پرداخت درون‌برنامه‌ای
/// - Myket: پنل توسعه‌دهندگان مایکت → همان بخش
/// Without real keys, purchase calls will fail with a platform error —
/// that's expected until you paste in your own keys.
class IapConfig {
  static const bazaarRsaKey = 'PUT_YOUR_BAZAAR_RSA_KEY_HERE';
  static const myketRsaKey = 'PUT_YOUR_MYKET_RSA_KEY_HERE';

  /// The product SKU you create in the Bazaar/Myket developer panel for
  /// the "Pro" one-time purchase. Both stores should use the same SKU
  /// string for simplicity, but they don't have to.
  static const proSku = 'mekaaniyar_pro';
}

enum IapStore { bazaar, myket, none }

class IapService {
  static IapStore? _activeStore;

  /// Tries to connect to whichever store's client app is installed on
  /// the device (Bazaar first, then Myket). Call this once before
  /// attempting a purchase, e.g. when the pro page opens.
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
      if (ok) {
        _activeStore = IapStore.bazaar;
        return IapStore.bazaar;
      }
    } catch (_) {
      // Bazaar client not installed or connect threw; try Myket next.
    }

    try {
      final result = await MyketIAP.init(rsaKey: IapConfig.myketRsaKey);
      if (result?.isSuccess() ?? false) {
        _activeStore = IapStore.myket;
        return IapStore.myket;
      }
    } catch (_) {
      // Myket client not installed either.
    }

    _activeStore = IapStore.none;
    return IapStore.none;
  }

  /// Launches the purchase flow for the Pro SKU on whichever store was
  /// detected. Returns true if the purchase completed successfully and
  /// marks Pro as active locally.
  static Future<bool> purchasePro() async {
    final store = await detectStore();
    try {
      if (store == IapStore.bazaar) {
        // Per Poolakey's own example, a completed (non-throwing) call to
        // purchase() means success -- it doesn't expose a separate
        // "check this field" success flag beyond that.
        await FlutterPoolakey.purchase(
          IapConfig.proSku,
          payload: 'mekaaniyar-pro',
        );
        await ProManager.activate();
        return true;
      }
      if (store == IapStore.myket) {
        final result = await MyketIAP.launchPurchaseFlow(
          sku: IapConfig.proSku,
          payload: 'mekaaniyar-pro',
        );
        final IabResult? iabResult = result[MyketIAP.RESULT];
        final success = iabResult != null && iabResult.isSuccess();
        if (success) await ProManager.activate();
        return success;
      }
      return false; // no store detected — user isn't running Bazaar or Myket
    } catch (_) {
      return false;
    }
  }

  /// Checks whether the user already owns the Pro SKU on the detected
  /// store (useful to restore purchases after a reinstall).
  static Future<bool> restorePurchase() async {
    final store = await detectStore();
    try {
      if (store == IapStore.bazaar) {
        final purchases = await FlutterPoolakey.getAllPurchasedProducts();
        final owns = purchases.any((p) => p.productId == IapConfig.proSku);
        if (owns) await ProManager.activate();
        return owns;
      }
      if (store == IapStore.myket) {
        final result = await MyketIAP.getPurchase(sku: IapConfig.proSku, querySkuDetails: false);
        final IabResult? iabResult = result[MyketIAP.RESULT];
        final owns = iabResult != null && iabResult.isSuccess();
        if (owns) await ProManager.activate();
        return owns;
      }
    } catch (_) {
      // ignore — treat as not owned
    }
    return false;
  }
}
