import 'dart:typed_data';
import 'dart:convert';

const String _dataImageSvgXmlBase64 = 'data:image/svg+xml;base64,';
const String _dataImagePngBase64 = 'data:image/png;base64,';

/// A png or svg icon representing a wallet.
class WalletIcon {
  /// The type of this image.
  final WalletIconType iconType;

  /// The bytes that represent the image.
  ///
  /// Format is according to [iconType].
  final Uint8List data;

  const WalletIcon(this.iconType, this.data);
}

/// The different formats the [WalletIcon.data] bytes can be in.
enum WalletIconType { png, svg }

/// Parses the string representation of an image into a [WalletIcon].
mixin WalletIconParser {
  /// A prefixed and base64 encoded string containing an image.
  ///
  /// This parser can understand the prefixes `data:image/svg+xml;base64,`
  /// and `data:image/png;base64,`.
  String get iconString;
  WalletIcon? _iconCached;

  /// The icon represented by [iconString] or `null` if parsing failes.
  WalletIcon? get icon {
    if (_iconCached == null) {
      String str = iconString;
      if (str.startsWith(_dataImageSvgXmlBase64)) {
        _iconCached = new WalletIcon(WalletIconType.svg,
            base64.decode(str.substring(_dataImageSvgXmlBase64.length)));
      } else if (str.startsWith(_dataImagePngBase64)) {
        _iconCached = new WalletIcon(WalletIconType.png,
            base64.decode(str.substring(_dataImagePngBase64.length)));
      }
    }
    return _iconCached;
  }
}
