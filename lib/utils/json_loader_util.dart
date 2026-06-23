import 'dart:convert';
import 'package:flutter/services.dart';

/// Utility class for loading JSON data from assets.
class JsonLoaderUtil {
  /// Loads and parses a JSON file from the assets folder.
  static Future<dynamic> loadJson(String path) async {
    final String jsonString = await rootBundle.loadString(path);
    return json.decode(jsonString);
  }

  /// Loads a JSON file and returns it as a List.
  static Future<List<dynamic>> loadJsonList(String path) async {
    final data = await loadJson(path);
    return data as List<dynamic>;
  }

  /// Loads a JSON file and returns it as a Map.
  static Future<Map<String, dynamic>> loadJsonMap(String path) async {
    final data = await loadJson(path);
    return data as Map<String, dynamic>;
  }
}
