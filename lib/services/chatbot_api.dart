// lib/services/chatbot_api.dart

import 'package:smartsewa/services/smart_sathi.dart';

class ChatbotApi {
  // Store instances per session ID to support multiple chats/users if needed
  static final Map<String, SmartSathi> _sessions = {};

  SmartSathi _getBot(String sessionId) {
    if (!_sessions.containsKey(sessionId)) {
      _sessions[sessionId] = SmartSathi();
    }
    return _sessions[sessionId]!;
  }

  Future<Map<String, dynamic>> sendMessage(String message, String sessionId) async {
    final bot = _getBot(sessionId);
    return await bot.respond(message);
  }

  Future<void> resetChat(String sessionId) async {
    final bot = _getBot(sessionId);
    bot.reset();
  }
}