import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/model/notifier/settings.dart';
import 'package:mrlgplayer/webview.dart';

class NicovideoLoginPage extends ConsumerStatefulWidget {
  const NicovideoLoginPage({super.key});

  @override
  NicovideoLoginPageState createState() => NicovideoLoginPageState();
}

class NicovideoLoginPageState extends ConsumerState<NicovideoLoginPage> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
	  mediaPlaybackRequiresUserGesture: false,
	  allowsInlineMediaPlayback: true,
	  javaScriptEnabled: true,
	  transparentBackground: false,
	  isInspectable: true,
  );
  double progress = 0.0;
  PullToRefreshController? pullToRefreshController;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = !(Platform.isAndroid || Platform.isIOS)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: Colors.blue),
            onRefresh: () async {
              if (Platform.isAndroid) {
                webViewController?.reload();
              } else if (Platform.isIOS) {
                webViewController?.loadUrl(
                  urlRequest: URLRequest(
                    url: await webViewController?.getUrl(),
                  ),
                );
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("ニコニコ動画へログイン")),
      body: SafeArea(
        child: Expanded(
          child: Stack(
            children: [
              InAppWebView(
                key: webViewKey,
							  webViewEnvironment: Platform.isWindows
							      ? WebView().webView
							      : null,
                initialUrlRequest: URLRequest(
                  url: WebUri(
                    "https://account.nicovideo.jp/login?site=niconico&next_url=%2F&sec=header_pc&cmnhd_ref=device%3Dpc%26site%3Dniconico%26pos%3Dheader_login%26page%3Dtop",
                  ),
                ),
                initialSettings: settings,
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) async {
                  if (url == null ||
                      url.host != "www.nicovideo.jp" ||
                      url.host != "sp.nicovideo.jp" ||
                      url.path != "/") {
                    return;
                  }

                  final cookieManager = CookieManager.instance(
                    webViewEnvironment: WebView().webView,
                  );

                  final cookies = await cookieManager.getCookies(
                    url: WebUri("https://www.nicovideo.jp/"),
                  );

                  debugPrint(
                    "Niconico cookies: ${cookies.map((e) => e.name).join(", ")}",
                  );

                  final nicosid = cookies
                      .where((cookie) => cookie.name == "nicosid")
                      .firstOrNull;

                  final userSession = cookies
                      .where((cookie) => cookie.name == "user_session")
                      .firstOrNull;

                  debugPrint("nicosid: ${nicosid != null}");
                  debugPrint("user_session: ${userSession != null}");

                  if (nicosid == null || userSession == null) {
                    debugPrint("Login cookies not found");
                    return;
                  }

                  await notifier.saveNicoVideoSession(
                    nicosid: nicosid.value,
                    userSession: userSession.value,
                  );

                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  var uri = navigationAction.request.url!;

                  if (![
                    "http",
                    "https",
                    "file",
                    "chrome",
                    "data",
                    "javascript",
                    "about",
                  ].contains(uri.scheme)) {
                    return NavigationActionPolicy.CANCEL;
                  }

                  return NavigationActionPolicy.ALLOW;
                },
                onReceivedError: (controller, request, error) {
                  pullToRefreshController?.endRefreshing();
                },
                onProgressChanged: (controller, progress) {
                  if (progress == 100) {
                    pullToRefreshController?.endRefreshing();
                  }
                  setState(() {
                    this.progress = progress / 100;
                  });
                },
              ),
              progress < 1.0
                  ? LinearProgressIndicator(value: progress)
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}
