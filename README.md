# solana_wallets_flutter

This plugin allows to connect to the solana wallet of a user in a web browser like [phantom](https://phantom.app/), [solflare](https://solflare.com/), [sollet](https://www.sollet.io/) and many more.

It wraps and includes solanas official [`@solana/wallet-adapter-wallets`](https://www.npmjs.com/package/@solana/wallet-adapter-wallets). The wallet can then be used to sign transactions directly in flutter. Additionally you can pass the wallet adapter object to JavaScript and to work with it there, while providing all ui in flutter.

Currently this plugin wraps `@solana/wallet-adapter-wallets` version `0.19.15` and provides access to all wallet adapters included in this version. If there is an other version you want to use, see `tool/README.md` to learn how to build it yourself.

## Theory needed to understand the API doc
In flutter web the [`js` package](https://pub.dev/packages/js) can be used to manipulate JavaScript objects what is done by this plugin. We can also use the [`js` package](https://pub.dev/packages/js) to call JavaScript functions. Furthermore there exists objects that are of the `Object` type in flutter, but "are linked to" or "proxy" a JavaScript object. We can now call a function using the [`js` package](https://pub.dev/packages/js) and use a "proxied" object as parameter. The JavaScript function then has access to the "real" object. The term "pass the wallet adapter object to JavaScript" from above means just that.

## UI
The library `solana_wallets_flutter_ui` contains functions to show a dialog where the user can pick the preffered wallet. You don't have to use it and can create your own dialog.
![](https://raw.githubusercontent.com/EPNW/solana_wallets_flutter/master/example/example.webp)

## Usage
These are the usual steps to use this plugin:
* Call (but not await) `initSolanaWallets` from the `solana_wallets_flutter` library in the `main` method of your project
* Call `getWalletAdaptersWhenInitalized` from the `solana_wallets_flutter` library to get the adapter list and optionally filter the returned list to exclude adapters you don't want to support in your dApp
* Call `showWalletSelectDialog` from `solana_wallets_flutter_ui` with the (filtered) adapter list to let the user choose a wallet from a dialog or build your own system to let the user decide on a wallet to use
* You now have the `BaseWalletAdapter` the user wants to use, call `addListener` on it to watch the `walletState`. IMPORTANT: If you are done with the adapter, call `removeListener` OR YOU MIGHT RUN INTO PERFORMANCE ISSUES!
* Call `connect` on it, the users browser will open the wallets extension or popup where the users has to accept your dApp
* The future from `connect` either completes or throws an error. Once it's complete you might want to check `walletState` again to see if you are connected. If you have registered a listener, it should have fired if the `walletState` changed
* You can now use the `BaseWalletAdapter` in flutter or pass it's `js` property to JavaScript and do stuff with it there

### Usage in JavaScript
Make sure to read the "theory" section above first. All child classes of `Adapter` (which `BaseWalletAdapter` also is) contain a `js` property which is a proxied JavaScript object of the wallet adapter. You can pass this `js` property to JavaScript and used it there, e.g. in conjunction with [anchor](https://github.com/coral-xyz/anchor). There you would use the `js` property as `wallet` parameter to create an [`AnchorProvider`](https://coral-xyz.github.io/anchor/ts/classes/AnchorProvider.html).

Here is some code do summarize this. Assume you loaded the following JavaScript into the browser:
```javascript
import { AnchorProvider } from '@coral-xyz/anchor';
import { Connection } from '@solana/web3.js';

function doSomething(wallet) {
    const url = 'https://solana-mainnet.rpc.extrnode.com';
    const provider = new AnchorProvider(new Connection(url), wallet, {});
    //do something related to your project with the provider
}

const my_project = {
    'doSomething': doSomething
};

if (window.dartInteropt == undefined) {
    window.dartInteropt = new Object();
}

window.dartInteropt.my_project = my_project;
```
Then you can interact with it from dart using the `js` property of `Adapter` like:
```dart
@JS('window.dartInteropt.my_project')
library my_project;

import 'package:js/js.dart';
import 'package:solana_wallets_flutter/solana_wallets_flutter.dart';

@JS('doSomething')
external void _doSomething(Object wallet);

void main() async {
  BaseWalletAdapter phantom = await getPhantom();
  _doSomething(phantom.js);
}

Future<BaseWalletAdapter> getPhantom() async {
    // ...
    // get the phantom wallet and connect it,
    // see example/lib/main.dart how to do this!
}
```
To get a better unterstanding of what's going on here, read the documentation of the [`js` package](https://pub.dev/packages/js).

### Usage in flutter
This plugin only provides access to the users wallet, it is out of scope to create or send transactions. The `BaseWalletAdapter` has a `sendTransaction` method, but this is just a proxied JavaScript function and explained in detail in its API documentation (make sure to read the "theory" section to understand it), so it might be hard to use this function with "pure" flutter (because it requires you to provide a JavaScript `@solana/web3.js/Connection` object). However, you can use a package like [`solana`](https://pub.dev/packages/solana) to create and send transactions, and `solana_wallets_flutter` to sign it using the users wallet. In order to do so you need a `BaseSignerWalletAdapter`. Most adapters returned by `getWalletAdaptersWhenInitalized` are actually of this type (so you can cast them). Then, take a look at `BaseSignerWalletAdapter.signTransaction` and `BaseSignerWalletAdapter.signAllTransactions`. The example also demonstrates this (see `example/lib/transaction_example.dart`).

## Examples
The examples folder contains a project demonstrating how to connect a wallet. It also demonstrates how to use the [`solana`](https://pub.dev/packages/solana) dart package to create a transaction, sign it with `solana_wallets_flutter` and send it with the [`solana`](https://pub.dev/packages/solana) package. If you want to see a solana dApp that is written in flutter and uses this plugin, take a look at [NFT-Pixels.io](https://nft-pixels.io).