import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:js/js_util.dart';

import 'wallet_error.dart';
import 'wallet_icon.dart';
import 'wallet_state.dart';

/// Abstarct base class for all adapters.
abstract class Adapter {
  /// The raw JavaScript object this adapter is wrapped around.
  ///
  /// You can pass this object to JavaScript and use it as wallet adapter there.
  final Object js;

  /// Creates a new adapter, wrapped around the JavaScript object [js].
  Adapter(this.js);

  /// Wraps an Adapter implementation around the JavaScript object [js] based on it's
  /// properties.
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

  BaseWalletAdapter(Object js) : super(js);

  bool get _connected => getProperty(js, 'connected');
  bool get _connecting => getProperty(js, 'connecting');
  // There is no build in indicator for _disconnecting,
  // so we add one manually
  bool _disconnecting = false;
  @override
  String get iconString => getProperty(js, 'icon');
  /// The name of this adapter
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
  /// The url to the wallets homepage.
  String get url => getProperty(js, 'url');
  WalletReadyStateJS get _readyState =>
      walletReadyStateFromJS(getProperty(js, 'readyState'));
  /// The state the wallet is currently in.
  ///
  /// This might change at any time, especially from [WalletState.connected] to
  /// [WalletState.disconnected] since the user might just deauthorized your app
  /// using his wallet extension!
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

  /// TODO
  ///
  /// Only allowed if [walletState] is [WalletState.connected], throws a
  /// [StateError] otherwise!
  Future<String> sendTransaction(Object transaction, Object connection,
      [Object? options]) {
    if (walletState != WalletState.connected) {
      throw new StateError('Can only sign if connected!');
    }
    Object call =
        callMethod(js, 'sendTransaction', [transaction, connection, options]);
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

  BaseSignerWalletAdapter(Object js) : super(js);

  Future<Object> signTransaction(Object transaction) {
    if (walletState != WalletState.connected) {
      throw new StateError('Can only sign if connected!');
    }
    Object call = callMethod(js, 'signTransaction', [transaction]);
    return catchWalletError(promiseToFuture(call));
  }

  Future<Object> signAllTransactions(List<Object> transactions) {
    if (walletState != WalletState.connected) {
      throw new StateError('Can only sign if connected!');
    }
    Object call = callMethod(js, 'signAllTransactions', [transactions]);
    return catchWalletError(promiseToFuture(call));
  }
}

/// Adapter that can also sign transactions and messages.
class BaseMessageSignerWalletAdapter extends BaseSignerWalletAdapter {
  static bool _hasNeededProperties(Object js) => hasProperty(js, 'signMessage');
  BaseMessageSignerWalletAdapter(Object js) : super(js);

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
