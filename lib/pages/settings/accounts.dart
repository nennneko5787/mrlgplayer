import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/model/notifier/settings.dart';
import 'package:mrlgplayer/pages/settings/login/nicovideo.dart';

class AccountsSettingsPage extends ConsumerStatefulWidget {
  const AccountsSettingsPage({super.key});

  @override
  AccountsSettingsPageState createState() => AccountsSettingsPageState();
}

class AccountsSettingsPageState extends ConsumerState<AccountsSettingsPage> {
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('警告'),
          content: Text('ニコニコ動画からログアウトしますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final notifier = ref.read(settingsProvider.notifier);
                await notifier.logoutFromNicoVideoSession();

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ニコニコ動画からログアウトしました。'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text('ログアウトする'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("設定")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.tv),
              title: Text("ニコニコ動画"),
              subtitle: Text("ニコニコ動画のアカウントでログインします。"),
              trailing: (settings.userSession != null)
                  ? const Icon(Icons.check)
                  : null,
              onTap: () {
                if (settings.userSession != null) {
                  showLogoutDialog(context);
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NicovideoLoginPage(),
                  ),
                );
              },
            ),
            const Divider(),
            Center(
              child: Column(
                children: [
                  const Text("本アプリはニコニコ動画及び株式会社ドワンゴとは一切関係ありません。"),
                  const Text("本アプリに関するお問い合わせをこれらのサービスの運営会社に行わないでください。"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
