@JS()
library dart_interopt_check;

import 'package:flutter/widgets.dart';

import 'package:inject_js/inject_js.dart' as InjectJS;

import 'package:solana_wallets_flutter/src/js_stub.dart'
    if (dart.library.js) 'package:js/js_util.dart';
    
import 'package:solana_wallets_flutter/src/js_stub.dart'
    if (dart.library.js) 'package:js/js.dart';

@JS('globalThis')
external Object _window;

Future<void> initDartInteropt(String packageName, String jsFileName) async {
  WidgetsFlutterBinding.ensureInitialized();
  await InjectJS.importLibrary(
      'assets/packages/$packageName/assets/$jsFileName');
  await _waitFor(packageName);
}

Future<void> _waitFor(String packageName,
    [Duration sleep = const Duration(milliseconds: 10)]) async {
  while (true) {
    if (hasProperty(_window, 'dartInteropt')) {
      Object dartInteropt = getProperty(_window, 'dartInteropt');
      if (hasProperty(dartInteropt, packageName)) {
        return;
      }
    }
    await new Future.delayed(sleep);
  }
}
