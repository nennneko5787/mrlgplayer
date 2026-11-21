import 'package:mrlgplayer/model/lyrics.dart';
import 'package:mrlgplayer/model/notifier/settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/widgets/label.dart';

class GeneralSettingsPage extends ConsumerStatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  GeneralSettingsPageState createState() => GeneralSettingsPageState();
}

class GeneralSettingsPageState extends ConsumerState<GeneralSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("一般")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            const Label('歌詞プロバイダー'),
            RadioGroup(
              groupValue: settings.lyricsProvider,
              onChanged: (value) async {
                await notifier.changeLyricsProvider(value!);
                setState(() {});
              },
              child: Column(
                children: [
                  RadioListTile<LyricsProviderType>(
                    title: const Text("MiDB"),
                    subtitle: const Text("azswkhn.f5.si に問い合わせを行います。"),
                    value: LyricsProviderType.midb,
                    enabled: false,
                  ),
                  RadioListTile<LyricsProviderType>(
                    title: const Text("ボカコレアプリ"),
                    subtitle: const Text(
                      "設定→アカウントよりニコニコ動画にログインする必要があります。また、一般会員は１ヶ月に歌詞を取得できる回数が制限されています。",
                    ),
                    value: LyricsProviderType.nicovideo,
                  ),
                  RadioListTile<LyricsProviderType>(
                    title: const Text("プチリリ"),
                    subtitle: const Text(
                      "検索にレートリミットが存在するため、また正しい歌詞の選択のために一度MiDBに問い合わせを行います。",
                    ),
                    value: LyricsProviderType.petitLyrics,
                  ),
                  RadioListTile<LyricsProviderType>(
                    title: const Text("Genius"),
                    subtitle: const Text("正しい歌詞の選択のために一度MiDBに問い合わせを行います。"),
                    value: LyricsProviderType.genius,
                  ),
                  const Divider(),
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "MiDBへ収録されている歌詞(同期ポイントを除く)は全て収録許可をいただいています。",
                        ),
                        const Text("本アプリはボカコレアプリ及び株式会社ドワンゴとは一切関係ありません。"),
                        const Text("本アプリはプチリリ及び株式会社シンクパワーとは一切関係ありません。"),
                        const Text(
                          "本アプリはGenius及びGenius Media Group Inc.とは一切関係ありません。",
                        ),
                        const Text("本アプリに関するお問い合わせをこれらのサービスの運営会社に行わないでください。"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
