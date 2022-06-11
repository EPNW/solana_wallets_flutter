@JS('window.dartInteropt.solana_wallets_flutter.transaction')
library transaction;

import 'dart:typed_data';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'proxy_message.dart';

@JS('from')
external Object _from(Uint8List serializedTransaction);

// Signatures should be base58 encoded
@JS('populate')
external Object _populate(Object message, List<String> signatures);

// https://solana-labs.github.io/solana-web3.js/modules.html#SerializeConfig
@JS()
@anonymous
class _SerializeConfig {
  external bool get requireAllSignatures;
  external bool get verifySignatures;

  // Must have an unnamed factory constructor with named arguments.
  external factory _SerializeConfig(
      {bool requireAllSignatures = true, bool verifySignatures = true});
}

/// Proxies a JavaScript [`@solana/web3.js/Transaction`](https://solana-labs.github.io/solana-web3.js/classes/Transaction.html).
///
/// You can use the provided functions to use it in dart or use the
/// [js] property to either pass it to JavaScript or use additional functions
/// not provided by this plugin.
class ProxyTransaction {
  /// The raw JavaScript [`@solana/web3.js/Transaction`](https://solana-labs.github.io/solana-web3.js/classes/Transaction.html) object this flutter object is wrapped around.
  ///
  /// You can pass this object to JavaScript and use it as transaction there,
  /// or use the [`js package`](https://pub.dev/packages/js) to access additional functions of the transaction
  /// not provided by this plugin.
  ///
  /// This property is a proxy object. The concept of proxy objects is
  /// explained in this plugins the README.md.
  final Object js;

  /// Creates a new transaction, wrapped around the JavaScript object [js].
  ///
  /// [js] is a proxy object. The concept of proxy objects is
  /// explained in this plugins the README.md.
  const ProxyTransaction(this.js);

  /// Creates a transaction from bytes.
  ///
  /// This can be used to turn the output of [serialize]
  /// back into an object.
  factory ProxyTransaction.from(Uint8List serializedTransaction) =>
      new ProxyTransaction(_from(serializedTransaction));

  /// Creates a transaction from a message and optionally signatures.
  ///
  /// The signatures should be base58 encoded.
  factory ProxyTransaction.populate(ProxyMessage message,
          [List<String>? signatures]) =>
      new ProxyTransaction(_populate(message.js, signatures ?? []));

  /// Serializes the transaction to bytes.
  ///
  /// The output of this can be turned into an object again
  /// using [ProxyTransaction.from].
  Uint8List serialize(
      {bool requireAllSignatures = true, bool verifySignatures = true}) {
    _SerializeConfig config = new _SerializeConfig(
        requireAllSignatures: requireAllSignatures,
        verifySignatures: verifySignatures);
    return callMethod(js, 'serialize', [config]);
  }

  /// Compiles the instructions of this transaction into a message.
  ProxyMessage compileMessage() =>
      new ProxyMessage(callMethod(js, 'compileMessage', []));
}
