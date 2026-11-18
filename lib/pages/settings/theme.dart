import 'package:mrlgplayer/model/notifier/settings.dart';
import 'package:mrlgplayer/themes/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/widgets/label.dart';

class ThemeSettingsPage extends ConsumerStatefulWidget {
  const ThemeSettingsPage({super.key});

  @override
  ThemeSettingsPageState createState() => ThemeSettingsPageState();
}

class ThemeSettingsPageState extends ConsumerState<ThemeSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text("テーマ")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            const Label('モード'),
            RadioGroup(
              groupValue: settings.themeMode,
              onChanged: (value) async {
                await notifier.changeThemeMode(value!);
                setState(() {});
              },
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    title: const Text('システム'),
                    value: ThemeMode.system,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('ライト'),
                    value: ThemeMode.light,
                  ),
                  RadioListTile<ThemeMode>(
                    title: const Text('ダーク'),
                    value: ThemeMode.dark,
                  ),
                ],
              ),
            ),
            const Divider(),
            const Label('テーマ'),
            RadioGroup(
              groupValue: settings.theme,
              onChanged: (value) async {
                await notifier.changeTheme(value!);
                setState(() {});
              },
              child: Column(
                children: [
                  RadioListTile<ThemeType>(
                    title: const Text('デフォルト'),
                    value: ThemeType.initial,
                  ),
                  RadioListTile<ThemeType>(
                    title: const Text('Miku'),
                    value: ThemeType.miku,
                  ),
                  RadioListTile<ThemeType>(
                    title: const Text('Rin'),
                    value: ThemeType.rin,
                  ),
                  RadioListTile<ThemeType>(
                    title: const Text('Len'),
                    value: ThemeType.len,
                  ),
                  RadioListTile<ThemeType>(
                    title: const Text('GUMI'),
                    value: ThemeType.gumi,
                  ),
                ],
              ),
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
