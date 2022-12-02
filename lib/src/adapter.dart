import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:solana_wallets_flutter/src/js_stub.dart'
    if (dart.library.js) 'package:js/js_util.dart';

import 'proxy_transaction.dart';

import 'wallet_error.dart';
import 'wallet_icon.dart';
import 'wallet_state.dart';

/// Abstarct base class for all adapters.
abstract class Adapter {
  /// The raw JavaScript object this adapter is wrapped around.
  ///
  /// You can pass this object to JavaScript and use it as wallet adapter there.
  ///
  /// This property is a proxy object. The concept of proxy objects is
  /// explained in this plugins the README.md.
  final Object js;

  /// Creates a new adapter, wrapped around the JavaScript object [js].
  ///
  /// [js] is a proxy object. The concept of proxy objects is
  /// explained in this plugins the README.md.
  Adapter(this.js);

  /// Wraps an Adapter implementation around the JavaScript object [js] based on it's
  /// properties.
  ///
  /// [js] is a proxy object. The concept of proxy objects is
  /// explained in this plugins the README.md.
  ///
  /// Tries to return either a [BaseWalletAdapter], [BaseSignerWalletAdapter] or
  /// [BaseMessageSignerWalletAdapter] instance based on the JavaScript object [js],
  /// or throws an [ArgumentError] if the JavaScript object does not fit any of these.
  static BaseWalletAdapter inferFromJS(Object js) {
    if (BaseWalletAdapter._hasNeededProperties(js)) {
      if (BaseSignerWalletAdapter._hasNeededProperties(js)) {
        if (BaseMessageSignerWalletAdapter._hasNeededProperties(js)) {
          return new BaseMessageSignerWalletAdapter(js);
        } else {
          return new BaseSignerWalletAdapter(js);
        }
      } else {
        return new BaseWalletAdapter(js);
      }
    } else {
      throw new ArgumentError();
    }
  }
}

