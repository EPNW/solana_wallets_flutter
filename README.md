# solana_wallets_flutter

This plugin allows to connect to the solana wallet of a user. It wraps and includes solanas official [`@solana/wallet-adapter-wallets`](https://www.npmjs.com/package/@solana/wallet-adapter-wallets). The wallet can then be used to sign transactions (but not to send them) directly in flutter. Additionally you can pass the wallet adapter object to JavaScript and to work with it there.

Currently this package wraps `@solana/wallet-adapter-wallets` version `0.16.1` and provides access to all wallet adapters included in this version. If there is a other version you want to use, see `tool/README.md` to learn how to build it yourself.

## Theory needed to understand the API doc
In flutter web the [`js`](https://pub.dev/packages/js) package can be used to manipulate JavaScript objects which is done by this package. We can also use the `js` package to call JavaScript functions. Furthermore there exists objects that are of the `Object` type in flutter, but "are linked to" or "proxy" a JavaScript object. We can now call a function using the `js` package and use a "proxied" object as parameter. The JavaScript function then has access to the "real" object. The term "pass the wallet adapter object to JavaScript" from above means just that.

## UI
The library `solana_wallets_flutter_ui` contains functions to show a dialog where the user can pick the preffered wallet. You don't have to use it and can create your own dialog.

## Usage
These are the usual steps to use this package:
* Call (but not await) `initSolanaWallets` from the `solana_wallets_flutter` library in your `main` method of your project
* Call `getWalletAdaptersWhenInitalized` from the `solana_wallets_flutter` library to get the adapter list and optionally filter the returned list to exclude adapters you don't want to support in your dApp
* Call `showWalletSelectDialog` from `solana_wallets_flutter_ui` with the (filtered) adapter list to let the user choose a wallet from a dialog or build your own system to let the user decide on a wallet to use
* You now have the `BaseWalletAdapter` the user wants to use, call `addListener` on it to watch the `walletState`. IMPORTANT: If you are done with the adapter, call `removeListener` OR YOU MIGHT RUN INTO PERFORMANCE ISSUES!
* Call `connect` on it, the users browser will open the wallets extension or popup where the users has to accept your dApp.
* The future from `connect` either completes or throws an error. Once it's complete you might wan't to check `walletState` again to see if you are connected. If you have registered a listener, it should have fired if the `walletState` changed.
* You can now use the `BaseWalletAdapter` in flutter or pass it's `js` property to JavaScript and do stuff with it there.

### Usage in JavaScript
Make sure to read the "theory" section above first. All child classes of `Adapter` (which `BaseWalletAdapter` also is) contain a `js` property which is a proxied JavaScript object of the wallet adapter. You can pass this `js` property to JavaScript and used it there, e.g. in conjunction with [anchor](https://github.com/project-serum/anchor). There you would use the `js` property as `wallet` parameter to create an [`AnchorProvider`](https://project-serum.github.io/anchor/ts/classes/AnchorProvider.html).

### Usage in flutter
This package only provides access to the users wallet, it is out of scope to create or send transactions. The `BaseWalletAdapter` has a `sendTransaction` method, but this is just a proxied JavaScript function and explained in detail in its API documentation (make sure to read the "theory" section to understand it). However, you can use a package like [`solana`](https://pub.dev/packages/solana) to create and send transactions, and this package to sign it using the users wallet. In order to do so you need a `BaseSignerWalletAdapter`. Most adapters returned by `getWalletAdaptersWhenInitalized` are actually of this type (so you can cast them). Then, take a look at `BaseSignerWalletAdapter.signTransaction` and `BaseSignerWalletAdapter.signAllTransactions`. Again, make sure you have read the "theory" section or you won't understand the API documentation.

## Examples
The examples folder contains a project demonstrating how to connect a wallet. If you want to see a solana dApp that is written in flutter and uses this package, take a look at https://nft-pixels.io 