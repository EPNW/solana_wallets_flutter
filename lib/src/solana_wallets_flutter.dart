@JS('window.dartInteropt.solana_wallets_flutter')
library solana_wallets_flutter;

import 'dart:async';
import 'package:js/js.dart';

import 'adapter.dart';
import 'dart_interopt_check.dart';

@JS('getWalletAdapters')
external List<dynamic> _getWalletAdapters();

/// Returns all supported adapters.
///
/// Supported does not mean, that these adapters are installed in
/// the users browser. It just means that the adapter is included
/// in solanas official [`@solana/wallet-adapter-wallets`](https://solana-labs.github.io/wallet-adapter/modules/_solana_wallet_adapter_wallets.html) package.
///
/// Each adapter in this list is at least a valid [BaseWalletAdapter],
/// it might even be a [BaseSignerWalletAdapter] or [BaseMessageSignerWalletAdapter].
///
/// Must only be called after [initSolanaWallets] was `await`ed, or throws a
/// [StateError].
List<BaseWalletAdapter> getWalletAdapters() {
  if (!(_initalized?.isCompleted ?? false)) {
    throw new StateError('Call and await initSolanaWallets first!');
  }
  List<BaseWalletAdapter> adapters =
      _getWalletAdapters().cast<Object>().map(Adapter.inferFromJS).toList();
  adapters.sort((Adapter a, Adapter b) {
    if (a is BaseWalletAdapter && b is BaseWalletAdapter) {
      return a.name.compareTo(b.name);
    } else if (a is BaseWalletAdapter) {
      return 1;
    } else if (b is BaseWalletAdapter) {
      return -1;
    } else {
      return 0;
    }
  });
  return adapters;
}

/// Returns all supported adapters and waits for initalization to be completed if needed.
///
/// This uses [getWalletAdapters] internally, but does not require that the future
/// returned by [initSolanaWallets] was `await`ed. It does require that [initSolanaWallets]
/// was called or throws a [StateError]!
Future<List<BaseWalletAdapter>> getWalletAdaptersWhenInitalized() async {
  Completer<void>? initalized = _initalized;
  if (initalized == null) {
    throw new StateError(
        'Even if this method waits until initalization is done, call initSolanaWallets first!');
  }
  if (!initalized.isCompleted) {
    await initalized.future;
  }
  return getWalletAdapters();
}

Completer<void>? _initalized;

/// Initalizes the library.
///
/// This function should be the first to be called before attemting to
/// use any other function. Subsequent calles to this function are no-ops.
Future<void> initSolanaWallets() async {
  if (_initalized == null) {
    _initalized = new Completer<void>();
    await initDartInteropt('solana_wallets_flutter', 'loader.js');
    _initalized!.complete();
  }
}
