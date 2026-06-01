import 'package:shared_preferences/shared_preferences.dart';

class StoredSession {
  const StoredSession({
    required this.participantId,
    required this.roomId,
    this.nickname,
    this.roomCode,
    this.roomName,
  });

  final String participantId;
  final String roomId;
  final String? nickname;
  final String? roomCode;
  final String? roomName;
}

abstract final class SessionStorage {
  static const _participantIdKey = 'participant_id';
  static const _roomIdKey = 'room_id';
  static const _nicknameKey = 'session_nickname';
  static const _roomCodeKey = 'session_room_code';
  static const _roomNameKey = 'session_room_name';

  static Future<void> saveSession({
    required String participantId,
    required String roomId,
    String? nickname,
    String? roomCode,
    String? roomName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_participantIdKey, participantId);
    await prefs.setString(_roomIdKey, roomId);
    if (nickname != null) {
      await prefs.setString(_nicknameKey, nickname);
    }
    if (roomCode != null) {
      await prefs.setString(_roomCodeKey, roomCode);
    }
    if (roomName != null) {
      await prefs.setString(_roomNameKey, roomName);
    }
  }

  static Future<StoredSession?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final participantId = prefs.getString(_participantIdKey);
    final roomId = prefs.getString(_roomIdKey);
    if (participantId == null || roomId == null) return null;
    return StoredSession(
      participantId: participantId,
      roomId: roomId,
      nickname: prefs.getString(_nicknameKey),
      roomCode: prefs.getString(_roomCodeKey),
      roomName: prefs.getString(_roomNameKey),
    );
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_participantIdKey);
    await prefs.remove(_roomIdKey);
    await prefs.remove(_nicknameKey);
    await prefs.remove(_roomCodeKey);
    await prefs.remove(_roomNameKey);
  }
}
