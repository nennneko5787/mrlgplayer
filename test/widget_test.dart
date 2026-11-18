import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/main.dart';
import 'package:mrlgplayer/model/lyrics.dart';
import 'package:mrlgplayer/model/notifier/playing.dart';
import 'package:mrlgplayer/model/notifier/settings.dart';
import 'package:mrlgplayer/model/settings.dart';
import 'package:mrlgplayer/model/song.dart';
import 'package:mrlgplayer/themes/theme.dart';

void main() {
  Settings createSettings() {
    return Settings(
      theme: ThemeType.initial,
      themeMode: ThemeMode.system,
      lyricsProvider: LyricsProviderType.nicovideo,
    );
  }

  Future<void> pumpApp(WidgetTester tester, {Song? song}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWithValue(createSettings()),
          playingProvider.overrideWithValue(song),
        ],
        child: const MRLGPlayer(),
      ),
    );
  }

  testWidgets('shows the home page with the player controls', (tester) async {
    await pumpApp(tester);

    expect(find.text('ニコニコ動画のURLを入力'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    expect(find.byIcon(Icons.repeat), findsOneWidget);
    expect(find.byIcon(Icons.lyrics), findsOneWidget);
    expect(find.byIcon(Icons.share), findsOneWidget);
  });

  testWidgets('opens the navigation drawer', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('MRLGPlayer'), findsOneWidget);
    expect(find.text('再生履歴'), findsOneWidget);
    expect(find.text('設定'), findsOneWidget);
  });

  testWidgets('shows the title of the current song', (tester) async {
    final song = Song(
      id: 'sm9',
      service: 'nicovideo',
      title: 'テスト曲',
      artist: 'uploader',
      websiteUrl: 'https://nico.ms/sm9',
    );

    await pumpApp(tester, song: song);

    expect(find.text('テスト曲'), findsOneWidget);
  });
}
