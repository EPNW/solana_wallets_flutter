/// Contains ui functions to show a wallet picker dialog.
library solana_wallets_flutter_ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'solana_wallets_flutter.dart';

typedef String WalletStateToText(BuildContext context, WalletState state);

/// Can be used to override the build process of a widget.
///
/// The [child] parameter contains the original builder. That means that [child]
/// would have been used to build the widget if you hadn't used a [WidgetOverrideBuilder].
typedef Widget WidgetOverrideBuilder(BuildContext context, WidgetBuilder child);

String _defaultEnglish(BuildContext context, WalletState state) {
  switch (state) {
    case WalletState.unsupported:
      return 'Unsupported';
    case WalletState.notDetected:
      return 'Not Detected';
    case WalletState.loadable:
      return 'Loadable';
    case WalletState.installed:
      return 'Installed';
    case WalletState.connecting:
      return 'Connecting';
    case WalletState.connected:
      return 'Connected';
    case WalletState.disconnecting:
      return 'Disconnecting';
  }
}

Widget _selectWallet(BuildContext context) => const Text('Select Wallet');

/// Shows a dialog that lets the user select a wallet.
///
/// [adapters] is a list of adapters the user should choose from.
///
/// The future completes either with the [BaseWalletAdapter] the user choose
/// from the [adapters] list, or with `null` if the user closed the dialog
/// without selecting a wallet.
///
/// You can change the dimension of the dialog using the [height] and [width]
/// parameters.
///
/// The [walletStateToText] is used to convert the [BaseWalletAdapter.walletState]
/// into a human readable text. It defaults to English, so override this if you want to
/// localize the dialog. The wallet state of each element in [adapters] is shown
/// as part of the dialog.
///
/// You can change the dialogs title widget from the default `Select Wallet` text
/// to something different by specifying a builder, what is useful for localization.
///
/// Finally, you can override or extend the way the dialog should be build by passing an
/// [overrideBuilder]. In this case, whatever the [overrideBuilder] returns will
/// be used as dialog widget (for the underlying [showDialog]) instead. The `child`
/// parameter of the [WidgetOverrideBuilder] will contain the way that the dialog
/// would have been build if you hadn't spcifyed the [overrideBuilder].
Future<BaseWalletAdapter?> showWalletSelectDialog(
    {required BuildContext context,
    required List<BaseWalletAdapter> adapters,
    WidgetBuilder dialogTitleBuilder = _selectWallet,
    double height = 400,
    double width = 300,
    WalletStateToText walletStateToText = _defaultEnglish,
    WidgetOverrideBuilder? overrideBuilder}) {
  //ignore: prefer_function_declarations_over_variables
  WidgetBuilder builder = (BuildContext context) => new SimpleDialog(
        title: dialogTitleBuilder(context),
        children: [
          new SizedBox(
            height: height,
            width: width,
            child: new ListView.builder(
                itemCount: adapters.length,
                itemBuilder: (BuildContext context, int index) {
                  return new _AdapterListTile(
                    adapter: adapters[index],
                    walletStateToText: walletStateToText,
                  );
                }),
          )
        ],
      );
  return showDialog<BaseWalletAdapter>(
      context: context,
      builder: overrideBuilder == null
          ? builder
          : (BuildContext context) => overrideBuilder(context, builder));
}

class _AdapterListTile extends StatefulWidget {
  final BaseWalletAdapter adapter;
  final WalletStateToText walletStateToText;

  const _AdapterListTile(
      {required this.adapter, required this.walletStateToText, Key? key})
      : super(key: key);

  @override
  __AdapterListTileState createState() => __AdapterListTileState();
}

class __AdapterListTileState extends State<_AdapterListTile> {
  @override
  void initState() {
    super.initState();
    widget.adapter.addListener(_onChange);
  }

  @override
  void dispose() {
    super.dispose();
    widget.adapter.removeListener(_onChange);
  }

  void _onChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    void Function()? onTap;
    switch (widget.adapter.walletState) {
      case WalletState.unsupported:
        onTap = null;
        break;
      case WalletState.notDetected:
        onTap = () => launchUrl(Uri.parse(widget.adapter.url));
        break;
      case WalletState.loadable:
      case WalletState.installed:
      case WalletState.connecting:
      case WalletState.connected:
      case WalletState.disconnecting:
        onTap = () => Navigator.of(context).pop(widget.adapter);
        break;
    }
    return new ListTile(
      onTap: onTap,
      leading: new _WalletIconView(
        icon: widget.adapter.icon,
      ),
      title: new Text(widget.adapter.name),
      subtitle: new Text(
          widget.walletStateToText(context, widget.adapter.walletState)),
    );
  }
}

class _WalletIconView extends StatelessWidget {
  final WalletIcon? icon;
  const _WalletIconView({required this.icon, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WalletIcon? icon = this.icon;
    if (icon == null) {
      return const Icon(Icons.help, size: 32);
    }
    switch (icon.iconType) {
      case WalletIconType.png:
        return new Image.memory(icon.data, width: 32, height: 32);
      case WalletIconType.svg:
        return new SvgPicture.memory(icon.data, width: 32, height: 32);
    }
  }
}
