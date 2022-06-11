/// A flutter plugin to connect to a users wallet like phantom, solflare, etc.
library solana_wallets_flutter;

export 'src/adapter.dart'
    show
        Adapter,
        BaseMessageSignerWalletAdapter,
        BaseSignerWalletAdapter,
        BaseWalletAdapter;
export 'src/proxy_message.dart' show ProxyMessage;
export 'src/proxy_transaction.dart' show ProxyTransaction;
export 'src/solana_wallets_flutter.dart'
    show getWalletAdapters, getWalletAdaptersWhenInitalized, initSolanaWallets;
export 'src/wallet_error.dart'
    show
        WalletAccountError,
        WalletConfigError,
        WalletConnectionError,
        WalletDisconnectedError,
        WalletDisconnectionError,
        WalletError,
        WalletKeypairError,
        WalletLoadError,
        WalletNotConnectedError,
        WalletNotReadyError,
        WalletPublicKeyError,
        WalletSendTransactionError,
        WalletSignMessageError,
        WalletSignTransactionError,
        WalletTimeoutError,
        WalletWindowBlockedError,
        WalletWindowClosedError;
export 'src/wallet_icon.dart' show WalletIcon, WalletIconType, WalletIconParser;
export 'src/wallet_state.dart' show WalletState;
