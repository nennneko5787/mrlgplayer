import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/history.dart';
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

  await PlayHistory().init();
  await SettingsManager().init();
  await WebView().init();
  runApp(const ProviderScope(child: MRLGPlayer()));
}

class MRLGPlayer extends ConsumerStatefulWidget {
  const MRLGPlayer({super.key});

  @override
  ConsumerState<MRLGPlayer> createState() => _MRLGPlayerState();
}

class _MRLGPlayerState extends ConsumerState<MRLGPlayer> {
  late final AppLifecycleListener _listener;

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

    return MaterialApp(
      title: 'MRLGPlayer',
      theme: themes[settings.theme]!.theme,
      darkTheme: themes[settings.theme]!.darkTheme,
      themeMode: settings.themeMode,
      home: const HomePage(),
    );
  }
}
