import 'package:mrlgplayer/model/lyrics.dart';
import 'package:mrlgplayer/themes/theme.dart';

class Settings {
  // settings
  ThemeType theme;
  LyricsProviderType lyricsProvider;

  // niconico cookies
  String? nicosid;
  String? userSession;

  Settings({
    required this.theme,
    this.nicosid,
    this.userSession,
    required this.lyricsProvider,
  });

  static const _unset = Object();

  Settings copyWith({
    ThemeType? theme,
    Object? nicosid = _unset,
    Object? userSession = _unset,
    LyricsProviderType? lyricsProvider,
  }) {
    return Settings(
      theme: theme ?? this.theme,
      nicosid: identical(nicosid, _unset) ? this.nicosid : nicosid as String?,
      userSession: identical(userSession, _unset)
          ? this.userSession
          : userSession as String?,
      lyricsProvider: lyricsProvider ?? this.lyricsProvider,
    );
  }
}
