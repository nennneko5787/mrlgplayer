import 'package:mrlgplayer/themes/base.dart';
import 'package:mrlgplayer/themes/default.dart';
import 'package:mrlgplayer/themes/miku.dart';

enum ThemeType { initial, miku }

Map<ThemeType, AppTheme> themes = {
  ThemeType.initial: DefaultTheme(),
  ThemeType.miku: MikuTheme(),
};
