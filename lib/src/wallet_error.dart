@JS()
library wallet_error;

import 'package:solana_wallets_flutter/src/js_stub.dart'
    if (dart.library.js) 'package:js/js_util.dart';
import 'package:meta/meta.dart';

@JS('WalletError')
class _WalletError {
  external Object? error;
  external String message;
  external String name;
  external String? stack;
}

/// Abstract base class for all errors regarding a wallet.
abstract class WalletError extends Error {
  final _WalletError _e;
  WalletError._(this._e);
  Object? get error => _e.error;
  String get message => _e.message;
  String get name => _e.name;
  String? get stack => _e.stack;

  @override
  StackTrace? get stackTrace {
    String? stack = this.stack;
    if (stack != null) {
      return StackTrace.fromString(stack);
    } else {
      return StackTrace.empty;
    }
  }
}

@protected
Future<T> catchWalletError<T>(Future<T> future) async {
  try {
    return await future;
  } catch (error) {
    WalletError? e = _tryCast(error);
    if (e != null) {
      throw e;
    } else {
      rethrow;
    }
  }
}

class WalletAccountError extends WalletError {
  WalletAccountError._(_WalletError _e) : super._(_e);
}

class WalletConfigError extends WalletError {
  WalletConfigError._(_WalletError _e) : super._(_e);
}

class WalletConnectionError extends WalletError {
  WalletConnectionError._(_WalletError _e) : super._(_e);
}

class WalletDisconnectedError extends WalletError {
  WalletDisconnectedError._(_WalletError _e) : super._(_e);
}

class WalletDisconnectionError extends WalletError {
  WalletDisconnectionError._(_WalletError _e) : super._(_e);
}

class WalletKeypairError extends WalletError {
  WalletKeypairError._(_WalletError _e) : super._(_e);
}

class WalletLoadError extends WalletError {
  WalletLoadError._(_WalletError _e) : super._(_e);
}

class WalletNotConnectedError extends WalletError {
  WalletNotConnectedError._(_WalletError _e) : super._(_e);
}

class WalletNotReadyError extends WalletError {
  WalletNotReadyError._(_WalletError _e) : super._(_e);
}

class WalletPublicKeyError extends WalletError {
  WalletPublicKeyError._(_WalletError _e) : super._(_e);
}

class WalletSendTransactionError extends WalletError {
  WalletSendTransactionError._(_WalletError _e) : super._(_e);
}

class WalletSignMessageError extends WalletError {
  WalletSignMessageError._(_WalletError _e) : super._(_e);
}

class WalletSignTransactionError extends WalletError {
  WalletSignTransactionError._(_WalletError _e) : super._(_e);
}

class WalletTimeoutError extends WalletError {
  WalletTimeoutError._(_WalletError _e) : super._(_e);
}

class WalletWindowBlockedError extends WalletError {
  WalletWindowBlockedError._(_WalletError _e) : super._(_e);
}

class WalletWindowClosedError extends WalletError {
  WalletWindowClosedError._(_WalletError _e) : super._(_e);
}

WalletError? _tryCast(dynamic e) {
  try {
    _WalletError error = e as _WalletError;
    if (error.name == 'WalletAccountError') {
      return WalletAccountError._(error);
    } else if (error.name == 'WalletConfigError') {
      return WalletConfigError._(error);
    } else if (error.name == 'WalletConnectionError') {
      return WalletConnectionError._(error);
    } else if (error.name == 'WalletDisconnectedError') {
      return WalletDisconnectedError._(error);
    } else if (error.name == 'WalletDisconnectionError') {
      return WalletDisconnectionError._(error);
    } else if (error.name == 'WalletKeypairError') {
      return WalletKeypairError._(error);
    } else if (error.name == 'WalletLoadError') {
      return WalletLoadError._(error);
    } else if (error.name == 'WalletNotConnectedError') {
      return WalletNotConnectedError._(error);
    } else if (error.name == 'WalletNotReadyError') {
      return WalletNotReadyError._(error);
    } else if (error.name == 'WalletPublicKeyError') {
      return WalletPublicKeyError._(error);
    } else if (error.name == 'WalletSendTransactionError') {
      return WalletSendTransactionError._(error);
    } else if (error.name == 'WalletSignMessageError') {
      return WalletSignMessageError._(error);
    } else if (error.name == 'WalletSignTransactionError') {
      return WalletSignTransactionError._(error);
    } else if (error.name == 'WalletTimeoutError') {
      return WalletTimeoutError._(error);
    } else if (error.name == 'WalletWindowBlockedError') {
      return WalletWindowBlockedError._(error);
    } else if (error.name == 'WalletWindowClosedError') {
      return WalletWindowClosedError._(error);
    } else {
      return null;
    }
  } on TypeError {
    return null;
  } on NoSuchMethodError {
    return null;
  }
}
