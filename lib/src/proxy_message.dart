@JS('window.dartInteropt.solana_wallets_flutter.message')
library message;

import 'dart:typed_data';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS('from')
external Object _from(Uint8List buffer);

/// Proxies a JavaScript [`@solana/web3.js/Message`](https://solana-labs.github.io/solana-web3.js/classes/Message.html).
///
/// You can use the provided functions to use it in dart or use the
/// [js] property to either pass it to JavaScript or use additional functions
/// not provided by this plugin.
class ProxyMessage {
  /// The raw JavaScript [`@solana/web3.js/Message`](https://solana-labs.github.io/solana-web3.js/classes/Message.html) object this flutter object is wrapped around.
  ///
  /// You can pass this object to JavaScript and use it as message there,
  /// or use the [`js package`](https://pub.dev/packages/js) to access additional functions of the message
  /// not provided by this plugin.
  ///
  /// This property is a proxy object. The concept of proxy objects is
  /// explained in this plugins the README.md.
  final Object js;

  /// Creates a new message, wrapped around the JavaScript object [js].
  ///
  /// [js] is a proxy object. The concept of proxy objects is
  /// explained in this plugins the README.md.
  const ProxyMessage(this.js);

  /// Creates a message from bytes.
  ///
  /// This can be used to turn the output of [serialize]
  /// back into an object.
  factory ProxyMessage.from(Uint8List compiledMessage) =>
      new ProxyMessage(_from(compiledMessage));

  /// Serializes the message to bytes.
  ///
  /// The output of this can be turned into an object again
  /// using [ProxyMessage.from].
  Uint8List serialize() => callMethod(js, 'serialize', []);
}
