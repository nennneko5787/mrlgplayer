import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mrlgplayer/audio.dart';
import 'package:mrlgplayer/model/lyrics.dart';
import 'package:mrlgplayer/model/settings.dart';
import 'package:mrlgplayer/themes/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static final SettingsManager _instance = SettingsManager._internal();
  SettingsManager._internal();
  factory SettingsManager() {
    return _instance;
  }

  SharedPreferences? prefs;
  final storage = FlutterSecureStorage();

  Settings? settings;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();

    final nicosid = await storage.read(key: 'nicovideo_nicosid');
    final userSession = await storage.read(key: 'nicovideo_userSession');

    settings = Settings(
      theme: (prefs!.getString("theme") == null)
          ? ThemeType.initial
          : ThemeType.values.byName(prefs!.getString("theme")!),
      nicosid: nicosid,
      userSession: userSession,
      lyricsProvider: (prefs!.getString("lyricsProvider") == null)
          ? LyricsProviderType.nicovideo
          : LyricsProviderType.values.byName(
              prefs!.getString("lyricsProvider")!,
            ),
    );

    if (nicosid != null && userSession != null) {
      final nicosidCookie = Cookie('nicosid', nicosid)
        ..domain = '.nicovideo.jp'
        ..path = '/';

      final userSessionCookie = Cookie('user_session', userSession)
        ..domain = '.nicovideo.jp'
        ..path = '/';

      await AudioManager().niconico.http.cookieJar.saveFromResponse(
        Uri.parse('https://nicovideo.jp/'),
        [nicosidCookie, userSessionCookie],
      );
    }
  }

  Future<void> saveTheme(ThemeType theme) async {
    if (SettingsManager().prefs == null) return;
    await SettingsManager().prefs!.setString("theme", theme.name);
  }

  Future<void> saveLyricsProvider(LyricsProviderType lyricsProvider) async {
    if (SettingsManager().prefs == null) return;
    await SettingsManager().prefs!.setString(
      "lyricsProvider",
      lyricsProvider.name,
    );
  }

  Future<void> saveNicoVideoSession({
    required String nicosid,
    required String userSession,
  }) async {
    await storage.write(key: "nicovideo_nicosid", value: nicosid);
    await storage.write(key: "nicovideo_userSession", value: userSession);
  }

  Future<void> logoutFromNicoVideoSession() async {
    await storage.delete(key: "nicovideo_nicosid");
    await storage.delete(key: "nicovideo_userSession");
  }
}
