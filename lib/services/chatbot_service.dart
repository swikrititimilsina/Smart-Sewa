import '../data/local_data_source.dart';

/// Service for the Smart Sathi chatbot.
class ChatbotService {
  static Map<String, dynamic>? _rules;

  /// Initializes the chatbot by loading rules from JSON.
  static Future<void> initialize() async {
    try {
      _rules = await LocalDataSource.loadChatbotRules();
    } catch (_) {
      _rules = {};
    }
  }

  /// Processes a user message and returns a bot response.
  static String getResponse(String userMessage) {
    if (_rules == null || _rules!.isEmpty) {
      return 'Hello! I am Smart Sathi, your government service assistant. '
          'How can I help you today?';
    }

    final message = userMessage.toLowerCase().trim();

    // Check for keyword matches in rules
    if (_rules!.containsKey('responses')) {
      final responses = _rules!['responses'] as Map<String, dynamic>?;
      if (responses != null) {
        for (final entry in responses.entries) {
          if (message.contains(entry.key.toLowerCase())) {
            return entry.value.toString();
          }
        }
      }
    }

    // Default response
    return 'Thank you for your query. Our team will look into it. '
        'You can also visit your nearest government office for assistance.';
  }

  /// Returns a greeting message for the chatbot.
  static String get greetingMessage =>
      'Namaste! \u0928\u092e\u0938\u094d\u0924\u0947! I am Smart Sathi, your government service assistant. '
      'Ask me anything about government services like NID, Citizenship, '
      'Birth Registration, or Passport.';
}
