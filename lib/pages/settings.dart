import 'package:mrlgplayer/model/notifier/debug.dart';
import 'package:mrlgplayer/pages/settings/accounts.dart';
import 'package:mrlgplayer/pages/settings/general.dart';
import 'package:mrlgplayer/pages/settings/theme.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends ConsumerState<SettingsPage> {
  Future<String> getVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    return ' v$version ($buildNumber)';
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(debugProvider.notifier);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("設定")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text("アカウント"),
              subtitle: Text("外部サービスのアカウントと連携できます"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccountsSettingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.music_note),
              title: Text("一般"),
              subtitle: Text("曲の聴き方を調節できます"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GeneralSettingsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Symbols.palette),
              title: Text("テーマ"),
              subtitle: Text("自分好みにUIをカスタマイズできます"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeSettingsPage(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Symbols.palette),
              title: Text("デバッグメニューを開く"),
              subtitle: Text("開発者向けの機能です"),
              onTap: () {
                notifier.state = !notifier.state;
              },
            ),
            const Divider(),
            Center(
              child: Column(
                children: [
                  FutureBuilder<String>(
                    future: getVersionInfo(),
                    builder: (context, snapshot) {
                      return Text(
                        'MRLGPlayer${snapshot.hasData ? snapshot.data! : ''}',
                      );
                    },
                  ),
                  const Text("Made by nennneko5787"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