/// Basic adapter implementation with [ChangeNotifier] capabilities on [walletState].
class BaseWalletAdapter extends Adapter
    with ChangeNotifier, _PollingValueNotifier<WalletState>, WalletIconParser {
  // dont check pubkey since its optional
  static bool _hasNeededProperties(Object js) =>
      hasProperty(js, 'connected') &&
      hasProperty(js, 'connecting') &&
      hasProperty(js, 'icon') &&
      hasProperty(js, 'name') &&
      hasProperty(js, 'url') &&
      hasProperty(js, 'readyState') &&
      hasProperty(js, 'connect') &&
      hasProperty(js, 'disconnect') &&
      hasProperty(js, 'sendTransaction');

  /// Creates a new [BaseWalletAdapter], wrapped around the JavaScript object [js].
  ///
  /// [js] is a proxy object. The concept of proxy objects is
  /// explained in this plugins the README.md.
  BaseWalletAdapter(Object js) : super(js);

  bool get _connected => getProperty(js, 'connected');
  bool get _connecting => getProperty(js, 'connecting');
  // There is no build-in indicator for _disconnecting,
  // so we add one manually
  bool _disconnecting = false;
  @override
  String get iconString => getProperty(js, 'icon');

  /// The name of this adapter.
  String get name => getProperty(js, 'name');

  /// The base58 representation of the wallets public key.
  ///
  /// Will be `null` if [walletState] is not [WalletState.connected], and might be `null`
  /// even if it's [WalletState.connected] but the underlying wallet doesn't want to share it.
  String? get publicKey {
    if (hasProperty(js, 'publicKey')) {
      Object? publicKey = getProperty(js, 'publicKey');
      if (publicKey != null) {
        return callMethod(publicKey, 'toBase58', []);
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  /// The url to the wallet's homepage.
  String get url => getProperty(js, 'url');
  WalletReadyStateJS get _readyState =>
      walletReadyStateFromJS(getProperty(js, 'readyState'));

  /// The state the wallet currently is in.
  ///
  /// This might change at any time, especially from [WalletState.connected] to
  /// [WalletState.installed]/[WalletState.loadable] since the user might just
  /// deauthorized your app using his wallet extension/close the wallet popup!
  ///
  /// You can get notified if this value changes if you [addListener] on this object,
  /// BUT MAKE SURE to remove the listener using [removeListener] after you are done,
  /// OR YOU MIGHT ENCOUNTER PERFORMANCE ISSUES!
  WalletState get walletState {
    if (_connected) {
      return WalletState.connected;
    } else if (_connecting) {
      return WalletState.connecting;
    } else if (_disconnecting) {
      return WalletState.disconnecting;
    } else {
      return fromWalletReadyState(_readyState);
    }
  }

  /// Tries to connect to the wallet.
  ///
  /// During this step the users browser usually opens a extension window or
  /// shows a popup.
  ///
  /// Only allowed if [walletState] is [WalletState.installed] or [WalletState.loadable], throws a
  /// [StateError] otherwise!
  Future<void> connect() async {
    if (walletState != WalletState.installed &&
        walletState != WalletState.loadable) {
      throw new StateError('Can only connect if installed or loadable!');
    }
    Object call = callMethod(js, 'connect', []);
    await catchWalletError(promiseToFuture(call));
  }

  /// Disconnects the wallet.
  ///
  /// Only allowed if [walletState] is [WalletState.connected], throws a
  /// [StateError] otherwise!
  Future<void> disconnect() async {
    if (walletState != WalletState.connected) {
      throw new StateError('Can only disconnect if connected!');
    }
    _disconnecting = true;
    try {
      Object call = callMethod(js, 'disconnect', []);
      await catchWalletError(promiseToFuture(call));
    } finally {
      _disconnecting = false;
    }
  }

  /// Signs and sends a [transaction].
  ///
  /// This is a proxy function around [`@solana/wallet_adapter_base/BaseSignerWalletAdapter.sendTransaction`](https://solana-labs.github.io/wallet-adapter/classes/_solana_wallet_adapter_base.BaseSignerWalletAdapter.html#sendTransaction).
  ///
  /// Since this is only a proxy function, other parameters should be proxy objects:
  /// * [connection] should be a [`@solana/web3.js/Connection`](https://solana-labs.github.io/solana-web3.js/classes/Connection.html)
  /// * [options] is optional and can either be `null` or should be a [`@solana/wallet_adapter_base/SendTransactionOptions`](https://solana-labs.github.io/wallet-adapter/interfaces/_solana_wallet_adapter_base.SendTransactionOptions.html)
  ///
  /// The term proxy object/function is explained in the plugins README.md.
  ///
  /// If the user refuses to sign the transaction or a wallet related error occurs,
  /// an appropriate subtype of [WalletError] is thrown.
  ///
  /// Only allowed if [walletState] is [WalletState.connected], throws a
  /// [StateError] otherwise!
  Future<String> sendTransaction(
      ProxyTransaction transaction, Object connection,
      [Object? options]) {
    if (walletState != WalletState.connected) {
      throw new StateError('Can only sign if connected!');
    }
    Object call = callMethod(
        js, 'sendTransaction', [transaction.js, connection, options]);
    return catchWalletError(promiseToFuture<String>(call));
  }

  @override
  WalletState get _watchedValue => walletState;
}

/// Adapter that can also sign transactions.
class BaseSignerWalletAdapter extends BaseWalletAdapter {
  static bool _hasNeededProperties(Object js) =>
      hasProperty(js, 'signTransaction') &&
      hasProperty(js, 'signAllTransactions');

  /// Creates a new [BaseSignerWalletAdapter], wrapped around the JavaScript object [js].
  ///
  /// [js] is a proxy object. The concept of proxy objects is
  /// explained in this plugins the README.md.
  BaseSignerWalletAdapter(Object js) : super(js);

  /// Signs the [transaction] and returns a signed transaction.
  ///
  /// If the user refuses to sign the transaction or a wallet related error occurs,
  /// an appropriate subtype of [WalletError] is thrown.
  ///
  /// Only allowed if [walletState] is [WalletState.connected], throws a
  /// [StateError] otherwise!
  Future<ProxyTransaction> signTransaction(ProxyTransaction transaction) async {
    if (walletState != WalletState.connected) {
      throw new StateError('Can only sign if connected!');
    }
    Object call = callMethod(js, 'signTransaction', [transaction.js]);
    Object signedTransaction = await catchWalletError(promiseToFuture(call));
    return new ProxyTransaction(signedTransaction);
  }

  /// Signs all [transactions] and returns a list of signed transactions.
  ///
  /// If the user refuses to sign the transactions or a wallet related error occurs,
  /// an appropriate subtype of [WalletError] is thrown.
  ///
  /// Only allowed if [walletState] is [WalletState.connected], throws a
  /// [StateError] otherwise!
  Future<List<ProxyTransaction>> signAllTransactions(
      List<ProxyTransaction> transactions) async {
    if (walletState != WalletState.connected) {
      throw new StateError('Can only sign if connected!');
    }
    Object call = callMethod(js, 'signAllTransactions',
        [transactions.map((ProxyTransaction e) => e.js).toList()]);
    List<Object> signedTransactions =
        await catchWalletError(promiseToFuture(call));
    return signedTransactions
        .map((Object signedTransaction) =>
            new ProxyTransaction(signedTransaction))
        .toList();
  }
}

/// Adapter that can also sign transactions and arbitrary binary data.
class BaseMessageSignerWalletAdapter extends BaseSignerWalletAdapter {
  static bool _hasNeededProperties(Object js) => hasProperty(js, 'signMessage');

  /// Creates a new [BaseMessageSignerWalletAdapter], wrapped around the JavaScript object [js].
  ///
  /// [js] is a proxy object. The concept of proxy objects is
  /// explained in this plugins the README.md.
  BaseMessageSignerWalletAdapter(Object js) : super(js);

  /// Signs arbitrary binary [data] and returns the signature.
  ///
  /// While [data] can be any binary data, the intended way of
  /// using this is calling it on the output of [ProxyMessage.serialize()].
  ///
  /// If the user refuses to sign the message or a wallet related error occurs,
  /// an appropriate subtype of [WalletError] is thrown.
  ///
  /// Only allowed if [walletState] is [WalletState.connected], throws a
  /// [StateError] otherwise!
  Future<Uint8List> signMessage(Uint8List data) {
    if (walletState != WalletState.connected) {
      throw new StateError('Can only sign if connected!');
    }
    Object call = callMethod(js, 'signMessage', [data]);
    return catchWalletError(promiseToFuture(call));
  }
}

mixin _PollingValueNotifier<T> on ChangeNotifier {
  StreamSubscription<void>? _valueChanged;
  int _startNumber = 0;

  T get _watchedValue;

  Stream<void> _pollValue() async* {
    T lastValue = _watchedValue;
    int myStartNumber = _startNumber;
    while (true) {
      await new Future.delayed(const Duration(milliseconds: 10));
      if (myStartNumber != _startNumber) {
        break;
      }
      T newValue = _watchedValue;
      if (lastValue != newValue) {
        yield null;
      }
      lastValue = newValue;
    }
  }

  @override
  void addListener(VoidCallback listener) {
    if (!hasListeners) {
      _valueChanged = _pollValue().listen((_) => notifyListeners());
    }
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _startNumber++;
      _valueChanged?.cancel();
      _valueChanged = null;
    }
  }
}
