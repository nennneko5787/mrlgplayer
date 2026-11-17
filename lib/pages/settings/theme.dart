import 'package:mrlgplayer/model/notifier/settings.dart';
import 'package:mrlgplayer/themes/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

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
        child: RadioGroup(
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
                title: const Text('ミク'),
                value: ThemeType.miku,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
