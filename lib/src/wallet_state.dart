import 'package:meta/meta.dart';

@protected
enum WalletReadyStateJS { installed, loadable, notDetected, unsupported }

/// Represents the stata a wallet is currently in.
enum WalletState {
  unsupported,
  notDetected,
  loadable,
  installed,
  connecting,
  connected,
  disconnecting
}

@protected
WalletState fromWalletReadyState(WalletReadyStateJS readyState) {
  switch (readyState) {
    case WalletReadyStateJS.installed:
      return WalletState.installed;
    case WalletReadyStateJS.loadable:
      return WalletState.loadable;
    case WalletReadyStateJS.notDetected:
      return WalletState.notDetected;
    case WalletReadyStateJS.unsupported:
      return WalletState.unsupported;
  }
}

@protected
WalletReadyStateJS walletReadyStateFromJS(String readyState) {
  if (readyState == "Installed") {
    return WalletReadyStateJS.installed;
  } else if (readyState == "Loadable") {
    return WalletReadyStateJS.loadable;
  } else if (readyState == "NotDetected") {
    return WalletReadyStateJS.notDetected;
  } else if (readyState == "Unsupported") {
    return WalletReadyStateJS.unsupported;
  } else {
    throw new ArgumentError();
  }
}
