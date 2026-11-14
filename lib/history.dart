import 'package:flutter/foundation.dart';
import 'package:mrlgplayer/model/history.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;

class PlayHistory {
  static final PlayHistory _instance = PlayHistory._internal();
  PlayHistory._internal();
  factory PlayHistory() {
    return _instance;
  }

  Database? db;

  Future<void> init() async {
    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
      // The ffi default folder is relative to the current directory,
      // use the application support directory instead.
      var dir = await getApplicationSupportDirectory();
      await databaseFactory.setDatabasesPath(join(dir.path, 'databases'));
    }

    db = await _openAppDatabase();
  }

  Future<void> dispose() async {
    if (db == null) return;
    await db!.close();
  }

  Future<Database> _openAppDatabase() async {
    var path = join(await getDatabasesPath(), 'history.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE history (id INTEGER PRIMARY KEY AUTOINCREMENT, viewed_at TEXT NOT NULL, title TEXT NOT NULL, '
          'artist TEXT NOT NULL, song_id TEXT NOT NULL, service TEXT NOT NULL, artwork_url TEXT, website_url TEXT NOT NULL)',
        );
      },
    );
  }

  Future<List<History>> fetchPlayHistory() async {
    if (db == null) return [];

    List<History> history = List.empty(growable: true);
    final rows = await db!.query("history", orderBy: "id DESC");
    for (var row in rows) {
      history.add(
        History(
          id: row["song_id"]! as String,
          service: row["service"]! as String,
          title: row["title"]! as String,
          artist: row["artist"]! as String,
          websiteUrl: row["website_url"]! as String,
          viewedAt: DateTime.parse(row["viewed_at"]! as String),
          artworkUrl: row["artwork_url"] as String?,
          historyId: row["id"] as int,
        ),
      );
    }

    return history;
  }

  Future<void> pushPlayHistory(History history) async {
    if (db == null) return;

    await db!.insert('history', {
      'viewed_at': history.viewedAt.toIso8601String(),
      "title": history.title,
      "artist": history.artist,
      'song_id': history.id,
      "service": history.service,
      "artwork_url": history.artworkUrl,
      "website_url": history.websiteUrl,
    });
  }

  Future<void> deletePlayHistory(History history) async {
    if (db == null) return;

    await db!.delete(
      "history",
      where: "id = ?",
      whereArgs: [history.historyId],
    );
  }

  Future<void> clearPlayHistory() async {
    if (db == null) return;

    await db!.delete("history");
    await db!.delete(
      "sqlite_sequence",
      where: "name = ?",
      whereArgs: ["history"],
    );
  }
}
