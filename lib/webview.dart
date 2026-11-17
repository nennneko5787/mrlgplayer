import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class WebView {
  static final WebView _instance = WebView._internal();
  WebView._internal();
  factory WebView() {
    return _instance;
  }

  WebViewEnvironment? webView;
  CookieManager? cookieManager;

  Future<void> init() async {
    if (Platform.isWindows) {
      final availableVersion = await WebViewEnvironment.getAvailableVersion();
      assert(
        availableVersion != null,
        'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.',
      );
    }

    var dir = await getApplicationSupportDirectory();
    webView = await WebViewEnvironment.create(
      settings: WebViewEnvironmentSettings(
        userDataFolder: join(dir.path, 'webview'),
      ),
    );

    cookieManager = CookieManager.instance(webViewEnvironment: webView);
  }

  Future<void> dispose() async {
    if (webView == null) return;
    await webView!.dispose();
  }
}
