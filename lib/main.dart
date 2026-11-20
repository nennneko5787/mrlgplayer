import 'dart:io';
import 'dart:ui';

import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/history.dart';
import 'package:mrlgplayer/model/notifier/debug.dart';
import 'package:mrlgplayer/model/notifier/settings.dart';
import 'package:mrlgplayer/settings.dart';
import 'package:mrlgplayer/pages/home.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:mrlgplayer/themes/theme.dart';
import 'package:mrlgplayer/webview.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'net.nennneko5787.mrlgplayer.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  JustAudioMediaKit.ensureInitialized();
  JustAudioMediaKit.bufferSize = 8 * 1024 * 1024; // 8 MB
  JustAudioMediaKit.title = 'MRLGPlayer';
  JustAudioMediaKit.protocolWhitelist = const [
    'http',
    'https',
    'tcp',
    'tls',
    'crypto',
  ];
  JustAudioMediaKit.pitch = true;
  JustAudioMediaKit.prefetchPlaylist = true;

  // debug stuff
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    MRLGPlayerState.logBucket.add(
      LogEvent(
        level: LogLevel.fatal,
        message: details.exceptionAsString(),
        error: details.toDiagnosticsNode().toStringDeep(),
        stackTrace: details.stack,
      ),
    );
  };

  PlatformDispatcher.instance.onError = (exception, stackTrace) {
    MRLGPlayerState.logBucket.add(
      LogEvent(
        level: LogLevel.fatal,
        message: "Unhandled Exception",
        error: exception,
        stackTrace: stackTrace,
      ),
    );
    return false; // "false" still dumps it to the console.
  };

  await PlayHistory().init();
  await SettingsManager().init();
  await WebView().init();
  runApp(const ProviderScope(child: MRLGPlayer()));
}

class MRLGPlayer extends ConsumerStatefulWidget {
  const MRLGPlayer({super.key});

  @override
  ConsumerState<MRLGPlayer> createState() => MRLGPlayerState();
}

class MRLGPlayerState extends ConsumerState<MRLGPlayer> {
  late final AppLifecycleListener _listener;
  static final LogBucket logBucket = LogBucket();

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onDetach: () {
        PlayHistory().dispose();
        WebView().dispose();
        AudioManager().dispose();
      },
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final debugMenuOpening = ref.watch(debugProvider);

    return MaterialApp(
      title: 'MRLGPlayer',
      theme: themes[settings.theme]!.theme,
      darkTheme: themes[settings.theme]!.darkTheme,
      themeMode: settings.themeMode,
      home: const HomePage(),
      builder: (context, child) {
        return DebugOverlay(
          hiddenFields: const [HttpHeaders.authorizationHeader, "Token"],
          logBucket: logBucket,
          debugEntries: [],
          visible: debugMenuOpening,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
