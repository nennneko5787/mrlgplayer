import 'package:mrlgplayer/themes/base.dart';
import 'package:mrlgplayer/themes/default.dart';
import 'package:mrlgplayer/themes/gumi.dart';
import 'package:mrlgplayer/themes/len.dart';
import 'package:mrlgplayer/themes/miku.dart';
import 'package:mrlgplayer/themes/rin.dart';

enum ThemeType { initial, miku, rin, len, gumi }

Map<ThemeType, AppTheme> themes = {
  ThemeType.initial: DefaultTheme(),
  ThemeType.miku: MikuTheme(),
  ThemeType.rin: RinTheme(),
  ThemeType.len: LenTheme(),
  ThemeType.gumi: GUMITheme(),
};
