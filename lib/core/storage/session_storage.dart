import 'package:shared_preferences/shared_preferences.dart';

abstract final class SessionStorage {
  static const _participantIdKey = 'participant_id';
  static const _roomIdKey = 'room_id';

  static Future<void> saveSession({
    required String participantId,
    required String roomId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_participantIdKey, participantId);
    await prefs.setString(_roomIdKey, roomId);
  }

  static Future<({String participantId, String roomId})?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final participantId = prefs.getString(_participantIdKey);
    final roomId = prefs.getString(_roomIdKey);
    if (participantId == null || roomId == null) return null;
    return (participantId: participantId, roomId: roomId);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_participantIdKey);
    await prefs.remove(_roomIdKey);
  }
}
