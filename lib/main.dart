import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/history.dart';
import 'package:mrlgplayer/themes/miku.dart';
import 'package:mrlgplayer/pages/home.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';

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
  runApp(const ProviderScope(child: MRLGPlayer()));
}

class MRLGPlayer extends StatefulWidget {
  const MRLGPlayer({super.key});

  @override
  State<MRLGPlayer> createState() => _MRLGPlayerState();
}

class _MRLGPlayerState extends State<MRLGPlayer> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      // アプリがバックグラウンドに移行した時
      onPause: () {
        // バックグラウンド再生しない場合はここで一時停止
        // AudioManager().player.pause();
      },
      // アプリが終了（破棄）される時
      onDetach: () {
        PlayHistory().dispose();
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
    return MaterialApp(
      title: 'MRLGPlayer',
      theme: MikuTheme().theme,
      darkTheme: MikuTheme().darkTheme,
      home: const HomePage(),
    );
  }
}
