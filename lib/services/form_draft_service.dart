class FormDraftService {
  static final Map<String, Map<String, dynamic>> _drafts = {};

  static void saveDraft(String key, Map<String, dynamic> data) {
    _drafts[key] = Map<String, dynamic>.from(data);
  }

  static Map<String, dynamic>? getDraft(String key) {
    if (_drafts.containsKey(key)) {
      return Map<String, dynamic>.from(_drafts[key]!);
    }
    return null;
  }

  static void clearDraft(String key) {
    _drafts.remove(key);
  }
}
