import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/game_kind.dart';
import 'session.dart';

/// Local persistence (localStorage on the web). No accounts, no server.
abstract class SessionStore {
  Session? loadSession();
  void saveSession(Session? s);
  Set<String> seen(GameKind g);
  void saveSeen(GameKind g, Set<String> ids);
  bool flag(String key);
  void setFlag(String key, bool value);
}

class PrefsSessionStore implements SessionStore {
  PrefsSessionStore(this._p);
  final SharedPreferences _p;

  static Future<PrefsSessionStore> open() async => PrefsSessionStore(await SharedPreferences.getInstance());

  @override
  Session? loadSession() {
    final raw = _p.getString('session');
    if (raw == null) return null;
    try {
      return Session.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _p.remove('session'); // corrupt or from an incompatible version
      return null;
    }
  }

  @override
  void saveSession(Session? s) {
    if (s == null) {
      _p.remove('session');
    } else {
      _p.setString('session', jsonEncode(s.toJson()));
    }
  }

  @override
  Set<String> seen(GameKind g) => {...?_p.getStringList('seen.${g.name}')};

  @override
  void saveSeen(GameKind g, Set<String> ids) => _p.setStringList('seen.${g.name}', ids.toList());

  @override
  bool flag(String key) => _p.getBool('flag.$key') ?? false;

  @override
  void setFlag(String key, bool value) => _p.setBool('flag.$key', value);
}

/// In-memory store for tests.
class MemorySessionStore implements SessionStore {
  String? raw;
  final Map<GameKind, Set<String>> seenIds = {};
  final Map<String, bool> flags = {};

  @override
  Session? loadSession() => raw == null ? null : Session.fromJson(jsonDecode(raw!));
  @override
  void saveSession(Session? s) => raw = s == null ? null : jsonEncode(s.toJson());
  @override
  Set<String> seen(GameKind g) => {...?seenIds[g]};
  @override
  void saveSeen(GameKind g, Set<String> ids) => seenIds[g] = {...ids};
  @override
  bool flag(String key) => flags[key] ?? false;
  @override
  void setFlag(String key, bool value) => flags[key] = value;
}
