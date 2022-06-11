import {
    BitKeepWalletAdapter,
    BitpieWalletAdapter,
    BloctoWalletAdapter,
    CloverWalletAdapter,
    Coin98WalletAdapter,
    CoinhubWalletAdapter,
    ExodusWalletAdapter,
    GlowWalletAdapter,
    LedgerWalletAdapter,
    MathWalletAdapter,
    PhantomWalletAdapter,
    SafePalWalletAdapter,
    SlopeWalletAdapter,
    SolflareWalletAdapter,
    SolletExtensionWalletAdapter,
    SolletWalletAdapter,
    SolongWalletAdapter,
    TokenPocketWalletAdapter,
    TorusWalletAdapter
} from '@solana/wallet-adapter-wallets';
import { Transaction, Message } from '@solana/web3.js';

const _wallets = [
    new BitKeepWalletAdapter(),
    new BitpieWalletAdapter(),
    new BloctoWalletAdapter(),
    new CloverWalletAdapter(),
    new Coin98WalletAdapter(),
    new CoinhubWalletAdapter(),
    new ExodusWalletAdapter(),
    new GlowWalletAdapter(),
    new LedgerWalletAdapter(),
    new MathWalletAdapter(),
    new PhantomWalletAdapter(),
    new SafePalWalletAdapter(),
    new SlopeWalletAdapter(),
    new SolflareWalletAdapter(),
    new SolletExtensionWalletAdapter(),
    new SolletWalletAdapter(),
    new SolongWalletAdapter(),
    new TokenPocketWalletAdapter(),
    new TorusWalletAdapter()
];

const solana_wallets_flutter = {
    'getWalletAdapters': () => _wallets,
    'transaction': {
        'from': (data) => Transaction.from(data),
        'populate': (message, signatures) => Transaction.populate(message, signatures),
    },
    'message': {
        'from': (data) => Message.from(data),
    },

};

if (window.dartInteropt == undefined) {
    window.dartInteropt = new Object();
}

window.dartInteropt.solana_wallets_flutter = solana_wallets_flutter;