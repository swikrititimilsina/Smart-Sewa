import '../utils/json_loader_util.dart';

/// Local data source that loads data from JSON asset files.
class LocalDataSource {
  /// Loads the list of available government services.
  static Future<List<dynamic>> loadServices() async {
    return JsonLoaderUtil.loadJsonList('assets/json/services.json');
  }

  /// Loads the chatbot rules configuration.
  static Future<Map<String, dynamic>> loadChatbotRules() async {
    return JsonLoaderUtil.loadJsonMap('assets/json/chatbot_rules.json');
  }
}
