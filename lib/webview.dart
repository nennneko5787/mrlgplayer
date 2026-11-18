import 'dart:ffi';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

typedef _CoInitializeExNative = Int32 Function(
  Pointer<Void> pvReserved,
  Uint32 dwCoInit,
);
typedef _CoInitializeExDart = int Function(
  Pointer<Void> pvReserved,
  int dwCoInit,
);

const _coinitApartmentThreaded = 0x2;
const _rpcEChangedMode = 0x80010106;

/// Makes sure the current thread has a COM apartment.
///
/// WebView2 requires COM on the thread that creates its environment.
/// `windows/runner/main.cpp` initializes it for the platform thread, but a hot
/// restart only re-runs Dart's `main()`, not the native entry point, so the
/// apartment can be gone by the time the environment is re-created.
void _ensureComInitialized() {
  try {
    final ole32 = DynamicLibrary.open('ole32.dll');
    final coInitializeEx = ole32
        .lookupFunction<_CoInitializeExNative, _CoInitializeExDart>(
          'CoInitializeEx',
        );
    final hr = coInitializeEx(nullptr, _coinitApartmentThreaded);

    // S_OK (0) and S_FALSE (1) both mean "initialized".
    // RPC_E_CHANGED_MODE means another apartment model is already active,
    // which still leaves COM usable.
    if (hr < 0 && hr.toUnsigned(32) != _rpcEChangedMode) {
      debugPrint(
        '[WebView] CoInitializeEx failed: '
        '0x${hr.toUnsigned(32).toRadixString(16)}',
      );
    }
  } catch (error) {
    debugPrint('[WebView] Could not initialize COM: $error');
  }
}

class WebView {
  static final WebView _instance = WebView._internal();
  WebView._internal();
  factory WebView() {
    return _instance;
  }

  WebViewEnvironment? webView;
  CookieManager? cookieManager;

	Future<void> init() async {
	  if (cookieManager != null) return;
	
	  if (!Platform.isWindows) {
	    cookieManager = CookieManager.instance();
	    return;
	  }
	
	  _ensureComInitialized();
	
	  final availableVersion = await WebViewEnvironment.getAvailableVersion();
	  assert(
	    availableVersion != null,
	    'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.',
	  );
	
	  final dir = await getApplicationSupportDirectory();
	  final settings = WebViewEnvironmentSettings(
	    userDataFolder: join(dir.path, 'webview'),
	  );
	
	  try {
	    webView = await WebViewEnvironment.create(settings: settings);
	  } on PlatformException catch (error) {
	    debugPrint('[WebView] Failed to create WebViewEnvironment: $error');
	
	    _ensureComInitialized();
	
	    try {
	      webView = await WebViewEnvironment.create(settings: settings);
	    } on PlatformException catch (retryError) {
	      debugPrint(
	        '[WebView] Failed to create WebViewEnvironment again: $retryError',
	      );
	      webView = null;
	    }
	  }
	
	  cookieManager = CookieManager.instance(
	    webViewEnvironment: webView,
	  );
	}

  Future<void> dispose() async {
    final environment = webView;
    if (environment == null) return;

    webView = null;
    cookieManager = null;
    await environment.dispose();
  }
}
