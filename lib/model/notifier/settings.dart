import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/model/lyrics.dart';
import 'package:mrlgplayer/model/settings.dart';
import 'package:mrlgplayer/settings.dart';
import 'package:mrlgplayer/themes/theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings.g.dart';

@riverpod
class SettingsNotifier extends _$SettingsNotifier {
  @override
  Settings build() {
    return SettingsManager().settings!;
  }

  Future<void> changeTheme(ThemeType theme) async {
    await SettingsManager().saveTheme(theme);
    state = state.copyWith(theme: theme);
  }

  Future<void> changeThemeMode(ThemeMode themeMode) async {
    await SettingsManager().saveThemeMode(themeMode);
    state = state.copyWith(themeMode: themeMode);
  }

  Future<void> changeLyricsProvider(LyricsProviderType lyricsProvider) async {
    await SettingsManager().saveLyricsProvider(lyricsProvider);
    state = state.copyWith(lyricsProvider: lyricsProvider);
  }

  Future<void> saveNicoVideoSession({
    required String nicosid,
    required String userSession,
  }) async {
    await SettingsManager().saveNicoVideoSession(
      nicosid: nicosid,
      userSession: userSession,
    );
    state = state.copyWith(nicosid: nicosid, userSession: userSession);

    final nicosidCookie = Cookie('nicosid', nicosid)
      ..domain = '.nicovideo.jp'
      ..path = '/';

    final userSessionCookie = Cookie('user_session', userSession)
      ..domain = '.nicovideo.jp'
      ..path = '/';

    await AudioManager().niconico.cookieJar.saveFromResponse(
      Uri.parse('https://nicovideo.jp/'),
      [nicosidCookie, userSessionCookie],
    );
  }

  Future<void> _deleteNicoCookie(String name) async {
    final uri = Uri.parse('https://nicovideo.jp/');
    final cookieJar = AudioManager().niconico.cookieJar;

    final cookie = Cookie(name, '')
      ..expires = DateTime.utc(1970, 1, 1)
      ..domain = 'nicovideo.jp'
      ..path = '/';

    await cookieJar.saveFromResponse(uri, [cookie]);
  }

  Future<void> logoutFromNicoVideoSession() async {
    await SettingsManager().logoutFromNicoVideoSession();

    state = state.copyWith(nicosid: null, userSession: null);

    await _deleteNicoCookie('nicosid');
    await _deleteNicoCookie('user_session');
  }
}
